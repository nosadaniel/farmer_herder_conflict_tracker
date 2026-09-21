// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_wizard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReportWizardController)
final reportWizardControllerProvider = ReportWizardControllerProvider._();

final class ReportWizardControllerProvider
    extends $NotifierProvider<ReportWizardController, ReportWizardState> {
  ReportWizardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportWizardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportWizardControllerHash();

  @$internal
  @override
  ReportWizardController create() => ReportWizardController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportWizardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportWizardState>(value),
    );
  }
}

String _$reportWizardControllerHash() =>
    r'9b11bd4cc345f4cb1bed20484348a1149359ee56';

abstract class _$ReportWizardController extends $Notifier<ReportWizardState> {
  ReportWizardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReportWizardState, ReportWizardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportWizardState, ReportWizardState>,
              ReportWizardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
