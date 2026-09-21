import 'package:drift/drift.dart';
import 'package:farmer_herder_conflict_tracker/core/constants/app_constants.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/errors/exceptions.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/models/conflict_record_model.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Local (on-device) data source for historical conflict data: reads the
/// bundled `farmer_herder_conflict.json` asset and reads/writes the Drift
/// `ConflictData` table.
///
/// Lives under `conflict_reporting/data/datasources/local` per Track A's
/// folder ownership in task.md — the row type it returns
/// ([ConflictDataData], Drift's generated data class for the `ConflictData`
/// table defined in `lib/core/database/tables.dart`) is consumed by
/// `lib/features/map/**`.
class ConflictLocalDataSource {
  const ConflictLocalDataSource(this._db);

  final AppDatabase _db;

  /// Number of rows currently in the `ConflictData` table.
  Future<int> count() async {
    final countExp = _db.conflictData.id.count();
    final query = _db.selectOnly(_db.conflictData)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// All rows currently in the `ConflictData` table.
  Future<List<ConflictDataData>> getAll() {
    return _db.select(_db.conflictData).get();
  }

  /// Inserts (or replaces, by primary key) the given rows in a single batch.
  Future<void> insertAll(List<ConflictDataCompanion> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(_db.conflictData, rows, mode: InsertMode.insertOrReplace);
    });
  }

  /// Loads and parses the bundled dataset asset (does not touch the
  /// database). Throws [CacheException] if the asset can't be read/parsed —
  /// this is a bundled asset, so a failure here indicates a packaging bug,
  /// not a transient error.
  Future<ConflictDatasetParseResult> loadBundledDataset() async {
    try {
      final jsonString = await rootBundle.loadString(
        AppConstants.conflictDatasetAssetPath,
      );
      return parseConflictDataset(jsonString);
    } catch (e) {
      throw CacheException('Failed to load bundled conflict dataset: $e');
    }
  }

  /// Loads the bundled dataset and inserts it into the `ConflictData` table
  /// only if the table is currently empty (first app launch). No-op on
  /// subsequent launches.
  Future<void> seedFromBundledDatasetIfEmpty() async {
    final existing = await count();
    if (existing > 0) return;

    final parsed = await loadBundledDataset();
    final companions = parsed.records.map((r) => r.toCompanion()).toList();
    await insertAll(companions);
  }
}
