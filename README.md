# Farmer-Herders Conflict Tracker

## 🏆 Andela Hackathon 2026 Submission

**Track**: Safety, Reporting & Protection
**Status**: Working proof of concept
**Submission Date**: September 21, 2026

---

## 📌 Problem

The Reactive Crisis: climate-driven desertification forces nomadic herders into farming zones, causing 10,000+ deaths annually in Nigeria's Middle Belt. No centralized early-warning network exists for rural communities — reports travel by rumor and spotty phone calls, after violence has already happened.

## 💡 Solution

A predictive early-warning and community-reporting app that turns environmental, historical, and crowd-sourced data into actionable intelligence — guided end-to-end by GenUI/A2UI over Firebase AI (Gemini), with Riverpod for state management.

Reporting is a short, tap-first **Guided Report Wizard** (Where? → What's happening? → Who's involved? → optional Speak-or-Write detail), so low-literacy users never face a blank form. The wizard's output feeds Gemini a structured context block (location, situation, nearby historical conflicts, weather) which generates a dynamic risk screen — map, headline, recommended actions, and a one-tap share to WhatsApp/SMS/social.

## 🎯 Key Features

- ✅ Guided Report Wizard — tap-only chips for the core report, optional voice/text enrichment via Firebase AI
- ✅ GPS location detection via Geolocator, requested in-context at the wizard's first step
- ✅ Dynamic A2UI screens via GenUI, including a live conflict-hotspot map embedded in the AI-generated surface
- ✅ Social media sharing via Share Plus
- ✅ Offline capability via Drift + SQLite (cached blueprints rehydrate with no network)
- ✅ Weather context via Open-Meteo, injected into the risk assessment

## 📚 Dataset

