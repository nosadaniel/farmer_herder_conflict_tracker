// A second, separate GenUI session — collects structured wizard input only.
//
// Per docs/refactor.md §1-§2: the existing "Result session"
// (lib/features/conflict_reporting/presentation/a2ui/providers/a2ui_providers.dart)
// is frozen and owned by a different track. This session uses
// `PromptBuilder.custom(allowedOperations: SurfaceOperations.createAndUpdate(dataModel: false))`
// with fixed, deterministic surfaceIds per `ReportWizardStep` and DataModel
// bindings for tap-to-select answers, instead of the Result session's
// `.chat()`/createOnly/one-surface-per-turn preset.
import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:genui/genui.dart';
import 'package:logger/logger.dart';

import '../../conflict_reporting/data/datasources/remote/gemini_remote_datasource.dart'
    show GeminiRemoteDataSource;

final _log = Logger();

/// The minimal seam [ReportWizardController] (presentation/providers) depends
/// on, rather than the concrete [ReportWizardSession] directly.
///
/// [ReportWizardSession]'s real constructor reaches for
/// `FirebaseAI.googleAI()`, which needs a live, initialized Firebase app —
/// unavailable in plain `flutter test` runs. Depending on this interface
/// instead lets tests supply a fake built from real, Firebase-free `genui`
/// primitives (`SurfaceController` + `Conversation` + `A2uiTransportAdapter`,
/// the same trio `a2ui_surface_view_test.dart` already fakes a send handler
/// for) while exercising the exact same controller logic production uses.
abstract class WizardSession {
  /// Where `DataModel`/surface state for a given `surfaceId` lives.
  SurfaceHost get host;

  /// Conversation-level events (surface added/updated, errors, etc).
  Stream<ConversationEvent> get events;

  /// Sends one turn's prompt text to the model.
  Future<void> sendText(String prompt);

  void dispose();
}

/// A bounded, per-wizard-run GenUI session (`docs/refactor.md` §3).
///
/// Created lazily when the user starts a report, disposed the moment they
/// hit Create or Close/restart — the opposite lifetime from the app-lifetime
/// `a2ui_providers.dart` providers, which is why this isn't modeled as a set
/// of `keepAlive` Riverpod providers the way that session is.
class ReportWizardSession implements WizardSession {
  ReportWizardSession({
    required Catalog catalog,
    required String systemInstruction,
  }) {
    controller = SurfaceController(catalogs: [catalog]);
    final prompt = PromptBuilder.custom(
      catalog: catalog,
      allowedOperations: SurfaceOperations.createAndUpdate(dataModel: false),
      systemPromptFragments: [systemInstruction],
    ).systemPromptJoined();
    _model = FirebaseAI.googleAI().generativeModel(
      model: GeminiRemoteDataSource.defaultModelName,
      systemInstruction: Content.system(prompt),
    );
    transport = A2uiTransportAdapter(onSend: _sendToGemini);
    conversation = Conversation(controller: controller, transport: transport);
  }

  late final SurfaceController controller;
  late final Conversation conversation;
  late final A2uiTransportAdapter transport;
  late final GenerativeModel _model;

  @override
  SurfaceHost get host => controller;

  @override
  Stream<ConversationEvent> get events => conversation.events;

  @override
  Future<void> sendText(String prompt) =>
      conversation.sendRequest(ChatMessage.user(prompt));

  /// Converts the outgoing `ChatMessage` to a `firebase_ai` `Content` and
  /// streams the model's response chunks into the transport.
  ///
  /// `ChatMessage` has a `.text` getter (the concatenation of its
  /// `TextPart`s — see `genai_primitives`' `chat_message.dart`), so no
  /// custom part-by-part converter is needed here.
  Future<void> _sendToGemini(ChatMessage message) async {
    _log.i('Wizard session calling Gemini (${message.text.length} chars sent)');
    try {
      var totalChars = 0;
      await for (final chunk in _model.generateContentStream([
        Content.text(message.text),
      ])) {
        if (chunk.text case final text?) {
          totalChars += text.length;
          transport.addChunk(text);
        }
      }
      _log.i('Wizard session Gemini stream complete ($totalChars total chars)');
    } catch (e, st) {
      _log.e('Wizard session Gemini call failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  void dispose() {
    conversation.dispose();
    transport.dispose();
    controller.dispose();
  }
}
