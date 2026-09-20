import '../../../../../core/database/app_database.dart';
import '../../../../../core/errors/exceptions.dart';

/// Raw Drift access to the `Cache` table (see
/// `lib/core/database/tables.dart`). Owned by Track D; callers should go
/// through `CacheRepository` rather than using this directly.
class CacheLocalDataSource {
  CacheLocalDataSource(this._db);

  final AppDatabase _db;

  /// Upserts a blueprint JSON blob for [key], stamping `timestamp` as now
  /// and `expiresAt` as `now + ttl`.
  Future<void> upsertBlueprint({
    required String key,
    required String blueprintJson,
    required Duration ttl,
  }) async {
    final now = DateTime.now();
    try {
      await _db
          .into(_db.cache)
          .insertOnConflictUpdate(
            CacheCompanion.insert(
              key: key,
              value: blueprintJson,
              timestamp: now,
              expiresAt: now.add(ttl),
            ),
          );
    } catch (e) {
      throw CacheException('Failed to write cache entry "$key": $e');
    }
  }

  /// Returns the raw cache row for [key], or null if absent. Does not
  /// evaluate expiry — that's a `CacheRepository` concern.
  Future<CacheData?> readEntry(String key) async {
    try {
      return await (_db.select(
        _db.cache,
      )..where((t) => t.key.equals(key))).getSingleOrNull();
    } catch (e) {
      throw CacheException('Failed to read cache entry "$key": $e');
    }
  }

  /// Deletes the cache row for [key], if any.
  Future<void> deleteEntry(String key) async {
    try {
      await (_db.delete(_db.cache)..where((t) => t.key.equals(key))).go();
    } catch (e) {
      throw CacheException('Failed to delete cache entry "$key": $e');
    }
  }
}
