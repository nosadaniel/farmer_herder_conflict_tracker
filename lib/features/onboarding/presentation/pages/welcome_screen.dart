import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Onboarding Screen 2 (UX doc): large friendly headline, prominent "Start"
/// button, small "Skip" in the top-right. Cultural relevance / community
/// trust tone — warm, simple, icon-led (low-literacy friendly).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.onStart, required this.onSkip, super.key});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                // 48x48dp minimum touch target comes from AppTheme's
                // textButtonTheme — no per-call override needed.
                child: TextButton(onPressed: onSkip, child: const Text('Skip')),
              ),
              const Spacer(),
              const Icon(
                Icons.handshake_rounded,
                size: 108,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Conflict Tracker',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Protect your community, report threats',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    // White text on AppColors.secondary measures ~4.4:1,
                    // just under the UX doc's 4.5:1 minimum — black text
                    // on this green clears ~4.8:1, so use that instead of
                    // touching the shared palette color itself (other
                    // tracks depend on that exact hex for risk-state UI).
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Start'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
