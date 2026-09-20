import 'package:farmer_herder_conflict_tracker/core/constants/api_endpoints.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/theme/app_colors.dart';
import 'package:farmer_herder_conflict_tracker/features/map/application/providers/map_providers.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/entities/app_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap-tiled map showing the user's current location plus
/// historical farmer-herder conflict hotspots (severity-differentiated
/// markers), per task.md deliverable #4 / phase_2_ux_design.md's MapView +
/// MapMarker component catalog.
///
/// Standalone and self-wired to Riverpod (`allConflictDataProvider`,
/// `currentLocationProvider`) — deliberately NOT wired into
/// `lib/main.dart`/the app shell here; that integration happens in Phase 2.
///
/// Middle Belt (Kaduna/Kano/Plateau/Benue/Nasarawa/Taraba) fallback center
/// is used whenever the user's location is unknown (permission denied, GPS
/// unavailable) and no [initialCenter] override is supplied, so the map is
/// still useful without a GPS fix.
class ConflictMap extends ConsumerWidget {
  const ConflictMap({super.key, this.initialCenter, this.initialZoom = 6.5});

  /// Overrides the default center (otherwise: user location, or the Middle
  /// Belt fallback if location is unknown).
  final LatLng? initialCenter;
  final double initialZoom;

  /// Per OSM's tile usage policy: identifies this app in tile requests.
  static const String userAgentPackageName =
      'com.andela.farmerherder.farmer_herder_conflict_tracker';

  /// Roughly the geographic center of the Middle Belt states this app
  /// covers — used only as a last-resort map center when GPS is
  /// unavailable and no explicit [initialCenter] was supplied.
  static const LatLng middleBeltFallbackCenter = LatLng(9.0, 8.5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);
    final conflictsAsync = ref.watch(allConflictDataProvider);

    final userLatLng = locationAsync.maybeWhen(
      data: (location) =>
          location is AppLocationKnown
              ? LatLng(location.latitude, location.longitude)
              : null,
      orElse: () => null,
    );

    final center = initialCenter ?? userLatLng ?? middleBeltFallbackCenter;

    final conflictMarkers = conflictsAsync.maybeWhen(
      data: (conflicts) => conflicts.map(_hotspotMarker).toList(),
      orElse: () => const <Marker>[],
    );

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: initialZoom),
      children: [
        TileLayer(
          urlTemplate: ApiEndpoints.osmTileUrlTemplate,
          userAgentPackageName: userAgentPackageName,
        ),
        MarkerLayer(
          markers: [
            ...conflictMarkers,
            if (userLatLng != null) _userLocationMarker(userLatLng),
          ],
        ),
      ],
    );
  }

  Marker _userLocationMarker(LatLng point) {
    return Marker(
      point: point,
      width: 28,
      height: 28,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4),
          ],
        ),
        child: const Icon(Icons.person_pin, color: Colors.white, size: 18),
      ),
    );
  }

  Marker _hotspotMarker(ConflictDataData conflict) {
    final color = _severityColor(conflict.severity);
    final size = _severitySize(conflict.severity);

    return Marker(
      point: LatLng(conflict.latitude, conflict.longitude),
      width: size,
      height: size,
      child: Tooltip(
        message:
            '${conflict.locationName}\n'
            '${conflict.type} · ${conflict.severity}\n'
            '${conflict.fatalities} fatalities',
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.75),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// Judgment call: color mapping follows the app's earth-tone risk palette
  /// (`lib/core/theme/app_colors.dart`) rather than the UX doc's literal
  /// "faded red circles for hotspots" description, so severity is
  /// distinguishable at a glance (green/yellow/red) rather than uniform red.
  static Color _severityColor(String severity) {
    switch (severity) {
      case 'HIGH':
        return AppColors.danger;
      case 'MEDIUM':
        return AppColors.warning;
      case 'LOW':
      default:
        return AppColors.secondary;
    }
  }

  /// Judgment call: larger marker = higher severity, so a glance at marker
  /// size alone (without color perception) still conveys risk level.
  static double _severitySize(String severity) {
    switch (severity) {
      case 'HIGH':
        return 26;
      case 'MEDIUM':
        return 20;
      case 'LOW':
      default:
        return 14;
    }
  }
}