Historical conflict records come from the [UCDP Georeferenced Event Dataset](https://ucdp.uu.se/downloads/) (Uppsala Conflict Data Program), Nigeria subset, sourced via [HDX](https://data.humdata.org/dataset/a2260243-108d-4df4-a7e6-a010bcbb553f) (`conflict_data_nga.csv`, 10,506 raw events). `dataset/filter_farmer_herder.py` filters this down to 555 farmer-herder-specific records across the Middle Belt (Kaduna, Kano, Plateau, Benue, Nasarawa, Taraba) — non-state conflict events (`type_of_violence == 2`) matched against herder/farmer actor keywords (see `dataset/README.md` for the exact criteria). The filtered output (`dataset/output/farmer_herder_conflict.json`) ships bundled with the app as the historical hotspot layer.

## 📱 Platforms

- **Android**: [Install via Firebase App Distribution](https://appdistribution.firebase.dev/i/9fd9cdc659c86666)
- **Web**: stretch goal — see `docs/a2ui_gemini_contract.md` / `task.md` for current status

## 🛠️ Tech Stack

- Flutter 3.47.2 (pinned via [FVM](https://fvm.app/), see `.fvmrc`)
- Firebase AI SDK 4.0.0 (Gemini)
- GenUI 0.10.3 (A2UI protocol)
- Riverpod 3.4.3
- go_router 18.0.1
- Flutter Map 8.3.2 + OpenStreetMap
- Drift 2.35.0 (SQLite, offline cache)
- Open-Meteo API (weather context)

## 🚀 Getting Started

Requires [FVM](https://fvm.app/) — this project pins Flutter 3.47.2, always run Flutter/Dart commands through `fvm`.

```bash
git clone https://github.com/nosadaniel/farmer_herder_conflict_tracker.git
cd farmer_herder_conflict_tracker
fvm use 3.47.2
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
```

You'll also need `google-services.json` / `firebase_options.dart` (Firebase project config, gitignored — see `task.md`'s CI/CD Pipeline section for how CI restores these from secrets) and a `.env` file (`.env.example` has the required keys) before `fvm flutter run` will boot past Firebase initialization.

## 📂 Project Structure

Feature-based layering (`lib/features/<feature>/{data,domain,application,presentation}`) — see `brainstorm_docs/phase_2_development_patterns.md` for the full convention, and `task.md` for how the build was actually sequenced (parallel feature tracks, then integration).

Key design docs:
- `docs/a2ui_gemini_contract.md` — the frozen A2UI/Gemini contract for the report-generation surface
- `docs/report_wizard_ux_flow.md` / `docs/refactor.md` — the Guided Report Wizard's UX spec and GenUI implementation guide

## 🎥 Demo Video


## 📊 Pitch Deck

[View Pitch Deck](https://docs.google.com/presentation/d/1FJNdxRwUqEMFXstFCM1Z8hvaV3xXLN-H/edit?usp=sharing&ouid=105392615106570971108&rtpof=true&sd=true)

## 📝 Summary

### Track

**Safety, Reporting & Protection** — enabling people to safely report threats and access clear pathways to timely protection (per the hackathon's track definitions). The app lets farmers and herders report sightings/conflicts through a low-friction, tap-first flow and see predictive risk information for their area before violence happens, not just after.

### Information Sources

- **Historical conflict data**: UCDP Georeferenced Event Dataset (Uppsala Conflict Data Program), filtered to 555 Middle Belt farmer-herder records — see the Dataset section above and `dataset/README.md` for the full provenance and filter methodology.
- **Weather/drought context**: [Open-Meteo](https://open-meteo.com/), called client-side, injected into the risk-assessment prompt.
- **Map tiles**: OpenStreetMap, via `flutter_map`.
- **Live report content**: voice/tap/text input from the person using the app in the moment (the Guided Report Wizard) — a new, user-submitted data point layered on top of the historical baseline above, not an independently sourced dataset.
- **Product/UX research**: persona and design decisions (`brainstorm_docs/`) are grounded in publicly documented farmer-herder conflict dynamics in Nigeria's Middle Belt, not primary field research — appropriate for an invention-sprint proof of concept, not a claim of field-validated accuracy.

### Approach to Trust and Accuracy

- **Historical data is the verified baseline.** UCDP is an established, citation-grade academic conflict-event dataset, not crowd-sourced — it anchors the risk model in real, dated, sourced incidents rather than speculation.
- **New user reports are explicitly unverified in this MVP.** Reporting is anonymous (no accounts, no PII collected — see `brainstorm_docs/phase_2_prd.md`'s Security/Privacy section), and reports are trusted at face value with no moderation pipeline. This is a deliberate, disclosed scope cut for the hackathon timeline, not an oversight — `brainstorm_docs/phase_2_prd.md`'s "Open Questions" section flags report verification/moderation as necessary future work before any real deployment.
- **Risk classification is a documented, inspectable rubric, not a black box** — see `docs/a2ui_gemini_contract.md` §3 for the exact HIGH/MEDIUM/LOW criteria (report content plus nearby historical severity/recency), so a judge (or a future contributor) can audit *why* the app assessed a given risk level rather than trusting an opaque score.
- **Data minimization by design**: no location or report content is persisted server-side — the architecture is client-side/offline-first (Drift/SQLite local cache only), and each report is a single stateless call to Firebase AI for that turn's processing, not a stored, cross-referenced profile.

### Use of AI Tools

- **Claude Code** (Anthropic) was used throughout development: architecture planning, implementing the Guided Report Wizard refactor, CI/CD pipeline design and debugging, and fixing on-device issues (App Check/Play Integrity, GoRouter navigation, GenUI surface-error handling) found via real device/emulator testing. `task.md` is the running build log of that process, kept honest rather than cleaned up after the fact.
- **Google Gemini**, via the Firebase AI SDK, is a **core runtime capability of the product itself**, not only a development tool — it powers voice transcription, risk assessment, and the dynamic A2UI screen generation described in `docs/a2ui_gemini_contract.md`. Every report a user submits triggers a live Gemini call; this is central to how the app works, not an add-on.
- Per the hackathon's requirement that the core capstone idea be original and not AI-generated: the problem framing, target track, and initial concept predate AI-assisted implementation (see `brainstorm_docs/phase_1_brainstorm.md`, `idea/idea.md`) — AI tools supported *building* the idea, not originating it.

## 👥 Team

- Nosa Daniel

## 📜 License

MIT License
