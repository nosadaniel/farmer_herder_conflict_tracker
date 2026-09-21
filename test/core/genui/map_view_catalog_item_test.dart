// Smoke tests for the custom `MapView` CatalogItem
// (lib/core/genui/map_view_catalog_item.dart), per
// docs/a2ui_gemini_contract.md §2's superseded-note.
//
// This is hackathon-scoped: we confirm the item registers under the right
// name and that its widget builder produces a widget (a SizedBox wrapping
// the existing `ConflictMap`, sized per the `variant` hint) without
// throwing, for `compact`, `full`, and missing-variant data — rendered end
// to end through the same SurfaceController/Conversation pipeline the real
// app uses (mirroring
// test/features/conflict_reporting/presentation/a2ui/widgets/a2ui_surface_view_test.dart),
// so we also exercise `ConflictMap`'s own provider wiring, with
// `currentLocationProvider`/`allConflictDataProvider` faked so no real
// location plugin or database is touched.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/genui/map_view_catalog_item.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/presentation/a2ui/providers/a2ui_providers.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/presentation/a2ui/widgets/a2ui_surface_view.dart';
import 'package:farmer_herder_conflict_tracker/features/map/application/providers/map_providers.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/entities/app_location.dart';

/// Builds a fenced-JSON fixture (matching the real Gemini output shape) that
/// creates a surface whose root is directly a `MapView` component with the
/// given [variant] (or no `variant` key at all if `variant` is null).
String _mapViewFixture({required String surfaceId, String? variant}) {
  final variantJson = variant == null ? '' : ',\n      "variant": "$variant"';
  return '''
```json
{
  "version": "v0.9",
  "createSurface": {
    "surfaceId": "$surfaceId",
    "catalogId": "https://a2ui.org/specification/v0_9/catalogs/basic/catalog.json",
    "sendDataModel": false
  }
}
```
```json
{
  "version": "v0.9",
  "updateComponents": {
    "surfaceId": "$surfaceId",
    "components": [
      { "id": "root", "component": "MapView"$variantJson }
    ]
  }
}
```
''';
}

ProviderContainer _containerWithFixtureHandler(String text) {
  return ProviderContainer(
    overrides: [
      a2uiSendHandlerProvider.overrideWith((ref) {
        return (ChatMessage message) async {
          ref.read(a2uiTransportProvider).addChunk(text);
        };
      }),
      // Avoid touching the real location plugin / Drift database — this
      // test only cares that MapView's widget builder wires up ConflictMap
      // without throwing, not real GPS/history data.
      currentLocationProvider.overrideWith(
        (ref) async => const AppLocationUnknown('test: location not faked'),
      ),
      allConflictDataProvider.overrideWith(
        (ref) async => const <ConflictDataData>[],
      ),
    ],
  );
}

void main() {
  test('mapViewCatalogItem is registered under the name "MapView"', () {
    expect(mapViewCatalogItem.name, 'MapView');
  });

  for (final variant in const [null, 'compact', 'full']) {
    testWidgets('renders a MapView surface without throwing '
        '(variant: ${variant ?? 'missing'})', (tester) async {
      final surfaceId = 'map_test_${variant ?? 'missing'}';
      final container = _containerWithFixtureHandler(
        _mapViewFixture(surfaceId: surfaceId, variant: variant),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: A2uiSurfaceView())),
        ),
      );

      await container
          .read(conversationProvider)
          .sendRequest(ChatMessage.user('test report'));

      await tester.pump();
      await tester.pump();

      // A SizedBox with the expected height (per variant) should now be
      // in the tree, proving MapView's widgetBuilder ran without
      // throwing and honored the variant -> height mapping.
      final expectedHeight = variant == 'compact'
          ? mapViewCompactHeight
          : mapViewFullHeight;
      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((box) => box.height == expectedHeight);
      expect(sizedBoxes, isNotEmpty);
    });
  }
}
