# ✅ Phase 1 APPROVED: Farmer-Herders Conflict Tracker

**Approved by**: User  
**Date**: September 20, 2026  
**Submission Deadline**: September 21, 2026, 11:59 PM

---

## 🎯 Final Decision

**PROJECT**: Farmer-Herders Conflict Tracker  
**TRACK**: Safety, Reporting & Protection (Track #3 from hackathon_areas.md)  
**STATUS**: APPROVED FOR PHASE 1 IMPLEMENTATION

---

## 📋 MVP Scope (24 Hours)

### ✅ CORE FEATURES (MUST SHIP)

| # | Feature | Implementation | Dependencies |
|---|---------|----------------|--------------|
| 1 | Flutter app with GPS detection | `geolocator: 14.0.3` | ✅ |
| 2 | Voice input for conflict reports | `firebase_ai: 4.0.0` (Gemini audio streaming) | ✅ |
| 3 | Static map with conflict hotspots | `flutter_map: 8.3.2` + `latlong2: 0.10.1` | ✅ |
| 4 | **Dynamic A2UI interface generation** | `genui: 0.10.3` + `firebase_ai: 4.0.0` | ✅ |
| 5 | **Social media sharing** | `share_plus` package | ✅ |
| 6 | Offline data caching | `drift: 2.35.0` + `sqlite3: 3.6.0` | ✅ |
| 7 | Weather context integration | Client-side Open-Meteo API calls | ✅ |

### ❌ DEFERRED (Post-MVP)
- MCP server integration (weather-mcp, osm-spatial-mcp)
- Multi-user synchronization via Firestore
- Web version (GitHub Pages)
- Government authority authentication
- Advanced analytics dashboard
- Multi-language support

---

## 🏗️ Technical Architecture Summary

### Data Flow
```
User Voice Input → firebase_ai (Gemini 2.5 Flash) → 
    [Inject: farmer_herder_conflict.json + Open-Meteo data] →
    A2UI Blueprint (JSON) → genui package → Dynamic UI Render
    ↓
    Hive/Drift Cache (for offline rehydration)
```

### Key Components
1. **Frontend**: Flutter with Riverpod state management
2. **AI Engine**: Firebase AI SDK → Gemini 2.5 Flash
3. **Dynamic UI**: GenUI package rendering A2UI JSON blueprints
4. **Maps**: Flutter Map with OpenStreetMap tiles
5. **Data**: farmer_herder_conflict.json (bundled) + Open-Meteo API (client-side)
6. **Offline**: Drift SQLite database caching A2UI blueprints
7. **Voice**: firebase_ai native audio transcription ($0 free tier)

---

## 🌦️ Weather Data Implementation (MVP)

**Strategy**: Direct client-side Open-Meteo API calls

### Implementation Steps:
1. Flutter app calls Open-Meteo REST API with user's GPS coordinates
2. Extract drought index and weather conditions
3. Inject weather data into LLM prompt context
4. LLM uses weather + historical data to generate A2UI blueprint
5. Refactor to MCP server later (post-MVP)

### Example Prompt Enrichment:
```
User location: 9.0820° N, 8.6753° E (Kaduna)
Weather context: Drought index = 0.85, Rainfall deficit = -45mm
Historical context: 3 conflicts in this sector last month
→ Generate A2UI blueprint for HIGH RISK scenario
```

---

## 📅 Implementation Timeline

### 🕐 Immediate (0-6 hours)
- [ ] Initialize Flutter project
- [ ] Add all dependencies (genui, firebase_ai, flutter_map, drift, etc.)
- [ ] Implement GPS location detection
- [ ] Set up basic Flutter Map with conflict hotspots
- [ ] Load farmer_herder_conflict.json dataset

### 🕑 Core Development (6-18 hours)
- [ ] Implement voice input with firebase_ai
- [ ] Connect to Gemini 2.5 Flash
- [ ] Implement A2UI blueprint generation
- [ ] Integrate genui for dynamic rendering
- [ ] Add Open-Meteo client-side calls
- [ ] Implement social media sharing (`share_plus`)
- [ ] Add Drift offline caching

### 🕒 Finalization (18-24 hours)
- [ ] Test complete user flow
- [ ] Create demo video (show A2UI in action)
- [ ] Draft pitch deck
- [ ] Write README.md
- [ ] Build and package APK
- [ ] Submit to Firebase App Distribution

---

## 🎯 Success Criteria

**Minimum Viable for Judges**:
- [ ] App opens and shows user location on map
- [ ] User can press & hold to report via voice
- [ ] Voice transcription works via firebase_ai
- [ ] LLM generates A2UI blueprint based on context
- [ ] genui renders dynamic UI from blueprint
- [ ] User can share alerts to any social media app
- [ ] App works offline (rehydrates from cache)

**Stretch Goals**:
- [ ] Weather data affects risk level display
- [ ] Multiple conflict hotspots visible on map
- [ ] Smooth A2UI transitions between risk states

---

## 📚 Source Files Used

| File | Purpose |
|------|---------|
| `idea/idea.md` | Original pitch and personas |
| `idea/hackathon_areas.md` | Track selection and deadline |
| `idea/tech_stack.md` | Dependency definitions |
| `idea/frontend_architecture_idea.md` | A2UI architecture |
| `idea/architecture_idea.md` | Full system design |
| `dataset/output/farmer_herder_conflict.json` | Historical conflict data |

---

## ✨ Why This Will Win

1. **Perfect Track Fit**: Directly addresses Safety, Reporting & Protection
2. **Innovative Tech**: A2UI pattern, Zero-Signal Architecture, voice-first
3. **Real Impact**: Solves 10,000+ annual deaths problem
4. **Production Ready**: Uses free tiers, offline-capable, scalable
5. **Judges Love**: Dynamic UI, AI-powered, community network effect

---

*Document created: September 20, 2026*  
*Status: ✅ APPROVED - Ready for Implementation*
