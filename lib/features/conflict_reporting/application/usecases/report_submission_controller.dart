import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../map/application/providers/map_providers.dart';
import '../../../map/domain/entities/app_location.dart';
import '../../data/datasources/remote/gemini_remote_datasource.dart';
import '../../data/repositories/cache_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../presentation/a2ui/providers/a2ui_providers.dart';
import 'rehydrate_from_cache.dart';
import 'submit_report.dart';

part 'report_submission_controller.g.dart';

/// UI-facing state for the report-submission pipeline (task.md Phase 2).
///
/// Deliberately does NOT include a "recording" state — [MicrophoneButton]
/// owns its own recording UI/`AudioRecorder` locally (a UI-owned hardware
/// controller, per task.md's refined Riverpod rule: such controllers stay
/// in widget `State` for dispose-lifecycle safety) and only calls into this
/// controller once bytes are ready.
sealed class ReportSubmissionState {
  const ReportSubmissionState();
}

class ReportIdle extends ReportSubmissionState {
  const ReportIdle();
}

class ReportProcessing extends ReportSubmissionState {
  const ReportProcessing();
}

class ReportFailed extends ReportSubmissionState {
  const ReportFailed(this.message);
  final String message;
}

/// Orchestrates the end-to-end report-submission flow: GPS -> nearby
/// historical conflicts -> Firebase AI (via [SubmitReport]) -> A2UI
/// blueprint streamed into genui's transport -> cached for offline
/// rehydration.
///
/// Both [submitVoice]/[submitText] (called directly by the mic button /
/// text modal) and [handleActionFollowUp] (called by the real
/// `a2uiSendHandlerProvider` implementation for button-tap follow-ups, see
/// lib/app/wiring/gemini_send_handler.dart) funnel through [_run].
final _log = Logger();

@Riverpod(keepAlive: true)
class ReportSubmissionController extends _$ReportSubmissionController {
  GeminiRemoteDataSource? _gemini;

  @override
  ReportSubmissionState build() => const ReportIdle();

  GeminiRemoteDataSource get _geminiDataSource =>
      _gemini ??= GeminiRemoteDataSource.production();

  Future<void> submitVoice(Uint8List audioBytes) =>
      _run(audioBytes: audioBytes);

  Future<void> submitText(String text) => _run(reportText: text);

  /// Called for button-tap follow-ups (every reserved action except
  /// `share_alert`, which is intercepted before it ever reaches here — see
  /// docs/a2ui_gemini_contract.md §7).
  Future<void> handleActionFollowUp(
    String actionName,
    Map<String, dynamic> actionContext,
  ) => _run(actionEventName: actionName, actionContext: actionContext);

  Future<void> _run({
    Uint8List? audioBytes,
    String? reportText,
    String? actionEventName,
    Map<String, dynamic>? actionContext,
  }) async {
    state = const ReportProcessing();
    _log.i(
      'ReportSubmissionController._run start '
      '(audio=${audioBytes != null}, text=${reportText != null}, '
      'action=$actionEventName)',
    );
    try {
      final location = await ref.read(currentLocationProvider.future);
      final (lat, lng) = switch (location) {
        AppLocationKnown(:final latitude, :final longitude) => (
          latitude,
          longitude,
        ),
        AppLocationUnknown() => (9.0, 8.5), // Middle Belt fallback centroid
      };
      _log.i('Resolved location: $location -> ($lat, $lng)');

      final params = SubmitReportParams(
        lat: lat,
        lng: lng,
        audioBytes: audioBytes,
        reportText: reportText,
        actionEventName: actionEventName,
        actionContext: actionContext,
        getNearbyConflicts: _nearbyConflictsAsMaps,
      );

      final submit = SubmitReport(geminiDataSource: _geminiDataSource);
      final transport = ref.read(a2uiTransportProvider);
      final buffer = StringBuffer();

      _log.i('Calling Gemini...');
      await for (final chunk in submit(params)) {
        _log.d('Gemini chunk (${chunk.length} chars): $chunk');
        buffer.write(chunk);
        transport.addChunk(chunk);
      }
      _log.i('Gemini stream complete, ${buffer.length} total chars');

      final fullBlueprint = buffer.toString();
      if (fullBlueprint.trim().isNotEmpty) {
        await ref
            .read(cacheRepositoryProvider)
            .saveBlueprint(
              AppConstants.lastBlueprintCacheKey,
              fullBlueprint,
              const Duration(days: 7),
            );
        if (reportText != null || audioBytes != null) {
          await ref
              .read(reportRepositoryProvider)
              .saveReport(
                latitude: lat,
                longitude: lng,
                transcription: reportText ?? '(voice report)',
                riskLevel: 'unknown',
                a2uiBlueprint: fullBlueprint,
              );
        }
      }

      state = const ReportIdle();
    } catch (e, st) {
      // Live call failed (offline, timeout, Firebase AI error, etc.) — fall
      // back to whatever was last cached (task.md non-negotiable #6).
      _log.e('Live submission failed, attempting cache fallback', error: e, stackTrace: st);
      try {
        final rehydrated = await rehydrateFromCache(
          ref.read(a2uiSurfaceControllerProvider),
          ref.read(cacheRepositoryProvider),
        );
        if (rehydrated) {
          state = const ReportIdle(); // recovered via cache, not an error
          _log.i('Recovered via cached blueprint');
        } else {
          _log.e('No cache to fall back to either');
          state = ReportFailed(e.toString());
        }
      } catch (cacheError) {
        _log.e('Cache fallback itself failed', error: cacheError);
        state = ReportFailed(e.toString());
      }
    }
  }

  Future<List<Map<String, dynamic>>> _nearbyConflictsAsMaps(
    double lat,
    double lng,
  ) async {
    final usecase = ref.read(getNearbyConflictsUsecaseProvider);
    final conflicts = await usecase(lat: lat, lng: lng);
    const distance = Distance();
    final origin = LatLng(lat, lng);
    return conflicts
        .map(
          (c) => <String, dynamic>{
            'distanceKm': distance
                .as(
                  LengthUnit.Kilometer,
                  origin,
                  LatLng(c.latitude, c.longitude),
                )
                .round(),
            'date': c.date.toIso8601String().split('T').first,
            'severity': c.severity,
            'fatalities': c.fatalities,
            'type': c.type,
          },
        )
        .toList();
  }
}
