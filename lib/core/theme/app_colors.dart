import 'package:flutter/material.dart';

/// Color palette from phase_2_ux_design.md — earth tones, high-contrast risk
/// colors for outdoor visibility and low-literacy users.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF8B4513); // Earth Brown
  static const Color secondary = Color(0xFF228B22); // Forest Green (safe/low)
  static const Color warning = Color(0xFFFFD700); // Golden Yellow (medium)
  static const Color danger = Color(0xFFDC143C); // Blood Red (high)
  static const Color neutral = Color(0xFFA9A9A9); // Warm Gray
  static const Color success = Color(0xFF32CD32); // Lime Green
  static const Color background = Color(0xFFFFFDD0); // Cream

  /// Orange used for offline-mode indicators (not in the original table but
  /// referenced throughout the UX doc's offline states).
  static const Color offline = Color(0xFFFF8C00);
}
