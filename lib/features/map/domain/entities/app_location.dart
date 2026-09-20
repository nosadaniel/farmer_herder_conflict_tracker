/// GPS location state for the map feature. Deliberately never throws up to
/// the presentation layer — permission-denied / GPS-unavailable are
/// first-class states ([AppLocation.unknown]), not exceptions, per task.md's
/// "graceful fallback if permission denied / GPS unavailable (don't crash)".
sealed class AppLocation {
  const AppLocation();
}

/// A resolved device position.
class AppLocationKnown extends AppLocation {
  const AppLocationKnown({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  String toString() => 'AppLocationKnown($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocationKnown &&
          other.latitude == latitude &&
          other.longitude == longitude);

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// Location could not be determined — permission denied, GPS/location
/// services disabled, or a lookup timeout/error. [reason] is a short,
/// user-presentable explanation.
class AppLocationUnknown extends AppLocation {
  const AppLocationUnknown(this.reason);

  final String reason;

  @override
  String toString() => 'AppLocationUnknown($reason)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocationUnknown && other.reason == reason);

  @override
  int get hashCode => reason.hashCode;
}
