import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A single step in the onboarding tutorial carousel (UX doc Screen 4).
@immutable
class TutorialStep {
  const TutorialStep({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// Visual card for one [TutorialStep] — simple, high-contrast, large icon
/// per the UX doc's "minimal cognitive load" / "maximum icons" principles.
class TutorialStepCard extends StatelessWidget {
  const TutorialStepCard({required this.step, super.key});

  final TutorialStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: step.text,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.secondary, width: 3),
              ),
            ),
            child: Icon(step.icon, size: 72, color: AppColors.primary),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              step.text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
