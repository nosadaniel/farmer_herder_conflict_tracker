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
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final onboardedAsync = ref.watch(onboardingControllerProvider);

  return GoRouter(
    initialLocation: OnboardingWelcomeRoute.path,
    redirect: (context, state) {
      final onboarded = onboardedAsync.value;
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
        builder: (context, state) => const ReportWizardScreen(),
      ),
    ],
  );
}

/// Persists onboarding completion (best-effort — a failed cache write
/// should never trap the user on the onboarding screens, matching the
/// original OnboardingFlow's behavior) then navigates home.
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
