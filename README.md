# Farmer-Herders Conflict Tracker

## 🏆 Andela Hackathon 2026 Submission

**Track**: Safety, Reporting & Protection
**Status**: Working proof of concept
**Submission Date**: September 21, 2026

### 📲 [Install the Android app via Firebase App Distribution](https://appdistribution.firebase.dev/i/9fd9cdc659c86666)

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

- **Android**: [Install via Firebase App Distribution](https://appdistribution.firebase.dev/i/9fd9cdc659c86666) — the primary, fully-featured build
- **Web**: [nosadaniel.github.io/farmer_herder_conflict_tracker](https://nosadaniel.github.io/farmer_herder_conflict_tracker/) — stretch goal, live

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


### Use of AI Tools

- **Claude Code** (Anthropic) was used throughout development: architecture planning, implemention. 
- **Google Gemini**, via the Firebase AI SDK, is a **core runtime capability of the product itself**, not only a development tool — it powers voice transcription, risk assessment, and the dynamic A2UI screen generation.

## Team
- Nosa Daniel
- OluwaKemi

## 📜 License

MIT License
