import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/onboarding/application/usecases/onboarding_controller.dart';
import '../../features/onboarding/presentation/pages/tutorial_screen.dart';
import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/report_wizard/presentation/pages/report_wizard_screen.dart';
import '../main_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

/// The app's [GoRouter] — a single, stable instance for the app's lifetime,
/// gated by [onboardingControllerProvider] via `refreshListenable` (not by
/// watching the provider to rebuild the router object itself — see the
/// correction note below). No local "which screen" state anywhere; [redirect]
/// bounces the user to the right place whenever the location or the
/// onboarding flag changes.
///
/// **Correction (found via on-device testing, task.md Phase 5)**: this used
/// to `ref.watch(onboardingControllerProvider)` and construct a brand-new
/// `GoRouter(...)` on every change. That's wrong: `MaterialApp.router`
/// tears down and remounts its entire `Navigator`/routed widget subtree
/// whenever `routerConfig`'s object identity changes, which unmounts
/// whatever screen just called `onboardingControllerProvider.notifier
/// .complete()` *before* that screen's own follow-up `context.go(...)` call
/// can run — so an explicit post-onboarding navigation (e.g. to
/// [ReportWizardRoute]) silently never happens; the new router's own
/// `redirect` pass (evaluated against its `initialLocation`, not wherever
/// the explicit call wanted to go) is the only thing that ends up
/// navigating anywhere. This was invisible for [_completeOnboardingAndGoHome]
/// only because its destination (Home) happens to be the *same* place
/// `redirect` lands anyway for an onboarded user at `initialLocation`.
/// `refreshListenable` is go_router's documented fix for exactly this: one
/// router instance for the app's lifetime, whose `redirect` re-runs (for
/// whatever location the app is *currently* at, not a fresh
/// `initialLocation`) each time the listenable fires — so the Navigator and
/// every screen's `BuildContext` stay mounted across an onboarding-complete
/// event, and an explicit `context.go(...)` issued right after always wins
/// as the final word.
///
/// Route tree (see app_routes.dart for the path-naming rationale):
/// - `/` -> [MainScreen] ([HomeRoute])
/// - `/onboarding` -> [WelcomeScreen] ([OnboardingWelcomeRoute])
/// - `/onboarding/tutorial` -> [TutorialScreen] ([OnboardingTutorialRoute])
/// - `/report` -> [ReportWizardScreen] ([ReportWizardRoute]) — the Guided
///   Report Wizard (task.md Phase 5), reached from onboarding's final "Get
///   Started" and from [HomeRoute]'s "Report" CTA alike.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Pings go_router to re-run `redirect` without touching the router
  // object's identity — see the correction note above. `ref.listen` (not
  // `ref.watch`) so this provider function itself never reruns, i.e. the
  // `GoRouter(...)` below is constructed exactly once.
  final refreshNotifier = ValueNotifier(0);
  ref.listen(onboardingControllerProvider, (previous, next) {
    refreshNotifier.value++;
  });
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: OnboardingWelcomeRoute.path,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final onboarded = ref.read(onboardingControllerProvider).value;
      // Still loading the persisted flag — don't redirect yet, whatever
      // initialLocation resolved to is shown as-is (imperceptibly brief:
      // this is a single Drift row read).
      if (onboarded == null) return null;

      final isOnboardingPath = state.matchedLocation.startsWith(
        OnboardingWelcomeRoute.path,
      );
      if (!onboarded && !isOnboardingPath) return OnboardingWelcomeRoute.path;
      if (onboarded && isOnboardingPath) return HomeRoute.path;
      return null;
    },
    routes: [
      GoRoute(
        path: HomeRoute.path,
        name: HomeRoute.name,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: OnboardingWelcomeRoute.path,
        name: OnboardingWelcomeRoute.name,
        builder: (context, state) => WelcomeScreen(
          onStart: () => OnboardingTutorialRoute.go(context),
          onSkip: () => _completeOnboardingAndGoHome(context, ref),
        ),
      ),
      GoRoute(
        path: OnboardingTutorialRoute.path,
        name: OnboardingTutorialRoute.name,
        builder: (context, state) => TutorialScreen(
          // Per docs/report_wizard_ux_flow.md: onboarding ends by dropping
          // the user straight into the wizard for their first report, not
          // home — Skip (above) still goes home since that's an explicit
          // "no tour" opt-out, not an ask to report immediately.
          onGetStarted: () => _completeOnboardingAndGoToWizard(context, ref),
        ),
      ),
      GoRoute(
        path: ReportWizardRoute.path,
        name: ReportWizardRoute.name,
        builder: (context, state) =>
            ReportWizardScreen(onExit: () => HomeRoute.go(context)),
      ),
    ],
  );
}

/// Persists onboarding completion (best-effort — a failed cache write
/// should never trap the user on the onboarding screens, matching the
/// original OnboardingFlow's behavior) then navigates home. Safe to call
/// `context.go(...)` directly right after `complete()`: [appRouter]'s
/// `refreshListenable` setup keeps the Navigator/this screen's `context`
/// mounted across the onboarding-complete event (see that provider's doc
/// comment), so there's no teardown race to defer around.
Future<void> _completeOnboardingAndGoHome(BuildContext context, Ref ref) async {
  try {
    await ref.read(onboardingControllerProvider.notifier).complete();
  } catch (_) {
    // Best-effort only.
  }
  if (context.mounted) HomeRoute.go(context);
}

/// Same best-effort completion as [_completeOnboardingAndGoHome], but for
/// the "Get Started" exit which per the UX doc goes straight into the
/// wizard for the user's first report rather than to the (now report-less)
/// home map screen.
Future<void> _completeOnboardingAndGoToWizard(
  BuildContext context,
  Ref ref,
) async {
  try {
    await ref.read(onboardingControllerProvider.notifier).complete();
  } catch (_) {
    // Best-effort only.
  }
  if (context.mounted) ReportWizardRoute.go(context);
}
