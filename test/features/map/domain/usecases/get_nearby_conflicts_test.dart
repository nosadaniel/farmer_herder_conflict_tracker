import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/repositories/conflict_repository.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/usecases/get_nearby_conflicts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConflictRepository extends Mock implements ConflictRepository {}

/// Query point used across these tests. Fixtures below vary only latitude
/// relative to this point so expected distances are easy to verify by hand
/// (1 degree of latitude is ~111km).
const _queryLat = 9.0;
const _queryLng = 8.5;

ConflictDataData _fixture({
  required int id,
  required double lat,
  required double lng,
  String locationName = 'Test Location',
}) {
  return ConflictDataData(
    id: id,
    date: DateTime(2020, 1, 1),
    latitude: lat,
    longitude: lng,
    type: 'farmer-herder',
    severity: 'LOW',
    fatalities: 0,
    locationName: locationName,
  );
}

void main() {
  late _MockConflictRepository repository;
  late GetNearbyConflicts usecase;

  setUp(() {
    repository = _MockConflictRepository();
    usecase = GetNearbyConflicts(repository);
  });

  // ~5.5km from the query point.
  final near = _fixture(id: 1, lat: 9.05, lng: _queryLng, locationName: 'Near');
  // ~16.7km from the query point.
  final medium = _fixture(
    id: 2,
    lat: 9.15,
    lng: _queryLng,
    locationName: 'Medium',
  );
  // ~166km from the query point — well outside any sane radius.
  final far = _fixture(id: 3, lat: 10.5, lng: _queryLng, locationName: 'Far');

  test(
    'filters out records beyond radiusKm and sorts the rest nearest-first',
    () async {
      // Deliberately supplied out of distance order.
      when(() => repository.getAllConflicts())
          .thenAnswer((_) async => [far, medium, near]);

      final result = await usecase(
        lat: _queryLat,
        lng: _queryLng,
        radiusKm: 25,
        limit: 5,
      );

      expect(result.map((c) => c.id).toList(), [1, 2]);
    },
  );

  test('respects the limit parameter after sorting', () async {
    when(() => repository.getAllConflicts())
        .thenAnswer((_) async => [medium, near, far]);

    final result = await usecase(
      lat: _queryLat,
      lng: _queryLng,
      radiusKm: 200,
      limit: 2,
    );

    // All three are within 200km, but limit=2 keeps only the nearest two.
    expect(result.map((c) => c.id).toList(), [1, 2]);
  });

  test('returns an empty list when nothing is within radiusKm', () async {
    when(() => repository.getAllConflicts()).thenAnswer((_) async => [far]);

    final result = await usecase(
      lat: _queryLat,
      lng: _queryLng,
      radiusKm: 25,
      limit: 5,
    );

    expect(result, isEmpty);
  });

  test('uses the default radiusKm (25) and limit (5) when omitted', () async {
    when(() => repository.getAllConflicts())
        .thenAnswer((_) async => [near, medium, far]);

    final result = await usecase(lat: _queryLat, lng: _queryLng);

    expect(result.map((c) => c.id).toList(), [1, 2]);
  });
}
