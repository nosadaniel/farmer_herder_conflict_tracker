import 'package:genui/genui.dart';

import '../data/datasources/remote/report_wizard_prompt.dart';

/// The catalog used to render the wizard's generated surfaces.
///
/// Reuses the basic (no-asset) catalog subset — `ChoicePicker`, `Text`,
/// `Icon`, `TextField` — exactly like the existing Result session
/// (`lib/features/conflict_reporting/presentation/a2ui/providers/a2ui_providers.dart`),
/// no custom `CatalogItem`s. No `MapView` here: the wizard never shows the
/// map, only the (separately-wired) Result screen does.
final Catalog reportWizardCatalog = BasicCatalogItems.asNoAssetCatalog(
  systemPromptFragments: [reportWizardPromptFragment],
);
