// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_submission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrates the end-to-end report-submission flow: GPS -> nearby
/// historical conflicts -> Firebase AI (via [SubmitReport]) -> A2UI
/// blueprint streamed into genui's transport -> cached for offline
/// rehydration.
///
/// Both [submitVoice]/[submitText] (called directly by the mic button /
/// text modal) and [handleActionFollowUp] (called by the real
/// `a2uiSendHandlerProvider` implementation for button-tap follow-ups, see
/// lib/app/wiring/gemini_send_handler.dart) funnel through [_run].

@ProviderFor(ReportSubmissionController)
final reportSubmissionControllerProvider =
    ReportSubmissionControllerProvider._();

/// Orchestrates the end-to-end report-submission flow: GPS -> nearby
/// historical conflicts -> Firebase AI (via [SubmitReport]) -> A2UI
/// blueprint streamed into genui's transport -> cached for offline
/// rehydration.
///
/// Both [submitVoice]/[submitText] (called directly by the mic button /
/// text modal) and [handleActionFollowUp] (called by the real
/// `a2uiSendHandlerProvider` implementation for button-tap follow-ups, see
/// lib/app/wiring/gemini_send_handler.dart) funnel through [_run].
final class ReportSubmissionControllerProvider
    extends
        $NotifierProvider<ReportSubmissionController, ReportSubmissionState> {
  /// Orchestrates the end-to-end report-submission flow: GPS -> nearby
  /// historical conflicts -> Firebase AI (via [SubmitReport]) -> A2UI
  /// blueprint streamed into genui's transport -> cached for offline
  /// rehydration.
  ///
  /// Both [submitVoice]/[submitText] (called directly by the mic button /
  /// text modal) and [handleActionFollowUp] (called by the real
  /// `a2uiSendHandlerProvider` implementation for button-tap follow-ups, see
  /// lib/app/wiring/gemini_send_handler.dart) funnel through [_run].
  ReportSubmissionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportSubmissionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportSubmissionControllerHash();

  @$internal
  @override
  ReportSubmissionController create() => ReportSubmissionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportSubmissionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportSubmissionState>(value),
    );
  }
}

String _$reportSubmissionControllerHash() =>
    r'5a2133262b0175210fcf09bee8cdf16cdcad962e';

/// Orchestrates the end-to-end report-submission flow: GPS -> nearby
/// historical conflicts -> Firebase AI (via [SubmitReport]) -> A2UI
/// blueprint streamed into genui's transport -> cached for offline
/// rehydration.
///
/// Both [submitVoice]/[submitText] (called directly by the mic button /
/// text modal) and [handleActionFollowUp] (called by the real
/// `a2uiSendHandlerProvider` implementation for button-tap follow-ups, see
/// lib/app/wiring/gemini_send_handler.dart) funnel through [_run].

abstract class _$ReportSubmissionController
    extends $Notifier<ReportSubmissionState> {
  ReportSubmissionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReportSubmissionState, ReportSubmissionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportSubmissionState, ReportSubmissionState>,
              ReportSubmissionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
