import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/repositories/conflict_repository.dart';
import 'package:latlong2/latlong.dart';

/// CRITICAL CROSS-TRACK DEPENDENCY (see task.md): Track B (Gemini prompt
/// building) imports this usecase to fetch nearby historical conflicts as
/// AI context. Keep this signature stable.
///
/// Returns the nearest [limit] [ConflictDataData] rows within [radiusKm] of
/// (`lat`, `lng`), sorted nearest-first, using [latlong2]'s [Distance]
/// (great-circle distance via Vincenty's formula by default).
///
/// Usage:
/// ```dart
/// final usecase = GetNearbyConflicts(repository);
/// final nearby = await usecase(lat: 9.05, lng: 8.0, radiusKm: 25, limit: 5);
/// ```
class GetNearbyConflicts {
  GetNearbyConflicts(this._repository, {Distance? distanceCalculator})
    : _distance = distanceCalculator ?? const Distance();

  final ConflictRepository _repository;
  final Distance _distance;

  Future<List<ConflictDataData>> call({
    required double lat,
    required double lng,
    double radiusKm = 25,
    int limit = 5,
  }) async {
    final all = await _repository.getAllConflicts();
    final origin = LatLng(lat, lng);

    final withinRadius = <(ConflictDataData, double)>[];
    for (final conflict in all) {
      final distanceKm = _distance.as(
        LengthUnit.Kilometer,
        origin,
        LatLng(conflict.latitude, conflict.longitude),
      );
      if (distanceKm <= radiusKm) {
        withinRadius.add((conflict, distanceKm));
      }
    }

    withinRadius.sort((a, b) => a.$2.compareTo(b.$2));

    return withinRadius.take(limit).map((entry) => entry.$1).toList();
  }
}
