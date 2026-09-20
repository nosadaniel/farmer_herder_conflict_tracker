import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/errors/exceptions.dart';

/// Raw Drift access to the `Reports` table (see
/// `lib/core/database/tables.dart`). Owned by Track D; callers should go
/// through `ReportRepository` rather than using this directly.
class ReportLocalDataSource {
  ReportLocalDataSource(this._db);

  final AppDatabase _db;

  Future<int> insertReport(ReportsCompanion entry) async {
    try {
      return await _db.into(_db.reports).insert(entry);
    } catch (e) {
      throw CacheException('Failed to save report: $e');
    }
  }

  /// All reports ordered oldest → newest (used for pruning).
  Future<List<Report>> allByTimestampAscending() async {
    try {
      return await (_db.select(
        _db.reports,
      )..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).get();
    } catch (e) {
      throw CacheException('Failed to list reports: $e');
    }
  }

  /// Most recent [limit] reports, newest first.
  Future<List<Report>> mostRecent(int limit) async {
    try {
      return await (_db.select(_db.reports)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(limit))
          .get();
    } catch (e) {
      throw CacheException('Failed to load recent reports: $e');
    }
  }

  Future<void> deleteByIds(Iterable<int> ids) async {
    if (ids.isEmpty) return;
    try {
      await (_db.delete(_db.reports)..where((t) => t.id.isIn(ids))).go();
    } catch (e) {
      throw CacheException('Failed to prune old reports: $e');
    }
  }
}
