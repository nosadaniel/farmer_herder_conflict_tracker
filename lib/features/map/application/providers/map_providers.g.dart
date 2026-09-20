// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conflictLocalDataSource)
final conflictLocalDataSourceProvider = ConflictLocalDataSourceProvider._();

final class ConflictLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ConflictLocalDataSource,
          ConflictLocalDataSource,
          ConflictLocalDataSource
        >
    with $Provider<ConflictLocalDataSource> {
  ConflictLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conflictLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conflictLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ConflictLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConflictLocalDataSource create(Ref ref) {
    return conflictLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConflictLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConflictLocalDataSource>(value),
    );
  }
}

String _$conflictLocalDataSourceHash() =>
    r'3b39c67b22446479d2c5be4974be717f1f9d5fef';

@ProviderFor(conflictRepository)
final conflictRepositoryProvider = ConflictRepositoryProvider._();

final class ConflictRepositoryProvider
    extends
        $FunctionalProvider<
          ConflictRepository,
          ConflictRepository,
          ConflictRepository
        >
    with $Provider<ConflictRepository> {
  ConflictRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conflictRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conflictRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConflictRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConflictRepository create(Ref ref) {
    return conflictRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConflictRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConflictRepository>(value),
    );
  }
}

String _$conflictRepositoryHash() =>
    r'a61e4a44d4afc4a261ff7c48ed0ea91e82430890';

/// CRITICAL CROSS-TRACK DEPENDENCY (see task.md): Track B (Gemini prompt
/// building) can `ref.watch`/`ref.read` this to get the
/// [GetNearbyConflicts] usecase instance and call it directly:
/// `ref.read(getNearbyConflictsUsecaseProvider)(lat: ..., lng: ...)`.

@ProviderFor(getNearbyConflictsUsecase)
final getNearbyConflictsUsecaseProvider = GetNearbyConflictsUsecaseProvider._();

/// CRITICAL CROSS-TRACK DEPENDENCY (see task.md): Track B (Gemini prompt
/// building) can `ref.watch`/`ref.read` this to get the
/// [GetNearbyConflicts] usecase instance and call it directly:
/// `ref.read(getNearbyConflictsUsecaseProvider)(lat: ..., lng: ...)`.

final class GetNearbyConflictsUsecaseProvider
    extends
        $FunctionalProvider<
          GetNearbyConflicts,
          GetNearbyConflicts,
          GetNearbyConflicts
        >
    with $Provider<GetNearbyConflicts> {
  /// CRITICAL CROSS-TRACK DEPENDENCY (see task.md): Track B (Gemini prompt
  /// building) can `ref.watch`/`ref.read` this to get the
  /// [GetNearbyConflicts] usecase instance and call it directly:
  /// `ref.read(getNearbyConflictsUsecaseProvider)(lat: ..., lng: ...)`.
  GetNearbyConflictsUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getNearbyConflictsUsecaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getNearbyConflictsUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetNearbyConflicts> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetNearbyConflicts create(Ref ref) {
    return getNearbyConflictsUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetNearbyConflicts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetNearbyConflicts>(value),
    );
  }
}

String _$getNearbyConflictsUsecaseHash() =>
    r'4962bfe8b89aeb422d325a65d2f88295d338f10b';

@ProviderFor(locationRepository)
final locationRepositoryProvider = LocationRepositoryProvider._();

final class LocationRepositoryProvider
    extends
        $FunctionalProvider<
          LocationRepository,
          LocationRepository,
          LocationRepository
        >
    with $Provider<LocationRepository> {
  LocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationRepository create(Ref ref) {
    return locationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationRepository>(value),
    );
  }
}

String _$locationRepositoryHash() =>
    r'e0f6c1ca303317139883449924263e2fd7c770b9';

/// Current device location, resolved once per app session (or whenever a
/// consumer calls `ref.invalidate(currentLocationProvider)` to retry).
/// Never throws — resolves to [AppLocationUnknown] on permission denial or
/// GPS unavailability, per task.md's "don't crash" requirement.

@ProviderFor(currentLocation)
final currentLocationProvider = CurrentLocationProvider._();

/// Current device location, resolved once per app session (or whenever a
/// consumer calls `ref.invalidate(currentLocationProvider)` to retry).
/// Never throws — resolves to [AppLocationUnknown] on permission denial or
/// GPS unavailability, per task.md's "don't crash" requirement.

final class CurrentLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppLocation>,
          AppLocation,
          FutureOr<AppLocation>
        >
    with $FutureModifier<AppLocation>, $FutureProvider<AppLocation> {
  /// Current device location, resolved once per app session (or whenever a
  /// consumer calls `ref.invalidate(currentLocationProvider)` to retry).
  /// Never throws — resolves to [AppLocationUnknown] on permission denial or
  /// GPS unavailability, per task.md's "don't crash" requirement.
  CurrentLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLocationHash();

  @$internal
  @override
  $FutureProviderElement<AppLocation> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppLocation> create(Ref ref) {
    return currentLocation(ref);
  }
}

String _$currentLocationHash() => r'97a7c940d6cd9cf071dc2914ad252d341b8ff40a';
