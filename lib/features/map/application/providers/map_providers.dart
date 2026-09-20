import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/database/database_provider.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/datasources/local/conflict_local_datasource.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/repositories/conflict_repository_impl.dart';
import 'package:farmer_herder_conflict_tracker/features/map/data/datasources/local/location_datasource.dart';
import 'package:farmer_herder_conflict_tracker/features/map/data/repositories/location_repository_impl.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/entities/app_location.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/repositories/conflict_repository.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/repositories/location_repository.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/usecases/get_nearby_conflicts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_providers.g.dart';

// --- Conflict data -----------------------------------------------------

@Riverpod(keepAlive: true)
ConflictLocalDataSource conflictLocalDataSource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ConflictLocalDataSource(db);
}

@Riverpod(keepAlive: true)
ConflictRepository conflictRepository(Ref ref) {
  final dataSource = ref.watch(conflictLocalDataSourceProvider);
  return ConflictRepositoryImpl(dataSource);
}

/// All historical conflict records, for the map to render as hotspot
/// markers. Seeds the `ConflictData` table from the bundled dataset asset
/// on first call if the table is empty (see task.md deliverable #1).
///
/// Hand-written (not `@riverpod`-generated): `riverpod_generator` 4.0.9
/// throws `InvalidTypeException: The type is invalid and cannot be
/// converted to code` when a codegen'd provider's return type is a
/// Drift-generated row class (e.g. `ConflictDataData`, or even plain
/// `Report`) — verified by isolating a minimal repro. Every other provider
/// in this file returns a hand-written type and codegens fine; this is the
/// narrow exception.
final allConflictDataProvider = FutureProvider<List<ConflictDataData>>((
  ref,
) async {
  final repository = ref.watch(conflictRepositoryProvider);
  await repository.ensureSeeded();
  return repository.getAllConflicts();
});

// --- Nearby-conflicts usecase (cross-track dependency) -----------------

/// CRITICAL CROSS-TRACK DEPENDENCY (see task.md): Track B (Gemini prompt
/// building) can `ref.watch`/`ref.read` this to get the
/// [GetNearbyConflicts] usecase instance and call it directly:
/// `ref.read(getNearbyConflictsUsecaseProvider)(lat: ..., lng: ...)`.
@Riverpod(keepAlive: true)
GetNearbyConflicts getNearbyConflictsUsecase(Ref ref) {
  final repository = ref.watch(conflictRepositoryProvider);
  return GetNearbyConflicts(repository);
}

/// Parameters for [nearbyConflictsProvider]. Build with
/// [nearbyConflictsParams] to get the same `radiusKm`/`limit` defaults as
/// [GetNearbyConflicts.call].
typedef NearbyConflictsParams = ({
  double lat,
  double lng,
  double radiusKm,
  int limit,
});

NearbyConflictsParams nearbyConflictsParams({
  required double lat,
  required double lng,
  double radiusKm = 25,
  int limit = 5,
}) => (lat: lat, lng: lng, radiusKm: radiusKm, limit: limit);

/// Pure-provider alternative to reading [getNearbyConflictsUsecaseProvider]
/// directly — same `InvalidTypeException` constraint as
/// [allConflictDataProvider] applies here (return type is
/// `List<ConflictDataData>`), so this is also hand-written rather than
/// `@riverpod`-generated.
///
/// Usage: `ref.watch(nearbyConflictsProvider(nearbyConflictsParams(lat: x, lng: y)))`.
final nearbyConflictsProvider =
    FutureProvider.family<List<ConflictDataData>, NearbyConflictsParams>((
      ref,
      params,
    ) {
      final usecase = ref.watch(getNearbyConflictsUsecaseProvider);
      return usecase(
        lat: params.lat,
        lng: params.lng,
        radiusKm: params.radiusKm,
        limit: params.limit,
      );
    });

// --- Location ------------------------------------------------------------

@Riverpod(keepAlive: true)
LocationRepository locationRepository(Ref ref) {
  return const LocationRepositoryImpl(LocationDataSource());
}

/// Current device location, resolved once per app session (or whenever a
/// consumer calls `ref.invalidate(currentLocationProvider)` to retry).
/// Never throws — resolves to [AppLocationUnknown] on permission denial or
/// GPS unavailability, per task.md's "don't crash" requirement.
@riverpod
Future<AppLocation> currentLocation(Ref ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getCurrentLocation();
}
