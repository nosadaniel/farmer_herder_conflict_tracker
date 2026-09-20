import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../datasources/local/cache_local_data_source.dart';

/// Repository for the Drift `Cache` table — stores/retrieves the last A2UI
/// blueprint JSON so it can be rehydrated when there's no network
/// (`docs/a2ui_gemini_contract.md` §7, task.md's offline-rehydration
/// requirement).
///
/// Keying convention: callers should key entries off
/// `AppConstants.lastBlueprintCacheKey`, optionally suffixed per-sector
/// (e.g. `'${AppConstants.lastBlueprintCacheKey}_<surfaceId>'`) — see
/// `lib/core/database/tables.dart`'s `Cache` table doc comment.
class CacheRepository {
  CacheRepository(AppDatabase db) : _local = CacheLocalDataSource(db);

  final CacheLocalDataSource _local;

  /// Saves [blueprintJson] under [key], expiring after [ttl] from now.
  /// Overwrites any existing entry for the same key.
  Future<void> saveBlueprint(String key, String blueprintJson, Duration ttl) {
    return _local.upsertBlueprint(
      key: key,
      blueprintJson: blueprintJson,
      ttl: ttl,
    );
  }

  /// Returns the last cached blueprint JSON for [key], or null if there is
  /// none or it has expired (expired entries are lazily deleted here).
  Future<String?> getLastBlueprint(String key) async {
    final entry = await _local.readEntry(key);
    if (entry == null) return null;
    if (entry.expiresAt.isBefore(DateTime.now())) {
      await _local.deleteEntry(key);
      return null;
    }
    return entry.value;
  }
}

/// Provides a [CacheRepository] wired to the app-wide Drift database.
final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return CacheRepository(ref.watch(appDatabaseProvider));
});
