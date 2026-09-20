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

### Phase 0 — Foundation (blocking, do first) — ✅ DONE (commit `9651fff`)
One agent, no parallelism (everyone else depends on this existing):
- [x] `fvm use 3.47.2` to pin the project's Flutter SDK (see "Tooling convention" above) — do this before anything else
- [x] `fvm flutter create` project skeleton, `pubspec.yaml` with exact versions from `idea/tech_stack.md`
- [x] Package additions beyond the original tech_stack.md list, all pinned and resolved:
  - `flutter_launcher_icons: 0.14.4` (dev) — generates the app icon
  - `flutter_native_splash: 2.4.8` (dev) — generates the splash screen
  - `carousel_slider_plus: 7.1.2` — Track E's onboarding screen carousel
  - `mocktail: 1.0.5` (dev) — mocking for unit tests across all tracks
  - `golden_test: 2.0.1` (dev) — **replaces `golden_toolkit`**: the doc's original `golden_toolkit: 2.0.1` pin doesn't exist on pub.dev (latest is `0.15.0`, discontinued); `golden_test: 2.0.1` is the real, actively-maintained package and is what's now in `pubspec.yaml`
- [x] App icon + splash screen (Material 3, one shared design): shield (safety) + map pin (location) glyph in the app's earth-tone palette (`lib/core/theme/app_colors.dart` — forest green background, cream shield, brown pin). Source art at `assets/icon/app_icon.png` (full icon) and `app_icon_foreground.png` (transparent, adaptive-icon-safe). Generated via `fvm dart run flutter_launcher_icons` and `fvm dart run flutter_native_splash:create`; config lives in `pubspec.yaml`. Splash background (`#FFFDD0` light / `#2B1B0E` dark) matches the app's scaffold background so splash → first frame has no color flash. Regenerate either by rerunning those two commands after editing the source PNGs or the pubspec config.
- [x] `lib/core/` scaffolding: constants, theme (colors/typography from `phase_2_ux_design.md`), error handling, routing shell
- [x] `lib/features/{conflict_reporting,map,weather,onboarding}/` empty layered folders (data/domain/application/presentation) per `phase_2_development_patterns.md` — added `onboarding` too since Track E owns it
- [x] Riverpod wiring (`flutter_riverpod` + `riverpod_annotation`, `build_runner` configured) — codegen verified working
- [x] Drift base `AppDatabase` with the three tables (`Reports`, `ConflictData`, `Cache`) from `phase_2_tech_architecture.md` — empty/migratable, not yet feature-wired
- [x] Static app shell widget (header, dynamic canvas placeholder, persistent footer with mic + text icons) per UX doc Screen 5
- [ ] Firebase project wiring **once you provide credentials** (see "Your responsibilities" — this step blocks on you) — **still pending, blocks Track B**
- [x] `.env` for the Sentry DSN, consumed via `--dart-define-from-file=.env` — no package dependency. `lib/core/config/env.dart` + `.env.example` committed, real `.env` gitignored.
- [x] CI workflow files scaffolded per the DRY "CI/CD Pipeline" design (composite action + reusable `_build_test.yml` + 3 thin workflows) — **not yet pushed to GitHub** since there's no remote yet (see "Your responsibilities" #3)
- [x] Bundled `farmer_herder_conflict.json` as an app asset (`assets/data/`, registered in `pubspec.yaml`) — unblocks Track A immediately
- [x] Verified: `flutter analyze` clean, smoke test passes, `build_runner` codegen succeeds
- [x] Committed as the base branch all feature branches fork from

**Blocked on you before Phase 1 can fully start**: Firebase project + `google-services.json` (Track B needs it), and a GitHub remote (so CI actually runs and Phase 1 worktrees have somewhere to push/merge).

