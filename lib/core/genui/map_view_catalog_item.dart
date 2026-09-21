// Custom `CatalogItem` registering a `MapView` component so Gemini-authored
// A2UI surfaces can embed the app's live conflict map.
//
// Per docs/a2ui_gemini_contract.md §2's superseded-note, the map is a
// required custom `CatalogItem` (not a stretch goal): Gemini only ever
// supplies an optional size hint (`variant`), never coordinates or markers
// — the widget pulls the user's location and nearby historical conflicts
// itself from the same providers `ConflictMap` already uses
// (`currentLocationProvider`/`allConflictDataProvider`), so this file
// deliberately reuses `ConflictMap` directly rather than reimplementing map
// rendering.
import 'package:farmer_herder_conflict_tracker/features/map/presentation/widgets/conflict_map.dart';
import 'package:flutter/widgets.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final _schema = S.object(
  description:
      'A live map showing the user\'s current location and nearby '
      'historical conflict hotspots. The app fills in coordinates and '
      'markers itself — do not supply them.',
  properties: {
    'variant': S.string(
      description:
          'A size hint for how much vertical space the map should take. '
          '"compact" for a small inline map, "full" for a larger, more '
          'prominent map. Defaults to "full" if omitted.',
      enumValues: ['compact', 'full'],
    ),
  },
);

/// Height (logical pixels) used when `variant` is `'compact'` — a small
/// inline map, e.g. alongside other content rather than as the screen's
/// focal point.
const double mapViewCompactHeight = 180;

/// Height (logical pixels) used when `variant` is `'full'` (the default) —
/// a larger, more prominent map.
const double mapViewFullHeight = 320;

/// A live map component Gemini can place in an AI-generated surface.
///
/// ## Parameters:
///
/// - `variant`: optional size hint, `'compact'` or `'full'` (default
///   `'full'`). Gemini never supplies coordinates or markers — this widget
///   pulls the user's location and nearby historical conflicts itself via
///   the same Riverpod providers `ConflictMap` already uses.
final mapViewCatalogItem = CatalogItem(
  name: 'MapView',
  dataSchema: _schema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, Object?>;
    final variant = data['variant'];
    final height = variant == 'compact'
        ? mapViewCompactHeight
        : mapViewFullHeight;
    return SizedBox(height: height, child: const ConflictMap());
  },
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "MapView",
          "variant": "compact"
        }
      ]
    ''',
  ],
);
