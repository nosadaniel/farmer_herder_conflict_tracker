// ignore_for_file: prefer_initializing_formals
//
// Public param names intentionally differ from the private field names they
// initialize so this constructor stays callable with named arguments from
// other libraries (tests) — see submit_report.dart for the full rationale.
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:genui/genui.dart';

import '../../../../../core/errors/exceptions.dart';
import 'conflict_tracker_prompt.dart';
import 'gemini_model_client.dart';

/// Firebase AI (Gemini) integration for the conflict-reporting pipeline, per
/// `docs/a2ui_gemini_contract.md` §4. This is a two-step flow:
///
/// 1. [transcribeAudio] — a lightweight, transcription-only call used for
///    voice reports ("transcribe exactly what is said, output only the
///    transcript"). Kept as its own call (not bundled with UI generation) so
///    transcription and UI-generation stay independently testable.
/// 2. [generateSurfaceStream] — the full system-prompted A2UI-generation
///    call. The system instruction is built via `PromptBuilder.chat()`
///    (from `genui`) using `BasicCatalogItems.asNoAssetCatalog()` as the
///    catalog plus [conflictTrackerPromptFragment] (contract doc §3,
///    verbatim) as the domain-specific fragment. The response is streamed
///    back to the caller exactly as Gemini emits it (fenced ```json blocks).
///
/// Text input skips step 1 entirely and goes straight to step 2 (handled by
/// the `submit_report` usecase, not here).
class GeminiRemoteDataSource {
  GeminiRemoteDataSource({
    required GeminiModelClient transcriptionClient,
    required GeminiModelClient surfaceClient,
  }) : _transcriptionClient = transcriptionClient,
       _surfaceClient = surfaceClient;

  /// Builds a production instance backed by real `firebase_ai` Gemini
  /// models via the Gemini Developer API (`FirebaseAI.googleAI()` — the
  /// entrypoint that uses the Gemini Developer API, already enabled per
  /// task.md's Firebase setup notes).
  factory GeminiRemoteDataSource.production({
    String modelName = defaultModelName,
  }) {
    final ai = FirebaseAI.googleAI();

    final transcriptionModel = ai.generativeModel(
      model: modelName,
      systemInstruction: Content.system(_transcriptionInstruction),
    );

    final catalog = BasicCatalogItems.asNoAssetCatalog(
      systemPromptFragments: [conflictTrackerPromptFragment],
    );
    final promptBuilder = PromptBuilder.chat(catalog: catalog);
    final surfaceModel = ai.generativeModel(
      model: modelName,
      systemInstruction: Content.system(promptBuilder.systemPromptJoined()),
    );

    return GeminiRemoteDataSource(
      transcriptionClient: FirebaseGeminiModelClient(transcriptionModel),
      surfaceClient: FirebaseGeminiModelClient(surfaceModel),
    );
  }

  /// Default Gemini model used for both steps. `gemini-2.5-flash` (the
  /// brainstorm docs' original choice) is deprecated for new projects as of
  /// live device testing — Firebase AI's own error response pointed at
  /// `gemini-3.6-flash` as the replacement, confirmed working. Override via
  /// the constructor if a track lead wants a different one.
  static const String defaultModelName = 'gemini-3.6-flash';

  static const String _transcriptionInstruction =
      'Transcribe exactly what is said in the provided audio. '
      'Output only the transcript text, verbatim — no preamble, no '
      'commentary, no formatting, no speaker labels. If the audio is '
      'silent or unintelligible, output an empty string.';

  final GeminiModelClient _transcriptionClient;
  final GeminiModelClient _surfaceClient;

  /// Step 1 of the two-step voice flow (contract §4).
  ///
  /// [mimeType] must be one of `FirebaseAIMimeTypes.audio`; the `record`
  /// package's default AAC/`.m4a` output maps to `'audio/m4a'`.
  Future<String> transcribeAudio(
    Uint8List audioBytes, {
    String mimeType = 'audio/m4a',
  }) async {
    try {
      final transcript = await _transcriptionClient.generateContent([
        Content.multi([InlineDataPart(mimeType, audioBytes)]),
      ]);
      final trimmed = transcript.trim();
      if (trimmed.isEmpty) {
        throw const TranscriptionException(
          'Gemini returned an empty transcript',
        );
      }
      return trimmed;
    } on TranscriptionException {
      rethrow;
    } catch (e) {
      throw TranscriptionException('Voice transcription failed: $e');
    }
  }

  /// Step 2 (contract §4): the full system-prompted A2UI-generation call,
  /// streamed. [contextBlock] is the per-turn text built by
  /// `ConflictContextBuilder` (location + report/event + nearby historical
  /// conflicts + surfaceId) and is sent as the sole user message — Gemini's
  /// system instruction (set at model-construction time, see
  /// [GeminiRemoteDataSource.production]) already carries the full A2UI
  /// protocol + catalog + domain prompt.
  Stream<String> generateSurfaceStream(String contextBlock) {
    return _surfaceClient.generateContentStream([Content.text(contextBlock)]);
  }
}
