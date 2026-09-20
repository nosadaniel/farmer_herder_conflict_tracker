/// App-wide constants that aren't environment secrets.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Farmer-Herders Conflict Tracker';

  /// Max duration for a single voice report recording.
  static const Duration maxRecordingDuration = Duration(minutes: 2);

  /// Max characters for a text report.
  static const int maxReportTextLength = 500;

  /// How many of the most recent reports/blueprints stay cached for offline use.
  static const int offlineCacheLimit = 50;

  /// Drift cache key for the last rendered A2UI blueprint, used for offline
  /// rehydration when the app has no network signal.
  static const String lastBlueprintCacheKey = 'last_blueprint';

  /// Path to the bundled historical conflict dataset asset.
  static const String conflictDatasetAssetPath =
      'assets/data/farmer_herder_conflict.json';
}

/// Risk levels the dynamic A2UI canvas can render, per phase_2_ux_design.md.
enum RiskLevel { low, medium, high, offline }
