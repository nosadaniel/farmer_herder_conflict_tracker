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
- [x] Firebase project wiring — project created (`farmer-herder-conflict-tracker`), Android + Web apps registered via `flutterfire configure`, `Firebase.initializeApp()` wired into `main.dart`. `google-services.json`/`firebase_options.dart`/`firebase.json` are gitignored (public repo — see "CI/CD Pipeline"); CI reconstructs them from secrets via `.github/actions/restore-firebase-config`. **Still pending**: enabling the Gemini Developer API in Firebase AI Logic (needed before Track B can call Gemini) and adding the three `*_B64` secrets to GitHub once there's a remote.
- [x] `.env` for the Sentry DSN, consumed via `--dart-define-from-file=.env` — no package dependency. `lib/core/config/env.dart` + `.env.example` committed, real `.env` gitignored.
- [x] CI workflow files scaffolded per the DRY "CI/CD Pipeline" design (composite actions for Flutter setup + Firebase config restore, reusable `_build_test.yml` + 3 thin workflows) — **not yet pushed to GitHub** since there's no remote yet (see "Your responsibilities" #3)
- [x] Bundled `farmer_herder_conflict.json` as an app asset (`assets/data/`, registered in `pubspec.yaml`) — unblocks Track A immediately
- [x] Verified: `flutter analyze` clean, smoke test passes, `build_runner` codegen succeeds
- [x] Committed as the base branch all feature branches fork from

**Blocked on you before Phase 1 can fully start**: Firebase project + `google-services.json` (Track B needs it), and a GitHub remote (so CI actually runs and Phase 1 worktrees have somewhere to push/merge).

