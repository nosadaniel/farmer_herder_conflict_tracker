import 'dart:async';

import 'package:farmer_herder_conflict_tracker/core/errors/exceptions.dart';
import 'package:geolocator/geolocator.dart';

/// Wraps `geolocator` to fetch the device's current GPS position, handling
/// permission requests and graceful failure itself.
///
/// Uses geolocator's own permission-request APIs only (per task.md — no
/// separate `permission_handler` dependency).
class LocationDataSource {
  const LocationDataSource();

  /// Returns the current device position.
  ///
  /// Throws [LocationException] (never a raw platform exception) when:
  /// - location services are disabled on the device
  /// - permission is denied or permanently denied
  /// - the underlying platform call fails or times out
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException('Location permission permanently denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      throw const LocationException('Timed out waiting for a GPS fix');
    } catch (e) {
      throw LocationException('Could not determine location: $e');
    }
  }
}
