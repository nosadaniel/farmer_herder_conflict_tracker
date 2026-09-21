// Smoke tests for ReportWizardController's FSM/navigation logic.
//
// No live Firebase AI is available in a plain `flutter test` run (genui's
// ReportWizardSession reaches for `FirebaseAI.googleAI()`, which needs an
// initialized Firebase app) — so, mirroring
// a2ui_surface_view_test.dart's approach of faking the *transport*'s onSend
// rather than mocking genui's own classes, this test overrides
// [reportWizardSessionFactoryProvider] with a [FakeWizardSession] built from
// real, Firebase-free `genui` primitives (SurfaceController + Conversation +
// A2uiTransportAdapter) whose "model" is just a fixture-JSON generator. That
// exercises the exact same controller code production uses (event-waiting,
// DataModel subscriptions, step-generation caching) without a network call.
import 'package:farmer_herder_conflict_tracker/features/report_wizard/application/report_wizard_catalog.dart';
import 'package:farmer_herder_conflict_tracker/features/report_wizard/application/report_wizard_session.dart';
import 'package:farmer_herder_conflict_tracker/features/report_wizard/domain/report_wizard_step.dart';
import 'package:farmer_herder_conflict_tracker/features/report_wizard/presentation/providers/report_wizard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

/// A [WizardSession] built from real `genui` primitives whose "Gemini call"
/// just returns a canned surface (one `Text` root component) for whatever
/// `surfaceId` the prompt asked for — extracted via the same
/// `"Use this surfaceId: <id>"` line `ReportWizardController._promptFor`
/// always appends.
class FakeWizardSession implements WizardSession {
  FakeWizardSession(Catalog catalog) {
    controller = SurfaceController(catalogs: [catalog]);
    transport = A2uiTransportAdapter(onSend: _onSend);
    conversation = Conversation(controller: controller, transport: transport);
  }

  late final SurfaceController controller;
  late final A2uiTransportAdapter transport;
  late final Conversation conversation;

  int sendTextCallCount = 0;
  final List<String> prompts = [];

  @override
  SurfaceHost get host => controller;

  @override
  Stream<ConversationEvent> get events => conversation.events;

  @override
  Future<void> sendText(String prompt) {
    sendTextCallCount++;
    prompts.add(prompt);
    return conversation.sendRequest(ChatMessage.user(prompt));
  }

  Future<void> _onSend(ChatMessage message) async {
    final match = RegExp(r'Use this surfaceId: (\S+)').firstMatch(message.text);
    final surfaceId = match?.group(1) ?? 'unknown_surface';
    transport.addChunk(_fixtureFor(surfaceId));
  }

  @override
  void dispose() {
    conversation.dispose();
    transport.dispose();
    controller.dispose();
  }
}

String _fixtureFor(String surfaceId) =>
    '''
```json
{
  "version": "v0.9",
  "createSurface": {
    "surfaceId": "$surfaceId",
    "catalogId": "https://a2ui.org/specification/v0_9/catalogs/basic/catalog.json",
    "sendDataModel": false
  }
}
```
```json
{
  "version": "v0.9",
  "updateComponents": {
    "surfaceId": "$surfaceId",
    "components": [
      { "id": "root", "component": "Text", "text": "stub" }
    ]
  }
}
```
''';

