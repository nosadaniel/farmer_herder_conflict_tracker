import 'package:drift/native.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/repositories/cache_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CacheRepository repository;

  setUp(() {
    // In-memory Drift instance per task's smoke-test instructions — never
    // touches a real device DB file.
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = CacheRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('saveBlueprint then getLastBlueprint round-trips the JSON', () async {
    await repository.saveBlueprint(
      'last_blueprint',
      '{"surfaceId":"report_1"}',
      const Duration(minutes: 5),
    );

    final result = await repository.getLastBlueprint('last_blueprint');

    expect(result, '{"surfaceId":"report_1"}');
  });

  test('getLastBlueprint returns null when nothing is cached', () async {
    final result = await repository.getLastBlueprint('missing_key');

    expect(result, isNull);
  });

  test('saveBlueprint overwrites an existing entry for the same key', () async {
    await repository.saveBlueprint(
      'last_blueprint',
      '{"v":1}',
      const Duration(minutes: 5),
    );
    await repository.saveBlueprint(
      'last_blueprint',
      '{"v":2}',
      const Duration(minutes: 5),
    );

    final result = await repository.getLastBlueprint('last_blueprint');

    expect(result, '{"v":2}');
  });

  test('getLastBlueprint returns null and prunes an expired entry', () async {
    await repository.saveBlueprint(
      'last_blueprint',
      '{"v":1}',
      const Duration(seconds: -1), // already expired
    );

    final result = await repository.getLastBlueprint('last_blueprint');

    expect(result, isNull);
  });
}
