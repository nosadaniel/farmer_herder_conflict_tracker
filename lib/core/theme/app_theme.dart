import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography and touch-target sizing from phase_2_ux_design.md:
/// - Minimum touch target 48x48dp (accessibility requirement)
/// - Minimum 16sp body text, 4.5:1 contrast
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.danger,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 16),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(fontSize: 14),
      ),
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      // Material 3's default TextButton minimum size (64x36) is under the
      // UX doc's 48x48dp accessibility floor — match the other button
      // themes above so every TextButton (e.g. onboarding's "Skip"/"Allow
      // Later") is a large-enough touch target without repeating the
      // override at every call site.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: base.textTheme.labelLarge,
        ),
      ),
    );
  }
}
