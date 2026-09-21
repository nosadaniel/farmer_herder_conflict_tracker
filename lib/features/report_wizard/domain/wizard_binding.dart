/// Ties one A2UI `DataModel` path (written by a generated wizard surface) to
/// a stable, app-facing key.
///
/// [path] is the absolute path the surface's catalog widget (typically a
/// `ChoicePicker` or `TextField`) writes into, e.g. `/report/location`.
/// [key] is what the rest of the app calls that answer — the chip-trail
/// label source and the map key used when handing everything off to
/// `ReportSubmissionController.submitStructured`'s `wizardAnswers` map.
class WizardBinding {
  const WizardBinding({
    required this.path,
    required this.key,
    this.isList = false,
  });

  /// The absolute `DataModel` path this binding mirrors, e.g.
  /// `/report/whatsHappening`.
  final String path;

  /// The stable key this binding's value is stored under in
  /// `ReportWizardState.answers`.
  final String key;

  /// Whether the bound value is expected to be a list rather than a single
  /// scalar. None of the current wizard steps use this (every step is a
  /// single-select `ChoicePicker` or a single `TextField`), but it's kept so
  /// a future multi-select step doesn't need a shape change here.
  final bool isList;
}
