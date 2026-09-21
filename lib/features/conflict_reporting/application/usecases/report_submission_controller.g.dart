// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_submission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReportSubmissionController)
final reportSubmissionControllerProvider =
    ReportSubmissionControllerProvider._();

final class ReportSubmissionControllerProvider
    extends
        $NotifierProvider<ReportSubmissionController, ReportSubmissionState> {
  ReportSubmissionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportSubmissionControllerProvider',
        isAutoDispose: false,
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
    r'c2b42cb7c5944fb0a50b7afebe9418d73a7b6ecc';

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
