# Task Plan: Farmer-Herders Conflict Tracker — Hackathon Build

**Source of truth**: `brainstorm_docs/phase_1_approved.md`, `phase_2_prd.md`, `phase_2_tech_architecture.md`, `phase_2_development_patterns.md`, `phase_2_ux_design.md`, `phase_4_delivery_plan.md`, `idea/*.md`, `dataset/output/farmer_herder_conflict.json`

## Hard deadlines (compressed from the original hackathon schedule)
| Checkpoint | Time | Meaning |
|---|---|---|
| **MVP code-complete / ready for testing** | **00:00 tonight** | App builds, installs, and the full voice→A2UI→map→share loop runs on a device/emulator. Bugs are allowed; missing features are not (for MUST items). |
| **Final submission** | **18:00 tomorrow (Sept 21)** | All 5 hackathon artifacts delivered and links collected. |

Everything below is scoped to fit that window. **Scope has been cut harder than the brainstorm docs** (see "Cut list" at the bottom) because the original plan assumed ~24h with a full evening for polish + web build; we have less.

---

## Tooling convention: FVM (Flutter Version Management)
This project is pinned to **Flutter 3.47.2** via `fvm` (already installed locally, confirmed via `fvm list` — no download needed).

- Phase 0 step zero: `fvm use 3.47.2` inside the project root to write `.fvmrc` / `.fvm/` config.
- **Every** Flutter/Dart command in every phase/track, for every agent, goes through fvm — never call the bare binary:
  - `fvm flutter <cmd>` (not `flutter <cmd>`)
  - `fvm dart <cmd>` (not `dart <cmd>`)
  - e.g. `fvm flutter create .`, `fvm flutter pub get`, `fvm flutter build apk`, `fvm dart run build_runner build`
- This applies to all parallel-track agents in Phase 1 too — bake it into each track's prompt so no agent falls back to a system-wide Flutter install.

---

## Non-negotiable MVP (must work by 00:00)
1. App opens → GPS detected → map renders with historical hotspots from bundled `farmer_herder_conflict.json`
2. Press-and-hold mic → voice → Firebase AI (Gemini) transcription → A2UI blueprint generated
3. Text input as fallback path (same pipeline, skip transcription)
4. GenUI renders the A2UI blueprint (Low/Medium/High risk states minimum)
5. Share button → native share sheet with pre-filled alert text
6. Offline: last blueprint rehydrates from Drift cache with no network

**Deferred to "if time allows after 00:00"**: weather (Open-Meteo) context injection, GitHub Pages web build, Hausa localization, Sentry/analytics wiring, animations/polish, full test-pyramid coverage.

---

## Execution model: foundation → parallel tracks → integration → QA/ship

This is a single Flutter codebase, so full unconstrained parallelism causes merge pain. The `phase_2_development_patterns.md` feature-based folder layout (`lib/features/<feature>/{data,domain,application,presentation}`) already gives near-disjoint file ownership per feature — we exploit that to run agents in parallel **git worktrees**, each scoped to one feature folder, merging back at fixed sync points.

```
Phase 0  FOUNDATION           (serial, 1 agent, ~45–60 min)
Phase 1  PARALLEL FEATURES    (5 agents in worktrees, ~3 hrs, sync every ~60–90 min)
Phase 2  INTEGRATION          (serial, 1 agent, ~60–90 min)
Phase 3  QA + BUILD           (serial + you, ~90 min)   → 00:00 checkpoint
Phase 4  SUBMISSION ARTIFACTS (mixed, rest of runway)    → 18:00 checkpoint
```

