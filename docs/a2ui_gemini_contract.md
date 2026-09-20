# A2UI / Gemini Contract (frozen before Phase 1 fan-out)

**Status**: source-grounded — read directly from `genui-0.10.3` and `a2ui_core-0.1.1` in the pub cache (`~/.pub-cache/hosted/pub.dev/genui-0.10.3`), not from the illustrative pseudo-JSON in `brainstorm_docs/phase_2_ux_design.md`. That doc's `A2UI_MapView`/`A2UI_Header`/etc. component names **do not exist** in the real package — this doc supersedes that section of the UX doc for implementation purposes.

This is the contract Track B (produces blueprints) and Track C (renders them) both build against, frozen now so those two tracks can run in parallel without waiting on each other.

---

## 1. What genui actually gives us for free

`genui` implements the real A2UI v0.9 wire protocol (`a2ui_core`) end to end. We are **consumers** of this protocol, not designers of a new one:

- **`PromptBuilder.chat(catalog:, systemPromptFragments:)`** generates the *entire* technical system prompt for us: the A2UI message protocol explanation (`createSurface`/`updateComponents`), the JSON-fenced-block output format instructions, the full catalog JSON schema, and common-type schemas. We only supply small **domain-specific** fragments (§3) — never hand-write protocol/format instructions, `PromptBuilder` already does it better and it'll break if we duplicate/contradict it.
- The `.chat()` preset uses `SurfaceOperations.createOnly(dataModel: false)`: every turn creates a **brand-new surface** (no `updateComponents`-only edits to an old surface, no reactive data-model bindings). This matches our use case exactly — each report/action produces a fresh risk-state screen.
- Gemini's output is plain text with ` ```json ... ``` ` fenced blocks (not function/tool calling) — matches `firebase_ai`'s standard streaming text mode, no special SDK config needed.
- Button taps **auto-loop back to Gemini**: `Button`'s `action: {"event": {"name": "...", "context": {...}}}` becomes a `UserActionEvent` → `SurfaceController.handleUiEvent` → `ChatMessage` → `Conversation`'s `onSubmit` stream, which `Conversation` **automatically resends to the LLM** (`controller.onSubmit.listen(sendRequest)` is wired internally). We do not need to hand-build a closed action-vocabulary enum — Gemini names its own events, and whatever it names comes right back to it as the next turn's context.

## 2. Catalog decision for MVP: use the basic catalog, zero custom `CatalogItem`s