### Phase 1 — Parallel feature tracks
Launch once Phase 0 is merged. Each track = one agent in its own git worktree/branch, touching only its feature folder + its own tests. Sync/merge to base every 60–90 min to catch integration drift early (don't wait until the end).

| Track | Owns (folders) | Delivers | Depends on |
|---|---|---|---|
| **A — Map & Historical Data** | `lib/features/map/**`, `lib/features/conflict_reporting/data/{datasources,models}` for conflict data | Load & parse `farmer_herder_conflict.json` into Drift `ConflictData`, `flutter_map` + `latlong2` rendering with hotspot markers, GPS via `geolocator` (with permission-denied fallback to manual/last-known location) | Phase 0 |
| **B — Voice/Text Reporting + AI** | `lib/features/conflict_reporting/presentation/widgets/{microphone_button,text_input_modal}`, `.../application/usecases/submit_report.dart`, Firebase AI integration | `record` package capture, `firebase_ai` audio streaming to Gemini 2.5 Flash, text-input fallback path, prompt template that injects location + historical context to produce an A2UI JSON blueprint | Phase 0, Firebase creds |
| **C — A2UI / GenUI Rendering** | `lib/features/conflict_reporting/presentation/a2ui/**` | `genui` catalog registration for the MVP component set (Workspace, Container, Header, StatusBanner, MapView tie-in, QuickActionBar, ActionButton, TextBlock) per the priority table in `phase_2_ux_design.md`; renders Low/Medium/High/Offline states from a blueprint JSON | Phase 0 |
| **D — Offline Cache + Share** | `lib/features/conflict_reporting/data/{repositories,datasources/local}`, `share_plus` wiring | Drift `Cache`/`Reports` repository implementations, offline rehydration logic (detect no-network → load last blueprint), `share_plus` pre-filled alert text per UX doc share-sheet copy | Phase 0 |
| **E — Onboarding + Static Shell Polish** | `lib/features/onboarding/**`, `lib/core/theme/**` | 3-screen onboarding (Welcome → Permissions → Tutorial) per UX Screens 2–4 using `carousel_slider_plus` for the swipeable tutorial carousel, permission request/denied states, visual polish of the static frame. App icon/splash are already done (Phase 0) — this track is UI screens only. | Phase 0 |

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
- [ ] Trigger the `deploy-android` CI job (or run it manually) → Firebase App Distribution public link
- [ ] Trigger the `deploy-web` CI job **only if the web stretch goal survived the cut list**
- [ ] GitHub repo made public, all links collected into README
- [ ] Final submission form

---

## CI/CD Pipeline (GitHub Actions) — DRY, composed from shared building blocks

Purpose: catch integration breaks continuously during Phase 1's parallel merges, then give Phase 3/4 a one-click way to ship both required artifacts (Android APK, and web only if it survives the cut list) — without duplicating the "how do we get a working Flutter environment" and "what counts as passing" logic three times over.

**Two shared building blocks, used by everything else — define once, reuse everywhere:**

1. **`.github/actions/setup-flutter/action.yml`** (composite action) — the single source of truth for "set up the pinned Flutter SDK and fetch deps." Reads the version from the committed `.fvmrc` (via `kuhnroyal/flutter-fvm-config-action@v3`) and feeds it to `subosito/flutter-action@v2` with caching enabled, then runs `flutter pub get`. Every workflow below calls this instead of re-declaring setup steps.
2. **`.github/workflows/_build_test.yml`** (reusable workflow, `on: workflow_call`) — the single source of truth for "does this build pass." Uses the composite action, then `flutter analyze` → `flutter test` → `flutter build apk --debug` (sanity build). Any workflow can gate on this by calling it as a job via `uses: ./.github/workflows/_build_test.yml`, instead of re-declaring analyze/test/build steps.

**Three thin workflows compose those two blocks — none of them re-implement setup or the test gate:**

| Workflow | Trigger | Does |
|---|---|---|
| `ci.yml` | every push + PR to `main` | Just calls `_build_test.yml`. This is what must be live from Phase 0 — it's what tells you a Phase 1 track's merge broke something. |
| `deploy-android.yml` | `workflow_dispatch` (manual) — you trigger it deliberately at the 00:00 checkpoint and again before 18:00 if there's a later build | Job 1: calls `_build_test.yml` as a gate. Job 2 (needs job 1): calls the `setup-flutter` composite action, then `flutter build apk --release` (or `--debug` if release signing isn't ready) → upload to Firebase App Distribution via the Firebase CLI or `wu-vincent/firebase-app-distribution-github-action`. |
| `deploy-web.yml` | `workflow_dispatch` (manual), **only wired up if web isn't cut** | Same pattern: gate on `_build_test.yml`, then `setup-flutter` → `flutter build web --release` → publish `build/web` to the `gh-pages` branch (`peaceiris/actions-gh-pages@v4`) or `actions/deploy-pages`. |