### Phase 0 — Foundation (blocking, do first)
One agent, no parallelism (everyone else depends on this existing):
- [ ] `fvm use 3.47.2` to pin the project's Flutter SDK (see "Tooling convention" above) — do this before anything else
- [ ] `fvm flutter create` project skeleton, `pubspec.yaml` with exact versions from `idea/tech_stack.md`
- [ ] `lib/core/` scaffolding: constants, theme (colors/typography from `phase_2_ux_design.md`), error handling, routing shell
- [ ] `lib/features/{conflict_reporting,map,weather}/` empty layered folders (data/domain/application/presentation) per `phase_2_development_patterns.md`
- [ ] Riverpod wiring (`flutter_riverpod` + `riverpod_annotation`, `build_runner` configured)
- [ ] Drift base `AppDatabase` with the three tables (`Reports`, `ConflictData`, `Cache`) from `phase_2_tech_architecture.md` — empty/migratable, not yet feature-wired
- [ ] Static app shell widget (header, dynamic canvas placeholder, persistent footer with mic + text icons) per UX doc Screen 5
- [ ] Firebase project wiring **once you provide credentials** (see "Your responsibilities" — this step blocks on you)
- [ ] `.env` for the Sentry DSN (your preference), consumed via Flutter's native `--dart-define-from-file=.env` — **no package dependency** (not `flutter_dotenv`). Read it at compile time with `String.fromEnvironment('SENTRY_DSN')`. Gitignore `.env`, commit a blank `.env.example`. Firebase/Open-Meteo/OSM don't need `.env` — see earlier discussion.
- [ ] Commit as the base branch all feature branches fork from