`BasicCatalogItems.asNoAssetCatalog()` (excludes audio/image/video, which we don't use) gives us: `Column`, `Row`, `Card`, `Text` (variants `h1`–`h5`, `caption`, `body`; markdown-capable), `Icon` (fixed enum incl. `warning`, `error`, `check`, `info_outline`, `location_on`, `share`, `phone`, `call`), `Button` (variants `primary`/`borderless`, dispatches a named `action.event`), `Divider`, `ChoicePicker`, `Modal`, `Tabs`, `TextField`, `CheckBox`, `Slider`, `DateTimeInput`.

**Decision**: MVP renders every risk state (Low/Medium/High/Offline) using only these — no custom `CatalogItem`. This is a deliberate scope cut from the UX doc's color-coded `A2UI_Header`/`A2UI_RiskLevelIndicator`: none of the basic-catalog widgets accept an arbitrary background color, so "urgent red banner" becomes **icon choice (`warning`/`error`) + bold `h1` text + tone of the copy**, not literal color theming. Distinct risk states (the actual non-negotiable requirement) are still fully achievable this way.

**Stretch, only if Track C has spare time after the MVP catalog works**: register one custom `CatalogItem` (e.g. `RiskBanner`, `level` enum prop) whose `widgetBuilder` picks a real background color from `AppColors` — small, additive, doesn't change the contract below, just gives Gemini one more component name it's allowed to use.

**The live historical-hotspot map (`flutter_map`, Track A) is NOT part of the AI-generated surface.** No map widget exists in the basic catalog, and building a custom interactive-map `CatalogItem` is real effort we're not spending for the 00:00 checkpoint. The map stays a separate, statically-rendered widget (Track A owns it); the AI-generated `Surface` renders as its own section (e.g. a panel above/below the map, or the whole Dynamic Canvas when no map is in view) per the static-frame/dynamic-canvas split in the UX doc. Registering a custom `MapView` `CatalogItem` so Gemini can actually place markers inside its own surface is a plausible post-MVP enhancement, not required.

## 3. Domain-specific `systemPromptFragments` (final text)

This is what Track B passes as `systemPromptFragments` to `PromptBuilder.chat()`. Paste verbatim; `PromptBuilder` wraps it with the protocol/format/catalog sections automatically.

```
You are the on-device AI for the Farmer-Herders Conflict Tracker, a voice-first
early-warning app for rural Nigerian farming and herding communities (Middle
Belt: Kaduna, Kano, Plateau, Benue, Nasarawa, Taraba). Your job each turn is to
read a short situation report plus injected context, decide a risk level, and
generate a small, calm, actionable screen using ONLY the provided component
catalog.

INPUT YOU WILL RECEIVE EACH TURN (as plain text, not a special format):
- Location: latitude/longitude, and a place name if known
- Report: either a fresh voice/text report from the user, or a follow-up
  triggered by the user tapping a button you previously generated (in which
  case you'll see the event name and its context instead of new report text)
- Nearby historical conflicts: up to 5 records within 25km, each with
  distance_km, date, severity (LOW/MEDIUM/HIGH), fatalities, type
- A surfaceId you MUST use verbatim for this turn's createSurface message

RISK CLASSIFICATION (apply this rubric; use judgment, don't overthink it):
- HIGH: the report describes an active/ongoing confrontation, violence,
  weapons, or an immediate advancing threat (e.g. "herd crossing toward
  farms right now") — OR any historical conflict within 5km in the last 12
  months with HIGH severity or fatalities.
- MEDIUM: the report describes a sighting or unusual movement without active
  conflict (e.g. routine grazing, herd spotted at a distance) — OR historical
  conflicts within 15km in the last 24 months, none HIGH severity nearby.
- LOW: no concerning report content and no significant nearby historical
  conflicts, or a routine/safe-passage report.
- If this turn is a follow-up from a button tap (not a new report), keep the
  same risk level as the surface that produced it unless the event context
  gives you a clear reason to change it.

WHAT TO GENERATE:
Build one screen (via createSurface + updateComponents) with, top to bottom:
1. A short headline as a Text (variant "h1"), reflecting the risk level in
   the wording itself (see TONE below) — since you cannot set colors, the
   words and the Icon you choose are what carry urgency.
2. An Icon: "check" for LOW, "info_outline" for MEDIUM, "warning" or "error"
   for HIGH.
3. One or two short Text (variant "body") sentences: what's happening and
   what the user should do. Keep it plain-language — many users have limited
   literacy, so short sentences beat long ones.
4. 1-3 Buttons (variant "primary" for the main action, "borderless" for
   secondary), each with a clear label and an action event name you choose
   (e.g. "report_sighting", "view_safety_tips", "call_mediation"). Always
   include a button with action name exactly "share_alert" whose label is
   "Share Alert" when risk is MEDIUM or HIGH — the app intercepts this one
   itself (see RESERVED EVENT NAMES) instead of sending it back to you, so
   always give it a "context" containing a short "summary" string (one
   sentence, suitable for sharing to WhatsApp/SMS) and the "riskLevel".

TONE (match phase_2_ux_design.md's messaging examples):
- LOW: calm, reassuring. E.g. "No immediate threats. Stay vigilant."
- MEDIUM: cautious, informative. E.g. "Herds reported nearby. Monitor cattle
  routes."
- HIGH: urgent, direct, but never panic-inducing or exaggerated beyond what
  the report/history actually supports. E.g. "Conflict reported nearby. Take
  action now."

RESERVED EVENT NAMES (the app handles these itself, not you — but you choose
when to offer them and what context to attach):
- "share_alert": opens the native share sheet with your provided summary.
  Context MUST include {"summary": "<one sentence>", "riskLevel": "low|
  medium|high"}.
Every other event name you invent is sent back to you as the next turn's
input — treat it as "the user chose this option, continue the conversation."

CONSTRAINTS:
- Never invent a component name outside the provided catalog.
- Never ask the user to type/say something you can't act on — every Button
  must have a concrete, sensible next step.
- No PII: do not ask for or repeat back names, phone numbers, or ID numbers.
- English only for this version.
```

## 4. Runtime wiring (for Track B)

```dart
final catalog = BasicCatalogItems.asNoAssetCatalog(
  systemPromptFragments: [conflictTrackerPromptFragment], // §3 text above
);
final promptBuilder = PromptBuilder.chat(catalog: catalog);
final systemInstruction = promptBuilder.systemPromptJoined();

final controller = SurfaceController(catalogs: [catalog]);
final transport = A2uiTransportAdapter(onSend: _onSendToGemini);
final conversation = Conversation(controller: controller, transport: transport);
```

`_onSendToGemini(ChatMessage message)` is where the actual Firebase AI call happens. **Every turn** (fresh report *or* a button-triggered follow-up) must re-inject the per-turn context block (location, report/event content, nearby historical conflicts, surfaceId) — `message.parts` alone (especially for button follow-ups, which only carry the raw action JSON) is not enough context for Gemini to generate a sensible screen. Build the context block, prepend it as text, call Gemini's `generateContentStream` with `systemInstruction`, and pipe response chunks into `transport.addChunk(chunk)`.

**Voice input is two separate Gemini calls, not one**, to keep transcription and UI-generation independently testable:
1. Send the recorded audio to Gemini with a minimal instruction ("transcribe exactly what is said, output only the transcript") → get plain transcript text.
2. Feed that transcript into step 2 below exactly like a text report — same downstream pipeline, matching PRD Flow 3's "same as voice flow" note.

**Text input** skips step 1 and goes straight to building the context block from the typed text.

**surfaceId convention**: generate one per turn client-side (e.g. `'report_${DateTime.now().millisecondsSinceEpoch}'`) and include it explicitly in the context block as "Use this surfaceId: ...". Don't rely on Gemini inventing a unique one.

## 5. Per-turn context block format (what gets prepended to every Gemini call)

Plain text, not JSON (Gemini reads it fine either way, but plain text is fewer tokens and matches the "not a special format" framing in §3):

```
Location: 9.0820, 8.6753 (Kaduna)
Use this surfaceId: report_1758389421000
Report: "A large herd just crossed the northern stream heading south toward the village farms."
Nearby historical conflicts (within 25km):
- 3.2km, 2024-11, severity HIGH, 12 fatalities, farmer-herder
- 9.8km, 2023-06, severity MEDIUM, 0 fatalities, cattle rustling
```

For a button-triggered follow-up, replace the `Report:` line with:
```
User tapped: "view_safety_tips" (context: {})
```
— everything else (location, surfaceId, historical conflicts) still gets refreshed and re-sent.

## 6. Worked example (HIGH risk, matches idea.md's Ibrahim scenario)

Gemini's expected text response (two fenced JSON blocks):

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
      { "id": "root", "component": "Column", "children": ["icon", "headline", "body", "actions"] },
      { "id": "icon", "component": "Icon", "name": "warning" },
      { "id": "headline", "component": "Text", "variant": "h1", "text": "Conflict reported nearby. Take action now." },
      { "id": "body", "component": "Text", "variant": "body", "text": "A large herd was seen crossing the northern stream toward the village farms. This area has had serious conflicts before." },
      { "id": "actions", "component": "Column", "children": ["shareBtn", "callBtn"] },
      { "id": "shareBtn", "component": "Button", "variant": "primary", "child": "shareText",
        "action": { "event": { "name": "share_alert", "context": { "summary": "Herd crossing toward farms near Kaduna. High risk area.", "riskLevel": "high" } } } },
      { "id": "shareText", "component": "Text", "text": "Share Alert" },
      { "id": "callBtn", "component": "Button", "variant": "borderless", "child": "callText",
        "action": { "event": { "name": "call_mediation", "context": { "riskLevel": "high" } } } },
      { "id": "callText", "component": "Text", "text": "Contact Mediation Patrol" }
    ]
  }
}
```

Useful as: Track C's first fixture for testing the `Surface` widget without a live Gemini call, and Track D's offline-cache test fixture (this is what gets serialized into the `Cache` table for rehydration).

## 7. Track D's job re: actions

`Conversation`'s built-in loop already forwards every non-special event back to Gemini automatically — **no client code needed for that**. The only thing Track D implements by hand is intercepting `share_alert` specifically: listen for `UserActionEvent`s (or the `ConversationEvent` stream) named `share_alert`, pull `context.summary` + `context.riskLevel`, and call `share_plus`'s `Share.share(...)` directly instead of (or in addition to) letting it round-trip to Gemini. Nothing else needs special-casing for MVP — `call_mediation` and everything else just continues the conversation normally.

---

*Frozen for Phase 1. If reality diverges once Track B/C actually integrate against a live Gemini call (e.g. the model doesn't reliably follow the fenced-JSON format, or invents component names outside the catalog), fix it here first and re-sync both tracks — don't let each track patch around it independently.*