### Phase 1 — Parallel feature tracks
Launch once Phase 0 is merged. Each track = one agent in its own git worktree/branch, touching only its feature folder + its own tests. Sync/merge to base every 60–90 min to catch integration drift early (don't wait until the end).

| Track | Status | Owns (folders) | Delivers | Depends on |
|---|---|---|---|---|
| **A — Map & Historical Data** | ✅ merged (`22db6a0`) | `lib/features/map/**`, `lib/features/conflict_reporting/data/{datasources,models}` for conflict data | Load & parse `farmer_herder_conflict.json` into Drift `ConflictData`, `flutter_map` + `latlong2` rendering with hotspot markers, GPS via `geolocator` (with permission-denied fallback to manual/last-known location) | Phase 0 |
| **B — Voice/Text Reporting + AI** | ✅ merged (`b6e9362`) | `lib/features/conflict_reporting/presentation/widgets/{microphone_button,text_input_modal}`, `.../application/usecases/submit_report.dart`, Firebase AI integration | Per `docs/a2ui_gemini_contract.md`: `record` capture → two-step Gemini flow (transcribe, then generate A2UI via `genui`'s `Conversation`/`PromptBuilder.chat()`), text-input path skips transcription, per-turn context-block builder (location + nearby historical conflicts + surfaceId) re-injected on every turn including button follow-ups | Phase 0, Firebase creds |
| **C — A2UI / GenUI Rendering** | ✅ merged (`8d6b316`) | `lib/features/conflict_reporting/presentation/a2ui/**` | Per `docs/a2ui_gemini_contract.md`: wire `genui`'s `SurfaceController` + `Surface` widget using `BasicCatalogItems.asNoAssetCatalog()` — **no custom `CatalogItem`s for MVP**, risk states are Icon+Text+Button only, not color-coded. Stretch: one custom `RiskBanner` CatalogItem for real background coloring if time allows. | Phase 0 |
| **D — Offline Cache + Share** | ✅ merged (`ee11204`) | `lib/features/conflict_reporting/data/{repositories,datasources/local}`, `share_plus` wiring | Drift `Cache`/`Reports` repository implementations, offline rehydration logic (detect no-network → load last blueprint), intercept the reserved `share_alert` action event (per `docs/a2ui_gemini_contract.md` §7) and call `share_plus` directly — every other button event needs no special handling, `genui`'s `Conversation` already loops it back to Gemini | Phase 0 |
| **E — Onboarding + Static Shell Polish** | ✅ merged (`c0da0fb`) | `lib/features/onboarding/**`, `lib/core/theme/**` | 3-screen onboarding (Welcome → Permissions → Tutorial) per UX Screens 2–4 using `carousel_slider_plus` for the swipeable tutorial carousel, permission request/denied states, visual polish of the static frame. App icon/splash are already done (Phase 0) — this track is UI screens only. | Phase 0 |

**Lesson learned mid-run**: Track B's agent bypassed its worktree isolation and wrote directly into the main checkout instead of its assigned worktree (confirmed empty when stopped) — root cause is likely that its prompt included the repo's literal absolute path, which it then used for all file operations instead of its actual (different) worktree path. Tracks A/C/D/E, whose prompts used the same pattern, were unaffected, so this wasn't systemic — but worth watching for on any future track launches. Track B's work was recovered manually (reviewed, lint-fixed, committed) rather than lost. Separately, Track D correctly caught that `flutter test` only scans top-level `test/` by default — `phase_2_development_patterns.md`'s "co-locate widget tests under lib/" convention means those tests silently never run; Track C's test was moved to `test/` to fix this (see commit `b6e9362`). **Any future track should put tests under top-level `test/`, mirroring the lib path — not co-located.**

**Another finding (Track A)**: `riverpod_generator` 4.0.9 throws `InvalidTypeException` for any `@riverpod`-annotated function whose return type is a Drift-generated row class (reproduced generically, not specific to one table). Track A worked around it by hand-writing `allConflictDataProvider`/`nearbyConflictsProvider` as plain `FutureProvider`/`FutureProvider.family` instead of codegen. **If Phase 2 integration or any later work adds a codegen'd provider returning a Drift row type directly, expect this to fail — use a plain (non-`@riverpod`) provider instead, or map to a domain entity first.**

**Optional Track F (only if a 6th agent-slot is free and weather is in scope)**: `lib/features/weather/**` — Open-Meteo client-side call, inject drought index into the Track B prompt. Treat as stretch; do not let it block the 00:00 checkpoint.

**Merge discipline**: Track B (produces via Gemini), Track C (renders), and Track D (persists/shares) all build against the frozen contract in **`docs/a2ui_gemini_contract.md`** — system prompt fragments, catalog decision (no custom components for MVP), context-block format, and the worked example. That doc was written after reading the actual `genui`/`a2ui_core` package source (not the illustrative sample in `phase_2_ux_design.md`, which uses component names — `A2UI_MapView`, `A2UI_Header`, etc. — that don't exist in the real package). If any track finds the contract doesn't match what a live Gemini call actually does, fix the doc first and re-sync, don't let tracks silently diverge.

**Codegen discipline**: if a track adds/edits a `@riverpod`-annotated class or a Drift table, it must run `fvm dart run build_runner build --delete-conflicting-outputs` and commit the regenerated `.g.dart` files in the same commit. Note `_build_test.yml` does **not** actually catch a forgotten commit here — it regenerates fresh before analyze/test/build, which overwrites whatever staleness was checked out and lets CI pass either way. So CI passing is not proof the committed `.g.dart` is current; it only proves the *source* still generates and compiles. Since the deploy jobs trust the committed files as-is (no regen step, per your call above), a stale commit here is a silent risk until Phase 2 integration or Phase 3 QA surfaces it as a runtime/compile mismatch. Catch it at review time, not CI time.

### Phase 2 — Integration (serial)

**Architecture for this phase** (confirmed against `riverpod-3.4.3` source, `lib/src/core/base_ref.dart`): `Ref` exposes `onDispose(cb)`, `keepAlive()`, `onCancel(cb)`, `onResume(cb)` — a full lifecycle hook set, so Riverpod *can* own any Dart object's lifecycle, not just app-level business state.

**Refined rule** (your call): that capability doesn't mean it *should*. A UI-owned controller object — `TextEditingController`, `AudioRecorder`, `CarouselSliderController`, and similar — stays in the widget's own `State` so its `dispose()` is tied to the widget's own mount/unmount, which is simpler and safer than replicating that lifecycle through `ref.onDispose`. Everything that *isn't* a UI-owned controller object — cross-cutting business state, anything another widget needs to observe, anything mirroring a stream from elsewhere — is Riverpod's job.

Applying that rule to what Phase 1 actually built:

| Widget | Local state | Verdict |
|---|---|---|
| `MicrophoneButton` | `AudioRecorder`, `_isRecording`, timer | **Unchanged** — `AudioRecorder` is a UI-owned hardware controller; stays local per the refined rule. Only its `onRecordingComplete(bytes)` callback gets wired (at the call site) to `ReportSubmissionController.submitVoice` |
| `TextInputModal` | `TextEditingController`, `_errorText` | **Unchanged** — same reasoning. Its `Navigator.pop(text)` return value gets wired at the call site to `ReportSubmissionController.submitText` |
| `TutorialScreen` | `CarouselSliderController`, `_currentIndex` | **Unchanged** — same reasoning, plus it's already tested and not on the critical path |
| `PermissionsScreen` | `_requesting`, `_requested` | **Unchanged** — plain ephemeral UI feedback, nothing else observes it, already tested |
| `OnboardingFlow` | `_checkingStatus`, `_step` | **Unchanged** — private navigation-within-a-flow state, already tested |
| `A2uiSurfaceView` | `_error`, manual `StreamSubscription<ConversationEvent>` | **Converts** to `ConsumerWidget` — this *is* business state (conversation error), manually mirrored from a stream Riverpod already owns (`conversationProvider`). Becomes a derived `conversationErrorProvider` |

Net effect: only `A2uiSurfaceView` actually changes. Everything else Phase 1 built was already correctly scoped once the UI-owned-controller exception is applied — no rewrite needed, just wiring.

One agent, after all Phase 1 branches are merged — **done, commit `0d1249b`**:
- [x] New `ReportSubmissionController` (`@riverpod` Notifier): owns the end-to-end report-submission lifecycle (idle → processing → rendered/failed — *not* the recording UI state, that stays in `MicrophoneButton`), wraps Track B's `SubmitReport`, injects Track A's real `getNearbyConflicts`/location providers (replacing the placeholder params Track B was built against), and pushes the resulting stream into Track C's `conversationProvider` transport seam. The real `a2uiSendHandlerProvider` implementation (button-tap follow-ups + `share_alert` interception) is wired via a `ProviderScope` override at the app root (`lib/app/wiring/gemini_send_handler.dart`), not by editing `a2ui_providers.dart` directly, to avoid a circular import between the two files
- [x] `A2uiSurfaceView` converted to `ConsumerWidget` (only widget that actually needed converting, per the refined rule above); `MicrophoneButton`/`TextInputModal`/`TutorialScreen`/`PermissionsScreen`/`OnboardingFlow` unchanged, wired at the call site only
- [x] Wired the real end-to-end flow in `lib/main.dart`: GPS → risk context → mic/text → Firebase AI → blueprint → GenUI render → Drift cache write. `AppShell`'s duplicate hardcoded mic button replaced with a composed `footer` slot (real `MicrophoneButton` + text trigger)
- [x] Resolved provider wiring — no conflicts found; each track's providers were cleanly namespaced already
- [x] Offline fallback wired: any live-call failure in `ReportSubmissionController._run` calls `rehydrateFromCache` before surfacing `ReportFailed` — **not yet manually verified on a real device** (that's a Phase 3 QA step, see below)
- [ ] Fix any A2UI component name/prop mismatches between what Track B's prompt asks Gemini to emit and what Track C's catalog registers — **unverified**: no live Gemini call has been exercised yet (Track C/B were built and tested against the frozen contract's worked-example fixture, not a real API response). First live run is a Phase 3 QA task.
- [x] Verified: `flutter analyze` clean, all 33 tests pass, `flutter build apk --debug` succeeds

**Known gap going into Phase 3**: everything above is verified through unit/widget tests and a successful build — nothing has been run on an actual device/emulator yet, so the live Gemini round-trip (does it actually follow the fenced-JSON format? does it stick to the catalog's component names?) and the real offline kill-switch (turn off network mid-session) are both still unverified. This is exactly what Phase 3 is for.

### Post-Phase-2 addition: type-safe routing with `go_router` — done, commit `63c5e26`
- [x] `go_router: 18.0.1` added; `lib/app/routing/{app_routes,app_router}.dart` — one typed route class per screen (`HomeRoute`, `OnboardingWelcomeRoute`, `OnboardingPermissionsRoute`, `OnboardingTutorialRoute`), each with a `path`/`name` constant and a `go(context)` helper. Hand-written, not `go_router_builder`/`TypedGoRoute` codegen — same practical type-safety benefit without an extra codegen dependency, and none of this app's routes take path parameters anyway.
- [x] The `GoRouter` itself lives in a `@riverpod` provider watching `onboardingControllerProvider` — its `redirect` gates `/onboarding*` vs `/`, so there's no local "which screen" state anywhere in the app.
- [x] `OnboardingFlow` (the manual step-switching wrapper) retired — its two jobs (step-switching, "already onboarded" short-circuit) both moved into the router. `main.dart` now uses `MaterialApp.router`.
- [x] Verified: `flutter analyze` clean, 29/29 tests pass (33→29 expected: `OnboardingFlow`'s 4 tests retired with it), debug APK builds.

### Post-Phase-2 addition: `skeletonizer` shimmer loading states — done, commit pending
`skeletonizer: 3.0.0` had been in `pubspec.yaml` since Phase 0 but unused until now.
- [x] `lib/core/widgets/app_skeleton.dart`: a reusable `AppSkeleton` wrapper — the single place `skeletonizer` is configured (brand `ShimmerEffect` using `AppColors.neutral`/`AppColors.background`), composed by feature code rather than each feature calling `Skeletonizer` directly with its own colors.
- [x] `A2uiSurfaceView`'s "nothing rendered yet, waiting on Gemini" state now uses `AppSkeleton` wrapping a fake layout shaped like a typical A2UI response (icon + headline + body text + action buttons, per the contract doc's component composition) instead of a bare `CircularProgressIndicator` — gives an "expectant" sense of the incoming layout. The follow-up-turn case (small corner spinner over *existing* rendered content) stays a plain spinner — skeletons are for "no content yet," not for overlaying content that's already visible.
- [x] Verified: `flutter analyze` clean, all 29 tests pass (updated the loading-state test's assertion to match), debug APK builds.
- Lower-priority/not done: the router's brief onboarding-status-loading spinner and the map's marker-loading state — both resolve fast enough that a skeleton adds little. `AppSkeleton` is there if a later pass wants them.

### Phase 3 — QA + Build → **00:00 checkpoint**
- [x] Manual run-through on a real Android emulator (`sdk gphone64 arm64`, API 33) — done via `adb`-driven taps + screenshots since no device was in your hands at the time. Onboarding (all 3 screens), real OS permission dialogs, the map with real hotspot markers, and the idle-state prompt all confirmed working visually. Commit `ea5338e` fixes what this run found:
  - AndroidManifest.xml had **zero permissions declared** — geolocator silently fell back to the Middle Belt centroid every time, RECORD_AUDIO was missing too. Fixed.
  - Firebase AI Logic calls failed with "App Check token is invalid" — App Check was never activated client-side. Fixed (`FirebaseAppCheck.instance.activate()` in `main.dart` with the debug provider).
  - `ReportSubmissionController` was accidentally `autoDispose` instead of `keepAlive`, inconsistent with every other cross-cutting provider. Fixed.
  - The skeleton loader never showed during actual voice/text submissions (only button-tap follow-ups) since that path bypasses genui's own `isWaiting`. Fixed — `A2uiSurfaceView` now also watches `ReportSubmissionController`'s state.
- [x] App Check debug token `67ba28ec-b80f-4751-acfa-d604f2be122b` registered by you in Firebase Console — confirmed resolved (error signature moved from `403 App attestation failed` to a legitimate Gemini API response).
- [x] **Live Gemini round-trip confirmed working end-to-end.** Registering the token surfaced one more real bug: `gemini-2.5-flash` is deprecated for new projects — Gemini's own error response pointed at `gemini-3.6-flash` as the replacement. Fixed `GeminiRemoteDataSource.defaultModelName`. Re-tested via a real text submission ("Armed herders driving cattle through farmland near Kaduna, farmers confronting them now"): logcat shows a clean 2356-char streamed response, no exceptions, no cache fallback, and the emulator rendered a real Gemini-generated A2UI surface — "Active Conflict Reported" warning card with a Gemini-authored description matching the report and a working "Share Alert" button. This is the first fully-verified live pass through report → Gemini → A2UI-render.
- [x] **Web launch crash fixed.** `fvm flutter run -d chrome` threw `TypeError: Cannot read properties of null (reading 'initialize')` from `firebase-app-check.js` on boot — `FirebaseAppCheck.instance.activate()` defaults its web provider to `ReCaptchaV3Provider` with no site key configured (only Android App Check has been set up). Fixed by scoping activation to `!kIsWeb` in `main.dart`; web now boots cleanly. Chrome-based interactive testing itself is still blocked — no browser-automation tool is available in this environment and screen-recording/accessibility permissions weren't granted for AppleScript-driven testing, so the web path is unverified beyond "it boots."
- [x] **Real bug found + fixed: silent-success bug in offline fallback.** `rehydrateFromCache` was a no-op (returned nothing, threw nothing) when there was no cache — so `ReportSubmissionController`'s catch block always logged "Recovered via cached blueprint" and returned to `ReportIdle` even when nothing had actually been rehydrated, silently swallowing the user's report with zero feedback. Found by wiping the emulator (see below) and submitting before any cache existed. Fixed: `rehydrateFromCache` now returns `bool` (true only on an actual cache hit); the controller only reports recovery when it's real, otherwise surfaces `ReportFailed`. Covered by an updated assertion in `rehydrate_from_cache_test.dart`; full suite (29 tests) passes.
- [x] **Offline mode test — confirmed working end-to-end** (task.md non-negotiable #6). Note: testing required wiping the `Pixel_4_API_35` emulator (ran out of internal storage — 399MB free, install failed; wipe freed 5GB) per your direction, which reset the App Check debug identity — new token `3a8f9d5c-7c6a-45ee-a5e3-be4253dd9b9b` registered by you in Firebase Console. Test sequence: (1) submitted a real report live to seed the cache — Gemini returned a genuine "Area Calm: Low Risk" A2UI surface, cached successfully; (2) disabled wifi+data via `adb shell svc wifi/data disable`; (3) submitted another report — live call failed with a real `SocketException: Failed host lookup: 'firebasevertexai.googleapis.com'` (genuine network-down error, not simulated); (4) caught, `rehydrateFromCache` returned `true`, the cached "Area Calm: Low Risk" surface replayed onto the screen exactly as a live response would. Network re-enabled afterward.
- [x] `flutter build apk --debug` — confirmed working, installs and runs
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

**Four shared building blocks, used by everything else — define once, reuse everywhere:**

1. **`.github/actions/setup-flutter/action.yml`** (composite action) — the single source of truth for "set up the pinned Flutter SDK and fetch deps." Reads the version from the committed `.fvmrc` (via `kuhnroyal/flutter-fvm-config-action@v3`) and feeds it to `subosito/flutter-action@v2` with caching enabled, then runs `flutter pub get`. Every workflow below calls this instead of re-declaring setup steps.
2. **`.github/actions/restore-firebase-config/action.yml`** (composite action) — writes `android/app/google-services.json`, `lib/firebase_options.dart`, and `firebase.json` from base64-encoded GitHub secrets. These three files are **gitignored, not committed** — this is a public hackathon repo and we're keeping the live Firebase project's identifiers out of it, at the cost of needing this restore step everywhere they're needed. Must run before any `flutter analyze`/`test`/`build` step (not just the Android build step) since `main.dart` imports `firebase_options.dart` directly.
3. **`.github/actions/restore-android-signing/action.yml`** (composite action) — writes the release keystore (`android/app/upload-keystore.jks`) and `android/key.properties` from base64 GitHub secrets. Only used by `deploy-android.yml`'s deploy job — `ci.yml`'s debug-only gate never touches this. `android/app/build.gradle.kts` falls back to debug signing when `key.properties` is absent (verified locally), so nothing breaks for tracks building debug without these secrets.
4. **`.github/workflows/_build_test.yml`** (reusable workflow, `on: workflow_call`) — the single source of truth for "does this build pass." Restores the Firebase config, sets up Flutter, regenerates Drift/Riverpod codegen (`dart run build_runner build --delete-conflicting-outputs`), then `flutter analyze` → `flutter test` → `flutter build apk --debug` (sanity build, debug signing, no release keystore needed). Declares the three Firebase secrets it needs via `on.workflow_call.secrets`; callers pass `secrets: inherit` rather than re-listing each one. Any workflow can gate on this by calling it as a job via `uses: ./.github/workflows/_build_test.yml` with `secrets: inherit`, instead of re-declaring analyze/test/build steps. **This is the only job that regenerates codegen** — the `.g.dart` files are committed to git (not gitignored) and both deploy jobs trust them as-is, since they `needs: gate` and this job already validated they're fresh. If a track edits a `@riverpod` provider or Drift table, committing the regenerated `.g.dart` alongside it is on that track, not on CI.

**Three thin workflows compose those blocks — none of them re-implement setup, secret-restoration, or the test gate:**

| Workflow | Trigger | Does |
|---|---|---|
| `ci.yml` | every push + PR to `main` | Just calls `_build_test.yml` with `secrets: inherit`. This is what must be live from Phase 0 — it's what tells you a Phase 1 track's merge broke something. |
| `deploy-android.yml` | `workflow_dispatch` (manual) — you trigger it deliberately at the 00:00 checkpoint and again before 18:00 if there's a later build | Job 1: calls `_build_test.yml` as a gate (`secrets: inherit`). Job 2 (needs job 1): `restore-firebase-config` → `restore-android-signing` → `setup-flutter` → `flutter build apk --release` (real signed build) → upload to Firebase App Distribution via `wu-vincent/firebase-app-distribution-github-action`. |
| `deploy-web.yml` | `workflow_dispatch` (manual), **only wired up if web isn't cut** | Same pattern: gate on `_build_test.yml`, then `restore-firebase-config` → `setup-flutter` → `flutter build web --release` → publish `build/web` to the `gh-pages` branch (`peaceiris/actions-gh-pages@v4`). |

Net effect: the Flutter-setup logic exists in exactly one place, the Firebase-config-restore logic exists in exactly one place, the Android-signing-restore logic exists in exactly one place, the test/build gate exists in exactly one place, and both deploy workflows reuse the same gate `ci.yml` runs on every push — so a manual deploy can never ship something that hasn't already passed the same checks as a normal commit.

**Deploy jobs stay manual-trigger, not automatic on push** — during Phase 1 the repo will get many WIP pushes from parallel tracks; auto-deploying on every push would either spam Firebase App Distribution testers or fail loudly on incomplete branches. You decide when a build is worth shipping.

**FVM in CI**: CI runners are ephemeral (only one Flutter SDK ever installed), so the "always prefix with `fvm`" rule is a local dev-machine concern, not a CI one. The composite action above still sources its version from `.fvmrc`, so there's one pinned-version source of truth shared by local dev and CI — CI just doesn't need the `fvm` CLI wrapper itself since `flutter`/`dart` are already the only SDK on the runner's PATH after setup.

**Secrets this needs in the GitHub repo** (Settings → Secrets and variables → Actions) — **you provision these**, agents can't:
- `GOOGLE_SERVICES_JSON_B64` — `base64 -i android/app/google-services.json | pbcopy` (macOS) after `flutterfire configure` has generated it locally, then paste
- `FIREBASE_OPTIONS_DART_B64` — same idea: `base64 -i lib/firebase_options.dart | pbcopy`
- `FIREBASE_JSON_B64` — `base64 -i firebase.json | pbcopy`
- `ANDROID_KEYSTORE_JKS_B64` — `base64 -i android/app/upload-keystore.jks | pbcopy` (see "Android release signing" below for how to generate the keystore first)
- `ANDROID_KEY_PROPERTIES_B64` — `base64 -i android/key.properties | pbcopy`
- `FIREBASE_APP_ID` — Android app ID from the Firebase console
- `FIREBASE_SERVICE_ACCOUNT_JSON` (or `FIREBASE_TOKEN`) — credential for the App Distribution upload step
- GitHub Pages: repo Settings → Pages → source set to the `gh-pages` branch (or the Pages environment if using `actions/deploy-pages`) — one-time setup, only needed if web isn't cut

---

## Planned CI/CD redesign — reviewed deployments (design now, implement after Phase 1)

Current state above (`ci.yml` builds a debug APK on every push; deploy workflows are `workflow_dispatch`-only) stays as-is through Phase 1 — don't touch these workflow files mid-fan-out. Once Phase 1 lands, switch to:

1. **`ci.yml` becomes lint + format + test only** — drop the `flutter build apk --debug` step from what runs on every push. Steps: `restore-firebase-config` → `setup-flutter` → codegen → `flutter analyze` → `dart format --output=none --set-exit-if-changed .` → `flutter test`. Faster feedback loop; the real build gets exercised for real at deploy time instead of redundantly on every push.
2. **`deploy-android.yml` / `deploy-web.yml` trigger on `push: branches: [main]`** instead of `workflow_dispatch`, and their `deploy` job gets `environment: production` (or split `android-production`/`web-production` if you want to approve them independently). A GitHub Environment with **required reviewers** configured (Settings → Environments) makes the job auto-queue the moment something merges to `main`, then pause for an explicit approval click before it runs the real signed build + upload — same practical control as today's manual dispatch, but a genuine reviewed-deployment story (worth a line in the pitch deck's "production-ready" pitch), and it means a teammate could push while you stay the sole approver.
3. `gate` (the lint/format/test reusable workflow) still runs before `deploy` in both cases — unchanged structurally, just renamed in spirit from "build/test gate" to "lint/format/test gate" now that the build step lives only in the deploy job itself.

**New "Your responsibilities" item for this**: create the GitHub Environment(s) in Settings → Environments and add yourself (and any teammates) as required reviewers. Not needed until this redesign is actually implemented post-Phase-1.

---

## Android release signing

`android/app/build.gradle.kts` reads `android/key.properties` (gitignored) and falls back to debug signing when it's absent — verified locally, so this is safe to set up whenever you have a spare few minutes, no rush relative to Phase 1.

**1. Generate the keystore yourself** (run this in your own terminal, not delegated — you should be the one typing/owning the passwords):
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
It'll prompt for a keystore password, your name/org (cosmetic, doesn't matter for a hackathon), and a key password (can reuse the keystore password when prompted). `android/app/upload-keystore.jks` is already gitignored (`*.jks`).

**2. Create `android/key.properties`** (also gitignored) pointing at it:
```properties
storePassword=<the password you set>
keyPassword=<the password you set>
keyAlias=upload
storeFile=upload-keystore.jks
```

**3. Verify locally**: `fvm flutter build apk --release` should now produce a real signed release APK (check the build log doesn't fall back to debug signing).

**4. Base64-encode both for GitHub secrets** (see the secrets list above): `base64 -i android/app/upload-keystore.jks | pbcopy` → paste as `ANDROID_KEYSTORE_JKS_B64`; same for `android/key.properties` → `ANDROID_KEY_PROPERTIES_B64`.

**Keep the `.jks` file and passwords somewhere durable outside git** (password manager, etc.) — if you lose them, you can't update this app under the same signing identity later. Low-stakes for a one-off hackathon submission, but cheap to do right.

---

## Your responsibilities (cannot be delegated to agents)
These block the plan at specific points — flagged above where relevant:

1. **Firebase project setup** — create the Firebase project, enable the Gemini/Firebase AI Logic API, download `google-services.json`, confirm free-tier limits are active. Blocks Phase 0's Firebase wiring and all of Track B.
2. **Device/emulator access** — install and manually exercise the app during Phase 3 QA (mic permission prompts, GPS prompts, actual voice audio with your accent/environment can't be simulated by an agent).
3. **GitHub repository** — create it (or grant push access), keep it public, enable Pages later only if the web build stretch goal survives.
4. **Firebase App Distribution** — set up the tester group / public link, since this requires your Firebase console access.
5. **CI/CD secrets** — add `GOOGLE_SERVICES_JSON_B64`, `FIREBASE_OPTIONS_DART_B64`, `FIREBASE_JSON_B64`, `ANDROID_KEYSTORE_JKS_B64`, `ANDROID_KEY_PROPERTIES_B64`, `FIREBASE_APP_ID`, and `FIREBASE_SERVICE_ACCOUNT_JSON`/`FIREBASE_TOKEN` to GitHub Actions secrets, and enable GitHub Pages in repo settings if web isn't cut. See "CI/CD Pipeline" and "Android release signing" above.
6. **Generate the Android release keystore** — run the `keytool` command yourself (see "Android release signing"); you should own the passwords, not have an agent generate/see them.
7. **Demo video** — record and narrate it. An agent can write the shot list and script; only you can produce the actual screen recording + voice.
8. **Pitch deck review** — add real team name/branding, sanity-check narrative, since the drafted content is generic.
9. **Judgment calls agents will flag inline** — e.g., exact risk-level thresholds, color tweaks, prompt-tone decisions. Answer these fast so tracks don't stall.
10. **Scope-cut decisions** — if a track is running late past a sync point, you decide whether to cut it (see cut list) or extend its budget by pulling time from another track.
11. **Final submission** — the actual form/link submission on the hackathon platform.

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
