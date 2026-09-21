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

## 👥 Team

- Nosa Daniel

## 📜 License

MIT License
