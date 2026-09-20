import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../datasources/local/report_local_data_source.dart';

/// Repository for the Drift `Reports` table — persists user-submitted
/// voice/text reports (with their A2UI blueprint) so recent reports survive
/// app restarts and can seed offline rehydration.
///
/// Storage is capped at [AppConstants.offlineCacheLimit] most-recent
/// reports: every [saveReport] call prunes older rows beyond that cap.
class ReportRepository {
  ReportRepository(AppDatabase db) : _local = ReportLocalDataSource(db);

  final ReportLocalDataSource _local;

  /// Saves a new report and prunes storage down to
  /// [AppConstants.offlineCacheLimit] most-recent rows. Returns the new
  /// row's id.
  Future<int> saveReport({
    required double latitude,
    required double longitude,
    required String transcription,
    required String riskLevel,
    required String a2uiBlueprint,
    bool synced = false,
    DateTime? timestamp,
  }) async {
    final id = await _local.insertReport(
      ReportsCompanion.insert(
        timestamp: timestamp ?? DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        transcription: transcription,
        riskLevel: riskLevel,
        a2uiBlueprint: a2uiBlueprint,
        synced: Value(synced),
      ),
    );
    await _pruneToLimit();
    return id;
  }

  /// Returns up to [limit] most recent reports, newest first. [limit] is
  /// clamped to [AppConstants.offlineCacheLimit] regardless of what's
  /// requested, since storage never holds more than that anyway.
  Future<List<Report>> getRecentReports(int limit) {
    final capped = limit > AppConstants.offlineCacheLimit
        ? AppConstants.offlineCacheLimit
        : (limit < 0 ? 0 : limit);
    return _local.mostRecent(capped);
  }

  Future<void> _pruneToLimit() async {
    final oldestFirst = await _local.allByTimestampAscending();
    final excess = oldestFirst.length - AppConstants.offlineCacheLimit;
    if (excess <= 0) return;
    final idsToDelete = oldestFirst.take(excess).map((r) => r.id);
    await _local.deleteByIds(idsToDelete);
  }
}

/// Provides a [ReportRepository] wired to the app-wide Drift database.
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(appDatabaseProvider));
});