void main() {
  late FakeWizardSession fakeSession;
  late ProviderContainer container;

  setUp(() {
    fakeSession = FakeWizardSession(reportWizardCatalog);
    container = ProviderContainer(
      overrides: [
        reportWizardSessionFactoryProvider.overrideWithValue(() => fakeSession),
      ],
    );
  });

  tearDown(() => container.dispose());

  test(
    'initialize() generates Step 1 exactly once, even if called twice',
    () async {
      final notifier = container.read(reportWizardControllerProvider.notifier);

      await notifier.initialize();
      await notifier.initialize();

      expect(fakeSession.sendTextCallCount, 1);
      expect(container.read(reportWizardControllerProvider).stepGenerated, {
        ReportWizardStep.where,
      });
    },
  );

  test('next() only calls sendText once per not-yet-generated step', () async {
    final notifier = container.read(reportWizardControllerProvider.notifier);
    await notifier.initialize();
    expect(fakeSession.sendTextCallCount, 1);

    // Simulate the user tapping a ChoicePicker option on Step 1 — a real
    // ChoicePicker writes a one-element list to the bound path (verified
    // against genui-0.10.3's choice_picker.dart source).
    fakeSession.host
        .contextFor(ReportWizardStep.where.surfaceId)
        .dataModel
        .update(DataPath('/report/location'), ['Kaduna State']);

    await notifier.next(); // where -> whatsHappening (new step: 1 more call)
    expect(fakeSession.sendTextCallCount, 2);
    expect(
      container.read(reportWizardControllerProvider).step,
      ReportWizardStep.whatsHappening,
    );
  });

  test('back() never triggers a Gemini call', () async {
    final notifier = container.read(reportWizardControllerProvider.notifier);
    await notifier.initialize();
    fakeSession.host
        .contextFor(ReportWizardStep.where.surfaceId)
        .dataModel
        .update(DataPath('/report/location'), ['Kaduna State']);
    await notifier.next();
    expect(fakeSession.sendTextCallCount, 2);

    notifier.back();
    expect(
      container.read(reportWizardControllerProvider).step,
      ReportWizardStep.where,
    );
    expect(fakeSession.sendTextCallCount, 2); // unchanged — pure local move
  });

  test(
    'revisiting an already-generated step via next() does not regenerate',
    () async {
      final notifier = container.read(reportWizardControllerProvider.notifier);
      await notifier.initialize();
      fakeSession.host
          .contextFor(ReportWizardStep.where.surfaceId)
          .dataModel
          .update(DataPath('/report/location'), ['Kaduna State']);
      await notifier.next(); // -> whatsHappening (2 calls total)
      expect(fakeSession.sendTextCallCount, 2);

      notifier.back(); // -> where, free
      await notifier.next(); // -> whatsHappening again, already generated
      expect(fakeSession.sendTextCallCount, 2); // still 2, no new call
      expect(
        container.read(reportWizardControllerProvider).step,
        ReportWizardStep.whatsHappening,
      );
    },
  );

  test('answers mirrors simulated ChoicePicker DataModel writes, unwrapping '
      "genui's one-element-list convention", () async {
    final notifier = container.read(reportWizardControllerProvider.notifier);
    await notifier.initialize();
    fakeSession.host
        .contextFor(ReportWizardStep.where.surfaceId)
        .dataModel
        .update(DataPath('/report/location'), ['Kaduna State']);
    await notifier.next();

    fakeSession.host
        .contextFor(ReportWizardStep.whatsHappening.surfaceId)
        .dataModel
        .update(DataPath('/report/whatsHappening'), ['Herd sighting']);

    final answers = container.read(reportWizardControllerProvider).answers;
    expect(answers['location'], 'Kaduna State');
    expect(answers['whatsHappening'], 'Herd sighting');
  });

  test(
    'next() requires an answer before advancing past a choice step',
    () async {
      final notifier = container.read(reportWizardControllerProvider.notifier);
      await notifier.initialize();

      await notifier.next(); // no answer set on Step 1 yet

      expect(
        container.read(reportWizardControllerProvider).step,
        ReportWizardStep.where, // still on Step 1
      );
      expect(
        container.read(reportWizardControllerProvider).validationMessage,
        isNotNull,
      );
      expect(fakeSession.sendTextCallCount, 1); // no extra generation attempt
    },
  );

  test('skip() advances without requiring an answer', () async {
    final notifier = container.read(reportWizardControllerProvider.notifier);
    await notifier.initialize();

    await notifier.skip();

    expect(
      container.read(reportWizardControllerProvider).step,
      ReportWizardStep.whatsHappening,
    );
    expect(fakeSession.sendTextCallCount, 2);
  });

  group('reportWizardStateCentroids', () {
    test('has exactly the 6 specified Middle Belt states and centroids', () {
      expect(reportWizardStateCentroids, {
        'Kaduna': (10.5222, 7.4383),
        'Kano': (12.0022, 8.5920),
        'Plateau': (9.2182, 9.5179),
        'Benue': (7.3369, 8.7404),
        'Nasarawa': (8.5378, 8.3206),
        'Taraba': (7.9994, 10.7740),
      });
    });
  });
}