### Phase 1 — Parallel feature tracks
Launch once Phase 0 is merged. Each track = one agent in its own git worktree/branch, touching only its feature folder + its own tests. Sync/merge to base every 60–90 min to catch integration drift early (don't wait until the end).

| Track | Owns (folders) | Delivers | Depends on |
|---|---|---|---|
| **A — Map & Historical Data** | `lib/features/map/**`, `lib/features/conflict_reporting/data/{datasources,models}` for conflict data | Load & parse `farmer_herder_conflict.json` into Drift `ConflictData`, `flutter_map` + `latlong2` rendering with hotspot markers, GPS via `geolocator` (with permission-denied fallback to manual/last-known location) | Phase 0 |
| **B — Voice/Text Reporting + AI** | `lib/features/conflict_reporting/presentation/widgets/{microphone_button,text_input_modal}`, `.../application/usecases/submit_report.dart`, Firebase AI integration | `record` package capture, `firebase_ai` audio streaming to Gemini 2.5 Flash, text-input fallback path, prompt template that injects location + historical context to produce an A2UI JSON blueprint | Phase 0, Firebase creds |
| **C — A2UI / GenUI Rendering** | `lib/features/conflict_reporting/presentation/a2ui/**` | `genui` catalog registration for the MVP component set (Workspace, Container, Header, StatusBanner, MapView tie-in, QuickActionBar, ActionButton, TextBlock) per the priority table in `phase_2_ux_design.md`; renders Low/Medium/High/Offline states from a blueprint JSON | Phase 0 |
| **D — Offline Cache + Share** | `lib/features/conflict_reporting/data/{repositories,datasources/local}`, `share_plus` wiring | Drift `Cache`/`Reports` repository implementations, offline rehydration logic (detect no-network → load last blueprint), `share_plus` pre-filled alert text per UX doc share-sheet copy | Phase 0 |
| **E — Onboarding + Static Shell Polish** | `lib/features/onboarding/**`, `lib/core/theme/**` | 3-screen onboarding (Welcome → Permissions → Tutorial) per UX Screens 2–4, permission request/denied states, visual polish of the static frame | Phase 0 |

**Optional Track F (only if a 6th agent-slot is free and weather is in scope)**: `lib/features/weather/**` — Open-Meteo client-side call, inject drought index into the Track B prompt. Treat as stretch; do not let it block the 00:00 checkpoint.

**Merge discipline**: because Track B (voice/text) *produces* the blueprint and Track C (A2UI) *consumes* it, and Track D *persists* it, agree the blueprint JSON schema **before** Phase 1 starts (lift it directly from the sample in `phase_2_ux_design.md` §"Sample A2UI Blueprint"). That schema is the contract between B, C, and D — freezing it up front is what lets those three run in parallel without waiting on each other.

### Phase 2 — Integration (serial)
One agent, after all Phase 1 branches are merged:
- [ ] Wire the real end-to-end flow: GPS → risk context → mic/text → Firebase AI → blueprint → GenUI render → Drift cache write → Share
- [ ] Resolve provider wiring conflicts (multiple tracks will have added Riverpod providers independently)
- [ ] Kill-switch check: turn off network mid-session, confirm offline rehydration actually renders the last cached blueprint
- [ ] Fix any A2UI component name/prop mismatches between what Track B's prompt asks Gemini to emit and what Track C's catalog registers

### Phase 3 — QA + Build → **00:00 checkpoint**
- [ ] Manual run-through of the primary flow (voice) and alternate flow (text) on a real device or emulator — **you drive this**, agent fixes bugs live
- [ ] Offline mode test
- [ ] `flutter build apk` (debug is fine for App Distribution testing unless you want release signing)
- [ ] Fix anything blocking install/launch/crash
- [ ] Tag/commit the state that hits the 00:00 bar even if rough — this is your fallback if later hours go sideways

### Phase 4 — Submission artifacts → **18:00 checkpoint**
Can run partly in parallel with late Phase 3 polish:
- [ ] README.md (template already drafted in `phase_4_delivery_plan.md`)
- [ ] Pitch deck (10-slide structure already drafted in `phase_4_delivery_plan.md` and `phase_3_pitch_deck.md`)
- [ ] Demo video script (agent can draft the 2–5 min shot list/voiceover script; **you record it**)
- [ ] Firebase App Distribution upload + public link
- [ ] GitHub repo made public, all links collected into README
- [ ] Final submission form

---

## Your responsibilities (cannot be delegated to agents)
These block the plan at specific points — flagged above where relevant:

1. **Firebase project setup** — create the Firebase project, enable the Gemini/Firebase AI Logic API, download `google-services.json`, confirm free-tier limits are active. Blocks Phase 0's Firebase wiring and all of Track B.
2. **Device/emulator access** — install and manually exercise the app during Phase 3 QA (mic permission prompts, GPS prompts, actual voice audio with your accent/environment can't be simulated by an agent).
3. **GitHub repository** — create it (or grant push access), keep it public, enable Pages later only if the web build stretch goal survives.
4. **Firebase App Distribution** — set up the tester group / public link, since this requires your Firebase console access.
5. **Demo video** — record and narrate it. An agent can write the shot list and script; only you can produce the actual screen recording + voice.
6. **Pitch deck review** — add real team name/branding, sanity-check narrative, since the drafted content is generic.
7. **Judgment calls agents will flag inline** — e.g., exact risk-level thresholds, color tweaks, prompt-tone decisions. Answer these fast so tracks don't stall.
8. **Scope-cut decisions** — if a track is running late past a sync point, you decide whether to cut it (see cut list) or extend its budget by pulling time from another track.
9. **Final submission** — the actual form/link submission on the hackathon platform.

---

## How to actually run Phase 1 in parallel
When Phase 0 is merged and the blueprint schema is frozen, either:
- Launch 5 `Agent` calls (one per track) with `isolation: "worktree"` so each gets its own git worktree and they can't stomp on each other's file writes, or
- If you want deterministic fan-out/merge-back with progress tracking, ask to run it as a `Workflow` (pipeline per track → integration stage) instead of ad hoc agent calls.

Either way, each track's prompt should pin: the folder it owns, the blueprint JSON contract, the relevant section of `phase_2_development_patterns.md` (TDD/layering rules), and explicit instruction *not* to touch files outside its folder.

---

## Cut list (apply top-down if behind schedule)
1. Web version / GitHub Pages deployment — drop first, Android APK is the required artifact
2. Weather (Open-Meteo) context — nice-to-have risk signal, not core loop
3. Hausa localization, Sentry, Firebase Analytics — defer entirely
4. Full TDD coverage targets (80% unit/widget) — replace with smoke tests on the 6 non-negotiable MVP behaviors only; there isn't runway for the full test pyramid in `phase_2_development_patterns.md`
5. Onboarding polish/animations — reduce to functional 3 screens, skip transitions
6. Multiple risk states — if truly squeezed, ship Low/High only and cut Medium/Offline-specific styling (keep offline *functionality*, just reuse the last-rendered styling)

Do not cut: voice input, text fallback, map with hotspots, A2UI rendering, share, offline rehydration — these are the demo's spine and what judges were told to expect from `phase_1_approved.md`'s "Minimum Viable for Judges" list.
