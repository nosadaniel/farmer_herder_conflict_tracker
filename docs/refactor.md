# Refactor Guide: Implementing `report_wizard_ux_flow.md` per `example_usage_genui.md`

**Status**: implementation guide, not yet built. Read `docs/report_wizard_ux_flow.md` first (the screen-by-screen UX sketch) and `docs/example_usage_genui.md` (the architecture pattern this guide adapts — its reference app, confirmed via `docs/image-2.png`, is literally the same "World setup → Scene type → ..." wizard pattern shown as the design inspiration). Read `docs/a2ui_gemini_contract.md` for what stays frozen/unchanged.

---

## 1. The one architectural decision that drives everything else

`report_wizard_ux_flow.md`'s original sketch assumed the app's existing `.chat()` preset (`SurfaceOperations.createOnly`, brand-new `surfaceId` every turn, no data bindings) — the same preset the shipped report-generation flow uses. Under that preset, "Back" had to hack around by remembering a list of past surface IDs.

`example_usage_genui.md` shows the better-fitting preset for a **multi-step form that ends in one result**: `PromptBuilder.custom(allowedOperations: SurfaceOperations.createAndUpdate(dataModel: false))`, combined with **fixed, deterministic `surfaceId`s per step** and **DataModel bindings** for the tap-to-select answers (`docs/image-3.png`'s migration table: "Observable, path-addressed DataModel" replacing a hand-rolled selections map). This changes the wizard's implementation in three ways that matter:

1. **Selecting an option is free** — no Gemini call. The catalog widget writes straight into the surface's `DataModel` (`context.dataContext.update(DataPath(path), value)`), confirmed in `docs/image-2.png`'s worked example (`"selectedOption": {"path": "/scene/season"}`). Only *moving to a new step* or *asking for different options* costs a Gemini call.
2. **Back is free** — each step has its own fixed `surfaceId` (e.g. `wizard_where`, `wizard_whats_happening`), so revisiting a step just re-shows a surface the `SurfaceController` already has cached. No new turn, no walking a history list.
3. **The chip trail is a DataModel subscription, not manually-threaded state** — `docs/image-1.png` shows this exactly: the chip bar ("Summer · Day · Small local kiosk") lives *outside* the GenUI surface as a native widget, but updates live because it's subscribed to the same `/scene/*` paths the surface writes to. Subscribe once per binding path, mirror every value change into the chip bar.

**This supersedes the "walk backward through `conversation.state.surfaces`" note in `report_wizard_ux_flow.md`'s Behavior Notes section.** Everything else in that doc (screen content, step order, permission-earning points, result screen) stays as designed.

---

## 2. Two separate GenUI sessions, bridged by plain Dart — not one

Keep the **existing, shipped, frozen** report-generation flow (`docs/a2ui_gemini_contract.md`, `.chat()`/`createOnly`, `GeminiRemoteDataSource`, `ReportSubmissionController`, `ConflictContextBuilder`) completely unchanged. It already does exactly one job well: turn a context block into a risk-state result surface (map + headline + actions + `share_alert`).

The wizard is a **second, separate GenUI session** with its own catalog subset, its own system prompt, its own `createAndUpdate` surfaces — purely for *collecting structured input*. When the user taps **Create**, the wizard's job ends: read its `DataModel` values back out, hand them to (an extended) `ConflictContextBuilder`, and call the existing report flow exactly as it runs today for a text report.

```
Wizard session (new)                         Report session (unchanged)
──────────────────────                       ───────────────────────────
createAndUpdate, dataModel: false             createOnly (.chat())
fixed surfaceId per step                      surfaceId per turn (timestamp)
ChoicePicker/Text/Icon + bindings             Column/Text/Icon/Button (no bindings)
Steps 1-4                                     Result screen only
        │
        │  Create tapped → read DataModel → build context block
        ▼
ConflictContextBuilder.build(..., wizardAnswers: {...})  ──▶  GeminiRemoteDataSource
                                                                (unchanged)
```

This means **no changes to the frozen contract doc's §3–§7**, and the shipped `share_alert` handling, risk classification rubric, and worked example all keep working unmodified.

---

## 3. Wizard session: adapt `FirebaseGenUiSession`, don't reuse `a2ui_providers.dart` as-is

The existing `a2ui_providers.dart` pattern (five separate `keepAlive` Riverpod providers: catalog/sendHandler/surfaceController/transport/conversation) is right for a session that lives as long as the app. The wizard is the opposite — a **bounded session**, created when the user starts a report and disposed the moment they hit Create or Close/restart. That's exactly the case the article's `FirebaseGenUiSession` class argues for ("that state belongs to the current refinement flow, not to the whole feature").

New file: `lib/features/report_wizard/application/report_wizard_session.dart`

```dart
class ReportWizardSession {
  ReportWizardSession({required Catalog catalog, required String systemInstruction}) {
    controller = SurfaceController(catalogs: [catalog]);
    final prompt = PromptBuilder.custom(
      catalog: catalog,
      allowedOperations: SurfaceOperations.createAndUpdate(dataModel: false),
      systemPromptFragments: [systemInstruction],
    ).systemPromptJoined();
    _model = FirebaseAI.googleAI().generativeModel(
      model: GeminiRemoteDataSource.defaultModelName, // reuse the existing constant
      systemInstruction: Content.system(prompt),
    );
    transport = A2uiTransportAdapter(onSend: _sendToGemini);
    conversation = Conversation(controller: controller, transport: transport);
  }

  late final SurfaceController controller;
  late final Conversation conversation;
  late final A2uiTransportAdapter transport;
  late final GenerativeModel _model;

  SurfaceHost get host => controller;
  Stream<ConversationEvent> get events => conversation.events;

  Future<void> sendText(String prompt) =>
      conversation.sendRequest(ChatMessage.user(prompt));

  /// App-owned intent, not part of any generated surface — same shape as
  /// the article's "Show different options" button (docs/image.png):
  /// `UserActionEvent` dispatched directly, `surfaceId` set explicitly
  /// since there's no catalog widget to inject it.
  void dispatchIntent({
    required String surfaceId,
    required String name,
    required Map<String, Object?> context,
  }) {
    controller.handleUiEvent(
      UserActionEvent(
        surfaceId: surfaceId,
        name: name,
        sourceComponentId: 'app_$name',
        context: context,
      ),
    );
  }

  Future<void> _sendToGemini(ChatMessage message) async {
    final content = /* reuse GeminiRemoteDataSource's existing Content-conversion helper */;
    await for (final chunk in _model.generateContentStream([content])) {
      if (chunk.text case final text?) transport.addChunk(text);
    }
  }

  void dispose() {
    conversation.dispose();
    transport.dispose();
    controller.dispose();
  }
}
```

Owned by a new Riverpod controller (§6), created on wizard entry, disposed via `ref.onDispose` when the wizard route/screen is left — mirrors this app's existing `ref.onDispose(controller.dispose)` idiom already used in `a2ui_providers.dart`.

---

## 4. FSM: one enum, each value carries its own prompt + bindings

Directly follows the article's `_ImageDescriptionRefinementState` pattern, mapped onto `report_wizard_ux_flow.md`'s four steps:

```dart
enum ReportWizardStep {
  where(
    code: 'where',
    title: 'Where?',
    bindings: [WizardBinding(path: '/report/location', key: 'location')],
    rules: '''
Ask how to find the user's area. Offer exactly two ChoicePicker options:
"Use my current location" and "Choose my state". Bind the selection to
/report/location. Do not ask anything else on this screen.''',
  ),
  whatsHappening(
    code: 'whats_happening',
    title: "What's happening?",
    bindings: [WizardBinding(path: '/report/whatsHappening', key: 'whatsHappening')],
    rules: '''
Offer a ChoicePicker with these exact options: "Herd sighting", "Herd
moving toward farmland", "Active confrontation", "Just checking my area".
Bind the selection to /report/whatsHappening.''',
  ),
  whoInvolved(
    code: 'who_involved',
    title: "Who's involved?",
    bindings: [WizardBinding(path: '/report/whoInvolved', key: 'whoInvolved')],
    rules: '''
Offer a ChoicePicker: "Herders & cattle", "Farmers", "Both", "Not sure".
Bind the selection to /report/whoInvolved.''',
  ),
  addDetail(
    code: 'add_detail',
    title: 'Add detail',
    bindings: [WizardBinding(path: '/report/detailText', key: 'detailText')],
    rules: '''
Offer a short optional TextField (placeholder: "Add more detail...") bound
to /report/detailText. Speak/Write buttons are handled by the app outside
this surface — do not generate them yourself.''',
  );

  const ReportWizardStep({required this.code, required this.title, required this.bindings, required this.rules});
  final String code, title, rules;
  final List<WizardBinding> bindings;
  String get surfaceId => 'wizard_$code';
  ReportWizardStep? get next => switch (this) {
    where => whatsHappening,
    whatsHappening => whoInvolved,
    whoInvolved => addDetail,
    addDetail => null, // Create, not another step
  };
}
```

`WizardBinding` mirrors the article's `_SelectionBinding` exactly (`path`, `key`, optional `isList`) — new file `lib/features/report_wizard/domain/wizard_binding.dart`.

**Step 4's Speak/Write buttons are app-owned chrome, not part of the generated surface** — same reasoning as the article's "Show different options" button living outside the surface (`docs/image.png`: "The button is not part of the GenUI Catalog"). The GenUI-generated part of step 4 is only the optional `TextField`; tapping the native "Speak" button opens the existing `MicrophoneButton`-style recording UI (reusing `record`'s permission-on-first-use behavior) and, on completion, calls `GeminiRemoteDataSource.transcribeAudio` then writes the transcript straight into `/report/detailText` via `dataContext.update(...)` — same local-write path a catalog widget would use, just triggered from native code instead of a tap inside the surface.

**A "Show different options" affordance is a natural, optional fit for Steps 2–3** too, in case Gemini's four ChoicePicker options don't match what the user saw — same `dispatchIntent(...)` call as above with an event name like `show_different_options`, handled by an `## Interaction Rules` block in the wizard's system prompt (verbatim pattern from the article, §9) telling Gemini to `updateComponents` on the same `surfaceId` with fresh options, never `createSurface`. Nice-to-have, not required for the MVP wizard.

---

## 5. Catalog for the wizard

Reuse the existing basic catalog subset (`ChoicePicker`, `Text`, `Icon`, `TextField`) — these already support A2UI's standard binding props, no custom `CatalogItem` required for MVP. If the tile-card look from the reference screenshot (icon + label + sublabel tiles, not plain radio rows) is wanted later, build a custom item following the article's `ImageOptionTiles` recipe verbatim (`S.object` schema with an `id` enum, `A2uiSchemas.stringReference()` for the bound selection, a `BoundString`-wrapped widget, confirmed working end-to-end in `docs/image-2.png`) — additive, not required to ship the wizard.

`lib/features/report_wizard/application/report_wizard_catalog.dart`:
```dart
final reportWizardCatalog = BasicCatalogItems.asNoAssetCatalog(
  systemPromptFragments: [reportWizardPromptFragment],
);
```
No `MapView` item here — the wizard never shows the map; only the Result screen does (per the separately-planned `mapViewCatalogItem`, unrelated to this session).

---

## 6. Domain layer: `ReportWizardController` (Riverpod Notifier, plays the article's "service" role)

New file: `lib/features/report_wizard/presentation/providers/report_wizard_controller.dart`

Owns:
- The `ReportWizardSession` instance (created lazily, disposed via `ref.onDispose`).
- Current `ReportWizardStep` (local state — this is UI-flow state, not cross-cutting business state).
- One subscription per binding path (`session.controller.contextFor(step.surfaceId).dataModel.subscribe<Object?>(DataPath(binding.path))`), mirrored into a `Map<String, Object?> answers` — this **is** the chip trail's data source (`docs/image-1.png`'s pattern).
- Navigation:
  - `next()`: validates the current step's binding has a value (unless the step was explicitly skipped), advances the FSM, and — **only if that next step's surface doesn't already exist in the controller** — calls `session.sendText(promptFor(nextStep))` to generate it. Revisiting an already-generated step is a pure local state change, no call.
  - `back()`: pure local state change, no call.
  - `skip()`: advances without requiring a bound value for the current step.
  - `restart()`: disposes the current `ReportWizardSession`, creates a fresh one, resets `answers` and step to `where`.
- Intent events (via `session.dispatchIntent(...)`, §3/§4 — never part of a generated surface):
  - `request_location_permission` (Step 1's "Use my current location" button) → calls `requestLocationPermission()` (the extracted function from the earlier implementation plan's permission-requesters step), then writes the resolved region name into `/report/location` via `dataContext.update(...)` directly — no Gemini round-trip needed for the permission outcome itself, since it's a local fact.
  - `request_microphone_permission` (Step 4's "Speak" button) → same pattern, no round-trip; only the resulting transcript gets written to `/report/detailText`.
- `Future<void> createReport()`: reads `answers`, builds the context block via the extended `ConflictContextBuilder` (§7), calls the **existing** `ReportSubmissionController.submitStructured(...)` (new method, see §7), then disposes the wizard session.

Whether this belongs in a `@riverpod` `Notifier` (this app's established pattern) or a hand-rolled `ChangeNotifier`-backed provider is a judgment call at build time — follow the `Notifier` convention already used everywhere else in this codebase (`OnboardingController`, `ReportSubmissionController`) for consistency, not the article's raw `ChangeNotifier`-based `ViewModel`.

---

## 7. Bridging into the existing (unchanged) report flow

Extend `ConflictContextBuilder.build` (`lib/features/conflict_reporting/data/datasources/remote/conflict_context_builder.dart`) with one new optional parameter, additive only:

```dart
Future<String> build({
  required double lat, required double lng, required String surfaceId,
  required Future<List<Map<String, dynamic>>> Function(double, double) getNearbyConflicts,
  String? placeName, String? reportText, String? actionEventName,
  Map<String, dynamic>? actionContext,
  Map<String, String>? wizardAnswers, // NEW: {whatsHappening, whoInvolved, detailText}
}) async { ... }
```

When `wizardAnswers` is provided, write a `Report:` line assembled from the structured fields (e.g. `Report: Herd moving toward farmland. People involved: Both. Additional detail: "..."`) instead of requiring a single freeform `reportText` — still exactly one line, still plain text, still slots into the existing prompt contract's "Report:" convention with zero changes needed on the Gemini-prompt side (`conflict_tracker_prompt.dart` already just expects a `Report:` line; it doesn't care how that line was assembled).

Add `ReportSubmissionController.submitStructured(Map<String, String> wizardAnswers)` alongside the existing `submitVoice`/`submitText`/`handleActionFollowUp`, funneling into the same private `_run(...)` with `wizardAnswers:` set instead of `reportText:`.

---

## 8. File layout

```
lib/features/report_wizard/                      # new feature, mirrors existing layering
├── application/
│   ├── report_wizard_session.dart                # §3
│   └── report_wizard_catalog.dart                # §5
├── domain/
│   ├── report_wizard_step.dart                   # §4 enum
│   └── wizard_binding.dart                        # §4
├── data/datasources/remote/
│   └── report_wizard_prompt.dart                  # per-step `rules` + shared framing + Interaction Rules block, mirrors conflict_tracker_prompt.dart's structure
└── presentation/
    ├── providers/report_wizard_controller.dart     # §6
    ├── pages/report_wizard_screen.dart              # native chrome: back/next/skip, 4-dot stepper, chip trail row, embeds a genui Surface for the active step
    └── widgets/wizard_chip_trail.dart                # renders `answers` as chips, subscribed outside the Surface per docs/image-1.png
```

Plus the two additive edits: `conflict_context_builder.dart` (§7) and `report_submission_controller.dart` (§7). Everything else in the earlier implementation plan (permission requesters extraction, persona onboarding rewrite, `MapView` `CatalogItem`, `docs/a2ui_gemini_contract.md` map-in-catalog update) is unaffected by this guide and still stands as previously planned.

---

## 9. What this deliberately does NOT change

- The shipped report-generation contract (`docs/a2ui_gemini_contract.md` §1–§7): risk rubric, tone, `share_alert` interception, worked example — all untouched. The wizard only changes *how the `Report:` line gets assembled*, never what happens after.
- `GeminiRemoteDataSource`, `gemini_send_handler.dart`, `handle_share_alert.dart` — untouched.
- The Result screen's component contract (Header/Body/Buttons/`share_alert`) — untouched; it's still produced by the existing `.chat()` flow, just now fed a richer `Report:` line.

---

## 10. Verification once built

1. `fvm dart run build_runner build --delete-conflicting-outputs`, `fvm flutter analyze` clean.
2. Unit-test `ConflictContextBuilder.build(wizardAnswers: ...)` produces the expected `Report:` line shape.
3. Widget-test `ReportWizardController`: stepping forward generates a surface only on first visit to a step (assert the fake session's `sendText` call count), stepping back never calls `sendText`, `answers` map mirrors DataModel writes.
4. Manual run: complete Steps 1–4 with a mix of ChoicePicker taps and one Back-then-different-answer, confirm the chip trail updates live with no visible loading state on taps (data writes are instant, matching `docs/image-1.png`'s behavior), confirm Create produces the same style of Result screen the existing voice/text flow already produces today.
