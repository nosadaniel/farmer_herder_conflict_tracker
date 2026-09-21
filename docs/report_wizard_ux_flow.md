# Report Wizard UX Flow (supersedes onboarding's old Permissions screen + the static mic/text footer)

**Status**: design sketch, not yet implemented. Supersedes the "separate setup wizard" concept and the persistent mic/keyboard footer described in `brainstorm_docs/phase_2_ux_design.md` Screen 5/6.

**Pattern source**: a Gemini-image-creation reference flow (World setup → Scene type → Story context → Camera & vibe → Visual elements → Create), adapted to this app's domain. Each step narrows input via tap-only choices (chips/`ChoicePicker`/`Button` — no free text field until the very last step), a chip trail at the top shows everything decided so far, and the flow ends in one generated result with a close/restart affordance to run it again.

---

## Why this replaces the earlier plan

The originally-planned standalone "setup wizard" (a one-time screen earning location + mic permission right after onboarding, before the user has done anything) is gone. Instead:

- **This wizard *is* the reporting mechanism** — the same flow runs every time, first report or the hundredth.
- **Location permission is earned at Step 1**, in context, the first time someone actually wants a prediction — not as a separate ritual.
- **Microphone permission is earned lazily**, exactly when the user first taps "Speak" on Step 4 — true just-in-time request.
- The persistent mic+keyboard footer on `MainScreen` is removed entirely, replaced by one CTA that launches this wizard.
- Onboarding (persona/benefit screens) still runs once, content-only, zero permission requests — unchanged from the earlier plan. It ends by dropping the user straight into this wizard for their first report.

---

## Screen-by-screen

```
[Onboarding: 4 persona screens, no permissions]
              |
              v
   ┌─────────────────────┐
   │  STEP 1 — Where?     │   chip trail: (empty)
   │  ─────────────────   │
   │  ○ Use my location   │──▶ requests GPS permission here, in context
   │  ○ Choose my state   │──▶ ChoicePicker: Kaduna / Kano / Plateau /
   │                       │    Benue / Nasarawa / Taraba
   │  [Next]      [Skip]  │
   └─────────────────────┘
              |
              v
   ┌─────────────────────┐
   │  STEP 2 — What's     │   chips: Kaduna State
   │  happening?          │
   │  ○ Herd sighting     │
   │  ○ Herd moving       │
   │    toward farmland   │
   │  ○ Active            │
   │    confrontation     │
   │  ○ Just checking     │
   │    my area           │
   │  [Back] [Next] [Skip]│
   └─────────────────────┘
              |
              v
   ┌─────────────────────┐
   │  STEP 3 — Who's      │   chips: Kaduna State · Herd moving toward farmland
   │  involved?           │
   │  ○ Herders & cattle  │
   │  ○ Farmers           │
   │  ○ Both               │
   │  ○ Not sure           │
   │  [Back] [Next] [Skip]│
   └─────────────────────┘
              |
              v
   ┌─────────────────────┐
   │  STEP 4 — Add detail │   chips: Kaduna State · Herd moving toward farmland · Both
   │  (optional)          │
   │  [🎤 Speak]           │──▶ requests mic permission here, in context (first use only)
   │  [⌨ Write]            │──▶ short free-text field, same validation as today's
   │                       │    TextInputModal
   │  [Skip this step]    │
   │  [✦ Create]           │
   │  [Back]               │
   └─────────────────────┘
              |
              v  (fires the Gemini call: accumulated chips + optional
              |   detail text/transcript → existing report-generation
              |   system prompt + context block)
   ┌─────────────────────┐
   │  RESULT               │
   │  [X close/restart]    │
   │  ─────────────────    │
   │  MapView (catalog     │   same MapView CatalogItem already planned,
   │  item) + risk headline│   camera-state-provider-backed
   │  + 1-2 sentences       │
   │  + action buttons      │   e.g. "Report Sighting" / "View Safety Tips"
   │  + Share Alert button  │   (existing share_alert reserved-event handling,
   │                        │    unchanged)
   └─────────────────────┘
              |
         [X] tapped
              |
              v
      back to STEP 1, chip trail cleared, ready for a new report
```

---

## Behavior notes

