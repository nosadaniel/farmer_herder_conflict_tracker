import 'package:drift/native.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/application/usecases/rehydrate_from_cache.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/repositories/cache_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

/// The worked example from docs/a2ui_gemini_contract.md §6 — this is what
/// Track B/Gemini actually emits, and what gets cached into the `Cache`
/// table for offline rehydration.
const _cachedBlueprint = '''
```json
{
  "version": "v0.9",
  "createSurface": {
    "surfaceId": "report_1758389421000",
    "catalogId": "https://a2ui.org/specification/v0_9/catalogs/basic/catalog.json",
    "sendDataModel": false
  }
}
```
```json
{
  "version": "v0.9",
  "updateComponents": {
    "surfaceId": "report_1758389421000",
    "components": [
      { "id": "root", "component": "Column", "children": ["headline"] },
      { "id": "headline", "component": "Text", "variant": "h1", "text": "Conflict reported nearby. Take action now." }
    ]
  }
}
```
''';

void main() {
  late AppDatabase db;
  late CacheRepository cacheRepository;
  late SurfaceController controller;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    cacheRepository = CacheRepository(db);
    controller = SurfaceController(
      catalogs: [BasicCatalogItems.asNoAssetCatalog()],
    );
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  test('rehydrateFromCache is a no-op when nothing is cached', () async {
    await rehydrateFromCache(controller, cacheRepository);

    expect(controller.activeSurfaceIds, isEmpty);
  });

  test(
    'rehydrateFromCache replays a cached blueprint into the controller',
    () async {
      await cacheRepository.saveBlueprint(
        'last_blueprint',
        _cachedBlueprint,
        const Duration(minutes: 5),
      );

      await rehydrateFromCache(
        controller,
        cacheRepository,
        cacheKey: 'last_blueprint',
      );

      expect(controller.activeSurfaceIds, contains('report_1758389421000'));
    },
  );

  test(
    'attemptLiveOrRehydrate falls back to the cache when the live call throws',
    () async {
      await cacheRepository.saveBlueprint(
        'last_blueprint',
        _cachedBlueprint,
        const Duration(minutes: 5),
      );

      await attemptLiveOrRehydrate(
        attemptLive: () async => throw Exception('no network'),
        controller: controller,
        cacheRepository: cacheRepository,
        cacheKey: 'last_blueprint',
      );

      expect(controller.activeSurfaceIds, contains('report_1758389421000'));
    },
  );

  test('attemptLiveOrRehydrate does not touch the cache when the live call succeeds', () async {
    var liveCalled = false;

    await attemptLiveOrRehydrate(
      attemptLive: () async {
        liveCalled = true;
      },
      controller: controller,
      cacheRepository: cacheRepository,
    );

    expect(liveCalled, isTrue);
    expect(controller.activeSurfaceIds, isEmpty);
  });
}