Net effect: the Flutter-setup logic exists in exactly one place, the test/build gate exists in exactly one place, and both deploy workflows reuse the same gate `ci.yml` runs on every push — so a manual deploy can never ship something that hasn't already passed the same checks as a normal commit.

**Deploy jobs stay manual-trigger, not automatic on push** — during Phase 1 the repo will get many WIP pushes from parallel tracks; auto-deploying on every push would either spam Firebase App Distribution testers or fail loudly on incomplete branches. You decide when a build is worth shipping.

**FVM in CI**: CI runners are ephemeral (only one Flutter SDK ever installed), so the "always prefix with `fvm`" rule is a local dev-machine concern, not a CI one. The composite action above still sources its version from `.fvmrc`, so there's one pinned-version source of truth shared by local dev and CI — CI just doesn't need the `fvm` CLI wrapper itself since `flutter`/`dart` are already the only SDK on the runner's PATH after setup.

**Secrets this needs in the GitHub repo** (Settings → Secrets and variables → Actions) — **you provision these**, agents can't:
- `FIREBASE_APP_ID` — Android app ID from the Firebase console
- `FIREBASE_SERVICE_ACCOUNT_JSON` (or `FIREBASE_TOKEN`) — credential for the App Distribution upload step
- GitHub Pages: repo Settings → Pages → source set to the `gh-pages` branch (or the Pages environment if using `actions/deploy-pages`) — one-time setup, only needed if web isn't cut

---

## Your responsibilities (cannot be delegated to agents)
These block the plan at specific points — flagged above where relevant:

1. **Firebase project setup** — create the Firebase project, enable the Gemini/Firebase AI Logic API, download `google-services.json`, confirm free-tier limits are active. Blocks Phase 0's Firebase wiring and all of Track B.
2. **Device/emulator access** — install and manually exercise the app during Phase 3 QA (mic permission prompts, GPS prompts, actual voice audio with your accent/environment can't be simulated by an agent).
3. **GitHub repository** — create it (or grant push access), keep it public, enable Pages later only if the web build stretch goal survives.
4. **Firebase App Distribution** — set up the tester group / public link, since this requires your Firebase console access.
5. **CI/CD secrets** — add `FIREBASE_APP_ID` and `FIREBASE_SERVICE_ACCOUNT_JSON`/`FIREBASE_TOKEN` to GitHub Actions secrets, and enable GitHub Pages in repo settings if web isn't cut. See "CI/CD Pipeline" above.
6. **Demo video** — record and narrate it. An agent can write the shot list and script; only you can produce the actual screen recording + voice.
7. **Pitch deck review** — add real team name/branding, sanity-check narrative, since the drafted content is generic.
8. **Judgment calls agents will flag inline** — e.g., exact risk-level thresholds, color tweaks, prompt-tone decisions. Answer these fast so tracks don't stall.
9. **Scope-cut decisions** — if a track is running late past a sync point, you decide whether to cut it (see cut list) or extend its budget by pulling time from another track.
10. **Final submission** — the actual form/link submission on the hackathon platform.

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
4. Full TDD coverage targets (80% unit/widget) — replace with smoke tests on the 6 non-negotiable MVP behaviors only; there isn't runway for the full test pyramid in `phase_2_development_patterns.md`. Where a track does write tests, use `mocktail` for fakes/mocks and `golden_test` only for the highest-value A2UI risk-state widgets (not every component).
5. Onboarding polish/animations — reduce to functional 3 screens, skip transitions
6. Multiple risk states — if truly squeezed, ship Low/High only and cut Medium/Offline-specific styling (keep offline *functionality*, just reuse the last-rendered styling)

Do not cut: voice input, text fallback, map with hotspots, A2UI rendering, share, offline rehydration — these are the demo's spine and what judges were told to expect from `phase_1_approved.md`'s "Minimum Viable for Judges" list.
