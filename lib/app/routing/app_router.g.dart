// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter], gated entirely by [onboardingControllerProvider] —
/// no local "which screen" state anywhere. Watching that provider here
/// means this provider (and therefore the router) rebuilds the moment
/// onboarding completes, and [redirect] below bounces the user to the
/// right place.
///
/// Route tree (see app_routes.dart for the path-naming rationale):
/// - `/` -> [MainScreen] ([HomeRoute])
/// - `/onboarding` -> [WelcomeScreen] ([OnboardingWelcomeRoute])
/// - `/onboarding/tutorial` -> [TutorialScreen] ([OnboardingTutorialRoute])
/// - `/report` -> [ReportWizardScreen] ([ReportWizardRoute]) — the Guided
///   Report Wizard (task.md Phase 5), reached from onboarding's final "Get
///   Started" and from [HomeRoute]'s "Report" CTA alike.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's [GoRouter], gated entirely by [onboardingControllerProvider] —
/// no local "which screen" state anywhere. Watching that provider here
/// means this provider (and therefore the router) rebuilds the moment
/// onboarding completes, and [redirect] below bounces the user to the
/// right place.
///
/// Route tree (see app_routes.dart for the path-naming rationale):
/// - `/` -> [MainScreen] ([HomeRoute])
/// - `/onboarding` -> [WelcomeScreen] ([OnboardingWelcomeRoute])
/// - `/onboarding/tutorial` -> [TutorialScreen] ([OnboardingTutorialRoute])
/// - `/report` -> [ReportWizardScreen] ([ReportWizardRoute]) — the Guided
///   Report Wizard (task.md Phase 5), reached from onboarding's final "Get
///   Started" and from [HomeRoute]'s "Report" CTA alike.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter], gated entirely by [onboardingControllerProvider] —
  /// no local "which screen" state anywhere. Watching that provider here
  /// means this provider (and therefore the router) rebuilds the moment
  /// onboarding completes, and [redirect] below bounces the user to the
  /// right place.
  ///
  /// Route tree (see app_routes.dart for the path-naming rationale):
  /// - `/` -> [MainScreen] ([HomeRoute])
  /// - `/onboarding` -> [WelcomeScreen] ([OnboardingWelcomeRoute])
  /// - `/onboarding/tutorial` -> [TutorialScreen] ([OnboardingTutorialRoute])
  /// - `/report` -> [ReportWizardScreen] ([ReportWizardRoute]) — the Guided
  ///   Report Wizard (task.md Phase 5), reached from onboarding's final "Get
  ///   Started" and from [HomeRoute]'s "Report" CTA alike.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'73b4db0c41ab4f1a62d81e8361265ec62e83a41e';
