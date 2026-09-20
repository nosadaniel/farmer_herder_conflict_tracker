import 'package:farmer_herder_conflict_tracker/features/map/domain/entities/app_location.dart';

/// Domain-facing contract for resolving the device's current location.
/// Never throws — permission/GPS failures surface as [AppLocationUnknown].
abstract class LocationRepository {
  Future<AppLocation> getCurrentLocation();
}
