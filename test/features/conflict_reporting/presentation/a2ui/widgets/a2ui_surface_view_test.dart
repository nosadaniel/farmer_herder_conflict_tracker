// Smoke tests for the A2UI rendering pipeline (SurfaceController + Surface +
// Conversation, wired via ../providers/a2ui_providers.dart).
//
// No live Gemini call is available to this track, so per the task brief we
// test against the EXACT worked HIGH-risk example fenced-JSON text from
// docs/a2ui_gemini_contract.md §6, feeding it through
// `A2uiTransportAdapter.addChunk()` via a fake `a2uiSendHandlerProvider`
// override that just triggers that fixture text — proving the render
// pipeline works end-to-end without a live Gemini call.
//
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/presentation/a2ui/providers/a2ui_providers.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/presentation/a2ui/widgets/a2ui_surface_view.dart';

/// The exact worked HIGH-risk example from docs/a2ui_gemini_contract.md §6.
const String _highRiskFixture = '''
```json
{
  "version": "v0.9",
  "createSurface": {
    "surfaceId": "report_1758389421000",
    "catalogId": "https://a2ui.org/specification/v0_9/catalogs/basic/catalog.json",
    "sendDataModel": false
  }
}
```
```json
{
  "version": "v0.9",
  "updateComponents": {
    "surfaceId": "report_1758389421000",
    "components": [
      { "id": "root", "component": "Column", "children": ["icon", "headline", "body", "actions"] },
      { "id": "icon", "component": "Icon", "name": "warning" },
      { "id": "headline", "component": "Text", "variant": "h1", "text": "Conflict reported nearby. Take action now." },
      { "id": "body", "component": "Text", "variant": "body", "text": "A large herd was seen crossing the northern stream toward the village farms. This area has had serious conflicts before." },
      { "id": "actions", "component": "Column", "children": ["shareBtn", "callBtn"] },
      { "id": "shareBtn", "component": "Button", "variant": "primary", "child": "shareText",
        "action": { "event": { "name": "share_alert", "context": { "summary": "Herd crossing toward farms near Kaduna. High risk area.", "riskLevel": "high" } } } },
      { "id": "shareText", "component": "Text", "text": "Share Alert" },
      { "id": "callBtn", "component": "Button", "variant": "borderless", "child": "callText",
        "action": { "event": { "name": "call_mediation", "context": { "riskLevel": "high" } } } },
      { "id": "callText", "component": "Text", "text": "Contact Mediation Patrol" }
    ]
  }
}
```
''';

/// Builds a [ProviderContainer] whose fake `onSend` feeds [text] into the
/// same transport the [conversationProvider] uses, simulating a Gemini
/// response without any network/Firebase AI call.
ProviderContainer _containerWithFixtureHandler(String text) {
  return ProviderContainer(
    overrides: [
      a2uiSendHandlerProvider.overrideWith((ref) {
        return (ChatMessage message) async {
          ref.read(a2uiTransportProvider).addChunk(text);
        };
      }),
    ],
  );
}

void main() {
  testWidgets(
    'renders the contract §6 HIGH-risk fixture headline and Share Alert '
    'button',
    (tester) async {
      final container = _containerWithFixtureHandler(_highRiskFixture);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: A2uiSurfaceView()),
          ),
        ),
      );

      await container.read(conversationProvider).sendRequest(
        ChatMessage.user(
          'A large herd just crossed the northern stream heading south '
          'toward the village farms.',
        ),
      );

      // Let the chunk-parsing pipeline (async stream transformer) and the
      // resulting surface-creation/component-update events propagate, then
      // rebuild the widget tree.
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Conflict reported nearby. Take action now.'),
        findsOneWidget,
      );
      expect(find.text('Share Alert'), findsOneWidget);
      expect(find.text('Contact Mediation Patrol'), findsOneWidget);
    },
  );

  testWidgets(
    'shows the skeleton loader while Conversation.state.isWaiting with no '
    'surface yet',
    (tester) async {
      // onSend never completes on its own — the test completes it manually —
      // so isWaiting stays true for as long as the widget is pumped, letting
      // us assert the loading placeholder renders.
      final completer = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          a2uiSendHandlerProvider.overrideWith((ref) {
            return (ChatMessage message) => completer.future;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: A2uiSurfaceView())),
        ),
      );

      final sendFuture = container.read(conversationProvider).sendRequest(
        ChatMessage.user('report'),
      );
      await tester.pump();

      // The AppSkeleton-wrapped placeholder, not a bare spinner — see
      // a2ui_surface_view.dart's _A2uiSkeletonLoader.
      expect(find.text('Assessing the situation'), findsOneWidget);

      completer.complete();
      await sendFuture;
      await tester.pump();
    },
  );
}
