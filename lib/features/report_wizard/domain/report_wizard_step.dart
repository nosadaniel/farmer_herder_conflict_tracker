import 'wizard_binding.dart';

/// The four fixed steps of the Guided Report Wizard (`docs/report_wizard_ux_flow.md`).
///
/// Each step owns a fixed, deterministic `surfaceId` and its own per-turn
/// `rules` text sent to Gemini the first time that step is visited — see
/// `docs/refactor.md` §1/§4. Because the `surfaceId` never changes for a
/// given step, revisiting an already-generated step (Back) is a pure local
/// index change: `SurfaceController` already has that surface cached, no new
/// Gemini call is made.
///
/// Every `ChoicePicker` in these rules is explicitly told to use
/// `variant: "mutuallyExclusive"`. This is a deliberate addition on top of
/// `docs/refactor.md`'s draft rules text: verified against the real
/// `genui-0.10.3` `ChoicePicker` catalog widget source
/// (`choice_picker.dart`), the default (no `variant` set) renders
/// *checkboxes* (multi-select) and writes an accumulating list to the
/// DataModel path. `mutuallyExclusive` renders radio-style single-select —
/// matching every wireframe in the UX doc ("○ Herd sighting") — and (via the
/// same source) still writes the DataModel value as a one-element list
/// (`[selectedValue]`), which `ReportWizardController` unwraps.
enum ReportWizardStep {
  where(
    code: 'where',
    title: 'Where?',
    bindings: [WizardBinding(path: '/report/location', key: 'location')],
    rules: '''
Ask how to find the user's area. Offer exactly two ChoicePicker options:
"Use my current location" and "Choose my state". Set the ChoicePicker's
variant to "mutuallyExclusive" (single choice, not a checkbox list). Bind
the selection to /report/location. Do not ask anything else on this
screen.''',
  ),
  whatsHappening(
    code: 'whats_happening',
    title: "What's happening?",
    bindings: [
      WizardBinding(path: '/report/whatsHappening', key: 'whatsHappening'),
    ],
    rules: '''
Offer a ChoicePicker with these exact options: "Herd sighting", "Herd
moving toward farmland", "Active confrontation", "Just checking my area".
Set the ChoicePicker's variant to "mutuallyExclusive" (single choice, not
a checkbox list). Bind the selection to /report/whatsHappening.''',
  ),
  whoInvolved(
    code: 'who_involved',
    title: "Who's involved?",
    bindings: [WizardBinding(path: '/report/whoInvolved', key: 'whoInvolved')],
    rules: '''
Offer a ChoicePicker: "Herders & cattle", "Farmers", "Both", "Not sure".
Set the ChoicePicker's variant to "mutuallyExclusive" (single choice, not
a checkbox list). Bind the selection to /report/whoInvolved.''',
  ),
  addDetail(
    code: 'add_detail',
    title: 'Add detail',
    bindings: [WizardBinding(path: '/report/detailText', key: 'detailText')],
    rules: '''
Offer a short optional TextField (placeholder: "Add more detail...") bound
to /report/detailText. This is the only component you generate for this
screen — a native "Speak" button and voice transcription are handled by the
app outside this surface; do not generate them yourself.''',
  );

  const ReportWizardStep({
    required this.code,
    required this.title,
    required this.bindings,
    required this.rules,
  });

  /// Short machine-friendly identifier, also used to build [surfaceId].
  final String code;

  /// Human-facing step title, used as the AppBar title while this step is
  /// active.
  final String title;

  /// The DataModel path(s) this step's surface writes to.
  final List<WizardBinding> bindings;

  /// The per-turn instructions sent to Gemini the first time this step is
  /// generated (see `ReportWizardController._promptFor`).
  final String rules;

  /// Fixed, deterministic surface id for this step — the linchpin of the
  /// "Back is free" behavior (`docs/refactor.md` §1).
  String get surfaceId => 'wizard_$code';

  ReportWizardStep? get next => switch (this) {
    ReportWizardStep.where => ReportWizardStep.whatsHappening,
    ReportWizardStep.whatsHappening => ReportWizardStep.whoInvolved,
    ReportWizardStep.whoInvolved => ReportWizardStep.addDetail,
    ReportWizardStep.addDetail => null,
  };

  ReportWizardStep? get previous => switch (this) {
    ReportWizardStep.where => null,
    ReportWizardStep.whatsHappening => ReportWizardStep.where,
    ReportWizardStep.whoInvolved => ReportWizardStep.whatsHappening,
    ReportWizardStep.addDetail => ReportWizardStep.whoInvolved,
  };

  // Enum already provides `index` (0-indexed declaration order, which
  // matches step order here) — used directly by the 4-dot progress
  // indicator instead of redeclaring it.
}
