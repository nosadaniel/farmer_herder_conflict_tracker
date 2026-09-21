// ignore_for_file: prefer_initializing_formals
//
// Public param names intentionally differ from the private field names they
// initialize (e.g. geminiDataSource -> _geminiDataSource) so constructors
// stay callable with named arguments from other libraries (tests) — a
// same-named `this._geminiDataSource` initializing formal would make the
// parameter's external label private too, which this lint doesn't account
// for.
import 'dart:typed_data';

import '../../data/datasources/remote/conflict_context_builder.dart';
import '../../data/datasources/remote/gemini_remote_datasource.dart';

/// Input for [SubmitReport.call].
///
/// Exactly one of [audioBytes], [reportText], [actionEventName], or
/// [wizardAnswers] must be provided:
/// - [audioBytes] set → voice mode: transcribed first (contract §4 step 1),
///   then the transcript is used as the report text.
/// - [reportText] set (and [audioBytes] null) → text mode: skips
///   transcription entirely (PRD Flow 3 — "same downstream pipeline, no
///   transcription needed").
/// - [actionEventName] set → button-tap follow-up from a previously
///   rendered A2UI surface; [actionContext] carries the event's payload.
/// - [wizardAnswers] set → guided Report Wizard mode: structured answers
///   instead of freeform voice/text, assembled by
///   [ConflictContextBuilder.build] into the same `Report:` line shape.
class SubmitReportParams {
  const SubmitReportParams({
    required this.lat,
    required this.lng,
    required this.getNearbyConflicts,
    this.placeName,
    this.audioBytes,
    this.audioMimeType = 'audio/m4a',
    this.reportText,
    this.actionEventName,
    this.actionContext,
    this.wizardAnswers,
  }) : assert(
         (audioBytes != null ? 1 : 0) +
                 (reportText != null ? 1 : 0) +
                 (actionEventName != null ? 1 : 0) +
                 (wizardAnswers != null ? 1 : 0) ==
             1,
         'Provide exactly one of audioBytes, reportText, actionEventName, '
         'or wizardAnswers',
       );

  final double lat;
  final double lng;
  final String? placeName;

  /// Recorded voice-report audio (voice mode). When set, [reportText],
  /// [actionEventName], and [wizardAnswers] must be null.
  final Uint8List? audioBytes;
  final String audioMimeType;

  /// Typed text report (text mode, skips transcription). When set,
  /// [audioBytes], [actionEventName], and [wizardAnswers] must be null.
  final String? reportText;

  /// Button-tap follow-up event name from a previously rendered surface.
  /// When set, [audioBytes], [reportText], and [wizardAnswers] must be null.
  final String? actionEventName;
  final Map<String, dynamic>? actionContext;

  /// Structured answers from the guided Report Wizard
  /// (`whatsHappening`/`whoInvolved`/`detailText`, any subset). When set,
  /// [audioBytes], [reportText], and [actionEventName] must be null. See
  /// [ConflictContextBuilder.build]'s `wizardAnswers` doc for the expected
  /// keys.
  final Map<String, String>? wizardAnswers;

  /// Injected lookup for nearby historical conflicts — see
  /// [ConflictContextBuilder.build] for the expected map shape. Owned by a
  /// different track (map/conflict-data); this usecase never imports that
  /// implementation directly.
  final Future<List<Map<String, dynamic>>> Function(double lat, double lng)
  getNearbyConflicts;
}

/// Orchestrates one full report-submission turn, per
/// `docs/a2ui_gemini_contract.md` §4:
///
/// 1. Transcribe (voice mode only) — [GeminiRemoteDataSource.transcribeAudio].
/// 2. Build the per-turn context block — [ConflictContextBuilder.build].
/// 3. Call Gemini with the full system prompt, streaming —
///    [GeminiRemoteDataSource.generateSurfaceStream].
///
/// The returned `Stream<String>` is exactly the raw text Gemini streamed
/// back (fenced ` ```json ` blocks per the contract's worked example,
/// §6) — this is the documented interface point for the A2UI-rendering
/// track (Track C) to consume; this usecase does no parsing of it.
class SubmitReport {
  SubmitReport({
    required GeminiRemoteDataSource geminiDataSource,
    ConflictContextBuilder contextBuilder = const ConflictContextBuilder(),
    String Function()? surfaceIdGenerator,
  }) : _geminiDataSource = geminiDataSource,
       _contextBuilder = contextBuilder,
       _surfaceIdGenerator = surfaceIdGenerator ?? _defaultSurfaceIdGenerator;

  final GeminiRemoteDataSource _geminiDataSource;
  final ConflictContextBuilder _contextBuilder;
  final String Function() _surfaceIdGenerator;

  static String _defaultSurfaceIdGenerator() =>
      'report_${DateTime.now().millisecondsSinceEpoch}';

  Stream<String> call(SubmitReportParams params) async* {
    String? reportText = params.reportText;

    if (params.audioBytes != null) {
      reportText = await _geminiDataSource.transcribeAudio(
        params.audioBytes!,
        mimeType: params.audioMimeType,
      );
    }

    final surfaceId = _surfaceIdGenerator();

    final contextBlock = await _contextBuilder.build(
      lat: params.lat,
      lng: params.lng,
      surfaceId: surfaceId,
      placeName: params.placeName,
      reportText: params.actionEventName == null ? reportText : null,
      actionEventName: params.actionEventName,
      actionContext: params.actionContext,
      wizardAnswers: params.wizardAnswers,
      getNearbyConflicts: params.getNearbyConflicts,
    );

    yield* _geminiDataSource.generateSurfaceStream(contextBlock);
  }
}
