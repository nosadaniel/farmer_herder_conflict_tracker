import 'package:farmer_herder_conflict_tracker/core/errors/exceptions.dart';
import 'package:farmer_herder_conflict_tracker/features/map/data/datasources/local/location_datasource.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/entities/app_location.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/repositories/location_repository.dart';

/// Concrete [LocationRepository] backed by [LocationDataSource].
///
/// Converts [LocationException]s from the data source into
/// [AppLocationUnknown] rather than rethrowing — the presentation layer
/// should never need a try/catch to render a "location unavailable" state.
class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final LocationDataSource _dataSource;

  @override
  Future<AppLocation> getCurrentLocation() async {
    try {
      final position = await _dataSource.getCurrentPosition();
      return AppLocationKnown(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationException catch (e) {
      return AppLocationUnknown(e.message);
    } catch (e) {
      return AppLocationUnknown('Could not determine location: $e');
    }
  }
}
