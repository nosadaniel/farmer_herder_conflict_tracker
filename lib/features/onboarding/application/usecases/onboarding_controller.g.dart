// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks whether the user has completed onboarding before, backed by the
/// shared Drift `Cache` table (read-only dependency on
/// `appDatabaseProvider` — this track does not own `core/database`).
///
/// [build] resolves to `true`/`false` based on the persisted flag. If the
/// cache read fails for any reason (fresh install, storage error, etc.) it
/// fails open to `false` so onboarding is shown rather than the app getting
/// stuck.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Tracks whether the user has completed onboarding before, backed by the
/// shared Drift `Cache` table (read-only dependency on
/// `appDatabaseProvider` — this track does not own `core/database`).
///
/// [build] resolves to `true`/`false` based on the persisted flag. If the
/// cache read fails for any reason (fresh install, storage error, etc.) it
/// fails open to `false` so onboarding is shown rather than the app getting
/// stuck.
final class OnboardingControllerProvider
    extends $AsyncNotifierProvider<OnboardingController, bool> {
  /// Tracks whether the user has completed onboarding before, backed by the
  /// shared Drift `Cache` table (read-only dependency on
  /// `appDatabaseProvider` — this track does not own `core/database`).
  ///
  /// [build] resolves to `true`/`false` based on the persisted flag. If the
  /// cache read fails for any reason (fresh install, storage error, etc.) it
  /// fails open to `false` so onboarding is shown rather than the app getting
  /// stuck.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();
}

String _$onboardingControllerHash() =>
    r'e10e90ac82e8f530d860b76a44c3cc89d542c675';

/// Tracks whether the user has completed onboarding before, backed by the
/// shared Drift `Cache` table (read-only dependency on
/// `appDatabaseProvider` — this track does not own `core/database`).
///
/// [build] resolves to `true`/`false` based on the persisted flag. If the
/// cache read fails for any reason (fresh install, storage error, etc.) it
/// fails open to `false` so onboarding is shown rather than the app getting
/// stuck.

abstract class _$OnboardingController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
