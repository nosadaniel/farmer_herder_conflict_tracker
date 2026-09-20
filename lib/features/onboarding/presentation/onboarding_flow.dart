import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/usecases/onboarding_controller.dart';
import 'pages/permissions_screen.dart';
import 'pages/tutorial_screen.dart';
import 'pages/welcome_screen.dart';

enum _OnboardingStep { welcome, permissions, tutorial }

/// Single entry point for Track E's onboarding flow: Welcome -> Permissions
/// -> Tutorial (UX doc Screens 2-4), per task.md's Track E deliverables.
///
/// Intended to be dropped in front of the main app shell by a later
/// integration step (this track does not touch `lib/main.dart`). Usage:
///
/// ```dart
/// OnboardingFlow(onComplete: () => /* navigate to AppShell */)
/// ```
///
/// [OnboardingFlow] checks the persisted "has completed onboarding" flag
/// itself (see [OnboardingController]) and, if already set, calls
/// [onComplete] immediately without rendering any screens — so a caller can
/// unconditionally mount this widget on every cold start and it will only
/// actually show onboarding to first-time users.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({required this.onComplete, super.key});

  /// Invoked once onboarding is finished — either because the user
  /// completed/skipped it just now, or because it was already completed on
  /// a previous run.
  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  _OnboardingStep _step = _OnboardingStep.welcome;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkExistingStatus();
  }

  Future<void> _checkExistingStatus() async {
    var hasOnboarded = false;
    try {
      hasOnboarded = await ref.read(onboardingControllerProvider.future);
    } catch (_) {
      // Fail open: if the cache read fails, just show onboarding rather
      // than getting stuck on a blank screen.
      hasOnboarded = false;
    }
    if (!mounted) return;
    if (hasOnboarded) {
      widget.onComplete();
      return;
    }
    setState(() => _checkingStatus = false);
  }

  Future<void> _finishOnboarding() async {
    try {
      await ref.read(onboardingControllerProvider.notifier).complete();
    } catch (_) {
      // Best-effort persistence only — a failed cache write should never
      // trap the user on the onboarding screens.
    }
    widget.onComplete();
  }

  void _goTo(_OnboardingStep step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    if (_checkingStatus) {
      return const _OnboardingLoadingGate();
    }

    switch (_step) {
      case _OnboardingStep.welcome:
        return WelcomeScreen(
          onStart: () => _goTo(_OnboardingStep.permissions),
          onSkip: _finishOnboarding,
        );
      case _OnboardingStep.permissions:
        return PermissionsScreen(
          onContinue: () => _goTo(_OnboardingStep.tutorial),
        );
      case _OnboardingStep.tutorial:
        return TutorialScreen(onGetStarted: _finishOnboarding);
    }
  }
}

class _OnboardingLoadingGate extends StatelessWidget {
  const _OnboardingLoadingGate();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
