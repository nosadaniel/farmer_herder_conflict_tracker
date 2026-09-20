import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Type-safe route definitions for the app — one class per screen, each
/// carrying its own `path`/`name` and a `go(context)` helper, so navigation
/// call sites read `HomeRoute.go(context)` instead of `context.go('/')`:
/// no magic strings, typos become compile errors, and every route is
/// centrally discoverable here.
///
/// go_router's official type-safe routing (`GoRouteData` + `TypedGoRoute` +
/// `go_router_builder` codegen) is the more ceremonial version of this same
/// idea; this hand-written form gets the same practical benefit (typed,
/// centralized, refactor-safe route references) without an extra codegen
/// dependency, which is the right tradeoff for the size of this app — none
/// of our routes take path parameters.
///
/// Path naming strategy: nested paths mirror the onboarding flow's actual
/// screen sequence (`/onboarding` -> `/onboarding/permissions` ->
/// `/onboarding/tutorial`), so the URL structure documents the flow.
abstract final class HomeRoute {
  static const String path = '/';
  static const String name = 'home';

  static void go(BuildContext context) => context.go(path);
}

abstract final class OnboardingWelcomeRoute {
  static const String path = '/onboarding';
  static const String name = 'onboardingWelcome';

  static void go(BuildContext context) => context.go(path);
}

abstract final class OnboardingPermissionsRoute {
  static const String path = '/onboarding/permissions';
  static const String name = 'onboardingPermissions';

  static void go(BuildContext context) => context.go(path);
}

abstract final class OnboardingTutorialRoute {
  static const String path = '/onboarding/tutorial';
  static const String name = 'onboardingTutorial';

  static void go(BuildContext context) => context.go(path);
}