- **Chip trail**: native chrome, not GenUI-rendered — accumulates one chip per resolved step, always visible at the top of the wizard so the user can see what's already been decided. Persists across Back navigation.
- **Back**: same as the earlier plan — no extra Gemini call. Each step's screen is a GenUI `Surface` bound to a `Conversation` whose `createOnly` model keeps every previous `surfaceId` around for the session; Back just walks a local index backward through already-rendered surfaces. Choosing something different on a re-visited step naturally produces a fresh forward turn.
- **Skip**: available on every step except the result — skipping just omits that chip and moves on; the final Gemini call still runs with whatever chips exist (mirrors the reference image's per-step Skip button).
- **Step 4's Speak/Write are not mutually exclusive with the structured chips** — they're additive free-form enrichment on top of Steps 1–3's answers, matching the reference flow's own last step (its "Describe the image" step still offers Speak/Write after four structured screens).
- **Voice transcription** reuses today's two-step Gemini flow (`GeminiRemoteDataSource.transcribeAudio` → feed transcript into the context block) — unchanged plumbing, just invoked from Step 4 instead of a standalone mic button.
- **Result screen's action buttons and `share_alert` handling** are unchanged from the current report-generation contract (`docs/a2ui_gemini_contract.md` §3/§7) — only the *input side* (Steps 1–4 replacing a single raw transcript/text) changes what context Gemini receives; the output contract stays the same.
- **Close/restart (X)**: clears the chip trail and local surface history, returns to Step 1. This is the flow's only "start a new report" affordance — the old always-visible mic/keyboard footer is gone.
- **First-ever run**: identical to every subsequent run. There is no separate one-time setup screen — Step 1 happens to be where GPS permission gets requested the first time, and Step 4 happens to be where mic permission gets requested the first time it's used, whichever report that is.

---

## Per-screen wireframes

Text-boxed mockups, same level of detail as the reference image (header, progress stepper, chip trail, question, options, bottom actions). All copy is a draft, not final.

### Step 1 — Where?

```
┌───────────────────────────────────┐
│ ←   Where?                        │
│     Use Next to continue.         │
│                                    │
│   (1)───2───3───4                 │  ← 4-dot stepper, step 1 active
│                                    │
│   [ chip trail: empty ]           │
│                                    │
│   How should we find your area?   │
│                                    │
│   ┌───────────────────────────┐  │
│   │ 📍  Use my current location │  │  ← primary, filled
│   └───────────────────────────┘  │
│   ┌───────────────────────────┐  │
│   │ 🗺️  Choose my state          │  │  ← secondary, outlined
│   └───────────────────────────┘  │
│                                    │
│         [ →  Next ]               │
│         [ ⏭  Skip ]                │
└───────────────────────────────────┘
```

Tapping "Use my current location" triggers the OS location-permission prompt right here (first time only); on grant it auto-advances with a "Location set: Kaduna State" chip. Tapping "Choose my state" advances to an inline `ChoicePicker` sub-screen (same header/stepper, still step 1) listing the six Middle Belt states.

### Step 2 — What's happening?

```
┌───────────────────────────────────┐
│ ←   What's happening?             │
│     Use Next to continue.         │
│                                    │
│   1───(2)───3───4                 │  ← step 1 done (✓), step 2 active
│                                    │
│   [ Kaduna State ]                │  ← chip from step 1
│                                    │
│   What are you seeing?            │
│                                    │
│   ○  Herd sighting                │
│   ●  Herd moving toward farmland  │  ← selected
│   ○  Active confrontation         │
│   ○  Just checking my area        │
│                                    │
│   [ ← Back ] [ → Next ] [ ⏭ Skip ]│
└───────────────────────────────────┘
```

### Step 3 — Who's involved?

```
┌───────────────────────────────────┐
│ ←   Who's involved?               │
│     Use Next to continue.         │
│                                    │
│   1───2───(3)───4                 │  ← steps 1-2 done, step 3 active
│                                    │
│   [ Kaduna State ] [ Herd moving  │
│   toward farmland ]               │  ← chips accumulate, wrap to 2 lines
│                                    │
│   Who's there?                    │
│                                    │
│   ○  Herders & cattle             │
│   ○  Farmers                      │
│   ●  Both                         │  ← selected
│   ○  Not sure                     │
│                                    │
│   [ ← Back ] [ → Next ] [ ⏭ Skip ]│
└───────────────────────────────────┘
```

### Step 4 — Add detail (optional)

```
┌───────────────────────────────────┐
│ ←   Add detail                    │
│     Optional — Create works       │
│     without this too.             │
│                                    │
│   1───2───3───(4)                 │  ← steps 1-3 done, step 4 active
│                                    │
│   [ Kaduna State ] [ Herd moving  │
│   toward farmland ] [ Both ]      │
│                                    │
│   Want to add more? Speak or      │
│   type a few words.               │
│                                    │
│   ┌────────────┐ ┌────────────┐  │
│   │ 🎤  Speak    │ │ ⌨  Write     │  │
│   └────────────┘ └────────────┘  │
│                                    │
│   [ ⏭ Skip this step ]            │
│   [ ✦  Create ]                   │
│   [ ← Back ]                      │
└───────────────────────────────────┘
```

Tapping "Speak" triggers the OS microphone-permission prompt right here (first use only), then a compact recording control (waveform + timer, reusing today's `MicrophoneButton` recording UI) replaces the Speak/Write row in place. Tapping "Write" swaps in a single-line text field (reusing `TextInputModal`'s validation) instead of navigating away.

### Result

```
┌───────────────────────────────────┐
│ ✕                                  │  ← close/restart, top-left
│                                    │
│   ┌───────────────────────────┐  │
│   │                             │  │
│   │      MapView (catalog      │  │
│   │      item — live map,      │  │
│   │      hotspots + user pin)  │  │
│   │                             │  │
│   └───────────────────────────┘  │
│                                    │
│   ⚠  Medium risk nearby           │
│                                    │
│   A herd was reported moving      │
│   toward farmland near Kaduna.    │
│   Monitor cattle routes.          │
│                                    │
│   [ Report Sighting ]             │  ← primary action(s), Gemini-authored
│   [ View Safety Tips ]            │  ← secondary, borderless
│   [ 📤  Share Alert ]              │  ← reserved action, intercepted client-side
│                                    │
└───────────────────────────────────┘
```

Tapping the ✕ clears the chip trail and local surface history, returning to Step 1 for a new report. Everything below the map (headline, body, action buttons, Share Alert) is unchanged from today's existing risk-state surface contract — only the map's presence inside the surface and the richer structured input feeding it are new.

---

## Open items for the next planning pass (not yet decided)

1. Exact Step 2/3 option wording and whether either should support multi-select (`ChoicePicker` supports both single and multi — reference image uses both across its steps).
2. Whether Step 2's answer should influence which options Step 3 offers (e.g. "Active confrontation" might skip straight to urgency-framing) — i.e. is this a fixed 4-step sequence or can Gemini adaptively reorder/skip based on earlier answers, the way it already adaptively skips the location-picker sub-step if GPS was granted.
3. Whether the result screen's "X to restart" should also be reachable as a persistent small control on the result screen itself (always-visible "report again") versus only appearing after a completed result.
