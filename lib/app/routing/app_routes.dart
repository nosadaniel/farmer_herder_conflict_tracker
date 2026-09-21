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
/// screen sequence (`/onboarding` -> `/onboarding/tutorial`), so the URL
/// structure documents the flow. `/report` (the Guided Report Wizard,
/// task.md Phase 5) is top-level rather than nested under onboarding since
/// it's reachable from both onboarding's end and [HomeRoute] alike.
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

abstract final class OnboardingTutorialRoute {
  static const String path = '/onboarding/tutorial';
  static const String name = 'onboardingTutorial';

  static void go(BuildContext context) => context.go(path);
}

/// The Guided Report Wizard (task.md Phase 5) — the app's single reporting
/// mechanism, replacing the old persistent mic/keyboard footer. Reached both
/// from onboarding's final "Get Started" (first-ever report) and from
/// [HomeRoute]'s "Report" CTA (every report after that).
abstract final class ReportWizardRoute {
  static const String path = '/report';
  static const String name = 'reportWizard';

  static void go(BuildContext context) => context.go(path);
}
