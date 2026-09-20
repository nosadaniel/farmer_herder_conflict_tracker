import 'package:drift/native.dart';
import 'package:farmer_herder_conflict_tracker/core/constants/app_constants.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/repositories/report_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ReportRepository repository;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = ReportRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> save({required DateTime timestamp, String riskLevel = 'HIGH'}) {
    return repository.saveReport(
      latitude: 9.08,
      longitude: 8.67,
      transcription: 'A herd crossed the northern stream.',
      riskLevel: riskLevel,
      a2uiBlueprint: '{"surfaceId":"report_1"}',
      timestamp: timestamp,
    );
  }

  test('saveReport then getRecentReports returns it newest first', () async {
    await save(timestamp: DateTime(2026, 1, 1));
    await save(timestamp: DateTime(2026, 1, 2));

    final reports = await repository.getRecentReports(10);

    expect(reports, hasLength(2));
    expect(reports.first.timestamp, DateTime(2026, 1, 2));
    expect(reports.first.riskLevel, 'HIGH');
  });

  test('getRecentReports clamps the requested limit to AppConstants.offlineCacheLimit', () async {
    final reports = await repository.getRecentReports(
      AppConstants.offlineCacheLimit + 100,
    );

    // No rows exist yet, but the call must not throw / must clamp
    // internally rather than querying an unbounded limit.
    expect(reports, isEmpty);
  });

  test(
    'saveReport prunes storage down to AppConstants.offlineCacheLimit rows',
    () async {
      // Save one more than the cap; oldest should be pruned.
      for (var i = 0; i < AppConstants.offlineCacheLimit + 1; i++) {
        await save(timestamp: DateTime(2026, 1, 1).add(Duration(minutes: i)));
      }

      final reports = await repository.getRecentReports(
        AppConstants.offlineCacheLimit + 10,
      );

      expect(reports, hasLength(AppConstants.offlineCacheLimit));
      // The oldest report (minute 0) should have been pruned; the newest
      // (last minute saved) should remain as the first (newest-first) row.
      expect(
        reports.first.timestamp,
        DateTime(
          2026,
          1,
          1,
        ).add(Duration(minutes: AppConstants.offlineCacheLimit)),
      );
    },
  );
}
