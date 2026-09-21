# Product Requirements Document: Farmer-Herders Conflict Tracker

**Version**: 1.1.0  
**Last Updated**: September 21, 2026  
**Phase**: 2 - Product Planning  
**Status**: Draft — realigned to the Guided Report Wizard (see `docs/report_wizard_ux_flow.md`)  
**Author**: Based on idea/ and phase_1_approved.md

---

## 📖 Product Overview

### Product Vision
Empower rural Nigerian communities with a predictive, AI-powered early-warning system that prevents farmer-herder conflicts by transforming real-time reports and environmental data into actionable, lifesaving intelligence accessible to all community members regardless of literacy level.

### Target Users
**Primary**: Community leaders (Ibrahim, Musa personas), Farmers, Herders  
**Secondary**: Local mediation teams, NGO workers, Government officials (future phase)  
**Geographic Focus**: Rural Nigeria, Middle Belt region (Kaduna, Kano, Southern Kaduna)

### Business Objectives
1. Reduce farmer-herder conflict fatalities in target regions by 30% within 12 months
2. Provide a zero-cost, offline-capable solution for rural areas with poor connectivity
3. Demonstrate the effectiveness of A2UI (Agent-to-User Interface) pattern for emergency response applications
4. Win the Andela Hackathon 2026 (Safety, Reporting & Protection track)

### Success Metrics (KPIs)
| Metric | Target | Measurement |
|--------|--------|-------------|
| Active users | 1,000+ | App installations |
| Conflict reports submitted | 500+/month | Reports completed via the Guided Wizard |
| Alert sharing rate | 80% | Social media shares per report |
| False positive rate | <10% | User feedback on alerts |
| Offline usage | 60% | Sessions without network |
| App rating | 4.5+ | User feedback |

---

## 👥 User Personas

### Persona 1: Ibrahim - Community Leader & Farmer
- **Demographics**: 45 years old, Male, Primary education, Farmer, Southern Kaduna
- **Technical Proficiency**: Low (basic phone usage, limited literacy)
- **Goals**: Protect village from conflicts, coordinate with neighboring communities
- **Pain Points**: 
  - Relies on rumors and spotty phone calls for threat information
  - No centralized system to report or verify threats
  - Reactive responses after violence has already occurred
  - Complex tech interfaces are difficult to use
- **User Journey**: 
  1. Opens app → Sees location on map with risk level → taps "Report"
  2. Taps through the Guided Report Wizard: Where? → What's happening? → Who's involved? (all tap-only chips)
  3. Optionally speaks or types a bit more detail, then taps Create
  4. Sees the Result: map + risk headline + alert details
  5. Shares alert to community groups via social media

### Persona 2: Musa - Herder Leader
- **Demographics**: 38 years old, Male, No formal education, Herder, Kano State
- **Technical Proficiency**: Low (basic phone usage)
- **Goals**: Safely move cattle to grazing areas, avoid conflicts with farmers
- **Pain Points**:
  - Needs to monitor grazing routes constantly
  - No way to warn farmers about cattle movement
  - Fear of retaliatory violence
  - No real-time communication with other herders
- **User Journey**:
  1. Opens app → Sees cattle corridor map
  2. Receives alert about farming zones ahead
  3. Adjusts route to avoid conflict areas
  4. Reports safe passage or issues via the same Guided Report Wizard (taps "just checking my area" at Step 2 instead of a sighting)

### Persona 3: Amina - NGO Mediation Worker (Future)
- **Demographics**: 35 years old, Female, University educated, NGO employee
- **Technical Proficiency**: High
- **Goals**: Monitor conflict hotspots, coordinate mediation efforts
- **Pain Points**: Lack of real-time data from rural areas
- **User Journey**: Access web dashboard to view aggregated conflict reports

---

## 🎯 Feature Requirements

### MoSCoW Prioritization

| Feature | Description | User Stories | Priority | Acceptance Criteria | Dependencies |
|---------|-------------|-------------|----------|---------------------|--------------|
| **Guided Report Wizard** | A 4-step, tap-first flow (Where? / What's happening? / Who's involved? / Add detail) is the app's single reporting mechanism, ending in one generated result | As Ibrahim, I want the app to walk me through a few taps so I never face a blank input | **Must** | All 4 steps navigable, chip trail accumulates correctly, Back/Skip work without extra Gemini calls | genui, firebase_ai |
| **Voice Reporting** | Optional voice enrichment at the wizard's final step, additive on top of the structured chips | As Ibrahim, I want to speak extra detail so I don't need to type | **Must** | Voice transcribed accurately, appended to context, mic permission requested in-context | firebase_ai, record |
| **Text Reporting** | Optional text enrichment at the wizard's final step, equal alternative to voice | As a user, I want to type extra detail when speaking is not convenient | **Should** | Text input submitted, processed same as voice | Flutter TextField |
| **GPS Location** | App detects user location in-context at Wizard Step 1 (or falls back to a state picker) | As a user, I want my location auto-detected so reports are accurate | **Must** | Location accurate within 50m, works offline, permission requested only when "Use my location" is tapped | geolocator |
| **Conflict Map** | Display conflict hotspots on interactive map | As a user, I want to see conflict zones on a map to avoid them | **Must** | Map loads in <3s, shows hotspots from dataset | flutter_map, latlong2 |
| **Dynamic A2UI** | UI adapts based on risk level and context | As a user, I want the UI to show relevant actions for my situation | **Must** | UI changes within 2s of context change, offline-capable | genui, firebase_ai |
| **Social Sharing** | Share alerts to any social media app | As a user, I want to share alerts via my preferred platform | **Must** | Share sheet opens, content pre-filled | share_plus |
| **Offline Cache** | App works without network connection | As a user in rural area, I want to use the app offline | **Must** | Last 50 reports cached, A2UI blueprints stored | drift, sqlite3 |
| **Weather Context** | Integrate drought/weather data | As a user, I want weather data considered in risk assessment | **Should** | Weather data fetched, affects risk level | Open-Meteo API |
| **Historical Data** | Load and display historical conflict data | As a user, I want to see past conflicts in my area | **Should** | farmer_herder_conflict.json loaded, visualizable | - |
| **Multi-language** | Support Hausa and English | As a Hausa speaker, I want to use the app in my language | **Could** | Language toggle, all text translated | - |
| **SMS Fallback** | Send alerts via SMS if no internet | As a user, I want SMS alerts if no data | **Won't** | - | - |

---

## 🔄 User Flows

### Flow 1: Report Conflict via the Guided Wizard (Primary Flow)
The wizard *is* the reporting mechanism — the same 4-step sequence runs every time, first report or the hundredth. There is no separate raw voice/text entry point anymore.

1. **App Launch**: User opens app, sees the current risk level (Low/Medium/High) for their last-known area, taps the single **"Report"** CTA
2. **Step 1 — Where?**: Taps "Use my location" (GPS permission requested here, in context, first time only) or "Choose my state" (`ChoicePicker` fallback); chip trail records the result
3. **Step 2 — What's happening?**: Taps one situation chip (herd sighting / moving toward farmland / active confrontation / just checking); chip trail grows
4. **Step 3 — Who's involved?**: Taps one chip (herders & cattle / farmers / both / not sure); chip trail grows
5. **Step 4 — Add detail (optional)**: Taps **Speak** (microphone permission requested here, in context, first time only) or **Write**, or skips straight to Create
6. **Create**: Fires the single Gemini call — accumulated chips + optional transcript/text → context enrichment (location + weather + historical data) → A2UI blueprint generation
7. **Result Render**: genui renders one surface with:
   - Risk level banner (color-coded)
   - Map with incident location
   - 1-2 sentence summary
   - Action buttons (Share, Report to authorities, etc.)
8. **Share Alert**: User taps share button, chooses social media app
9. **Close (✕)**: Clears the chip trail and returns to Step 1, ready for the next report

**Alternative Path**: Back navigation
- Back walks to the previous already-rendered step locally — no extra Gemini call
- Choosing something different on a re-visited step produces a fresh forward turn

**Alternative Path**: Skip
- Available on every step except the Result — skipping a step just omits that chip
- The Create call still runs with whatever chips exist, even if every step was skipped

**Alternative Path**: Offline mode
- If no network: Use cached A2UI blueprint from last online session for the home state
- The wizard still runs fully offline (all steps are local/tap-based); Create queues the report for sync when network returns

**Error States**:
- No GPS and no state chosen: Step 1 can simply be skipped — Gemini receives no location context
- No microphone permission: "Speak" is disabled at Step 4, "Write" remains fully available
- Network error at Create: Show offline indicator, cache accumulated chips locally
- Step 4 text/transcript empty: not an error — Step 4 is optional by design

### Flow 2: View Conflict Hotspots
1. User opens app, map loads with current location
2. Historical conflict data (farmer_herder_conflict.json) displays as heatmap
3. User can tap hotspots to see details (date, severity, type)
4. Weather overlay shows drought-index regions

**Alternative Path**: Filter by date range
**Error State**: Data loading error - show retry button

### Flow 3: Receive Alert (Push Notification - Future)
1. Nearby user reports conflict
2. System calculates proximity
3. Alert notification sent to affected users
4. User taps notification, opens app to see details

---

**Note**: The Guided Report Wizard's tap-only chips (Steps 1-3) are the primary reporting mechanism — they carry the core structured signal with zero typing or speaking required. Voice and text at Step 4 are equally-weighted, optional enrichment on top of that structured signal, not competing primary paths. See `docs/report_wizard_ux_flow.md` for the full spec.

## 📊 Non-Functional Requirements

### Performance
- **App Load Time**: <5 seconds on mid-range Android device
- **Map Render Time**: <3 seconds for initial load
- **A2UI Update Time**: <2 seconds for dynamic UI changes
- **Voice Processing**: <10 seconds for transcription + LLM response
- **Concurrent Users**: Support 1000+ active users (free tier limits)

### Security
- **Authentication**: None for MVP (anonymous reporting)
- **Data Encryption**: Local storage encrypted (Drift default)
- **Privacy**: No PII collected, location data anonymized
- **Compliance**: Follow Google Play data safety requirements

### Compatibility
- **Devices**: Android 8.0+ (API 26+), iOS 14+ (future)
- **Screen Sizes**: 5" to 10" screens supported
- **Orientation**: Portrait primary, landscape supported
- **Accessibility**: 
  - Guided, tap-first wizard interface for low-literacy users
  - High contrast mode support
  - Screen reader compatible

### Accessibility
- **Compliance Level**: WCAG 2.1 AA (where applicable)
- **Specific Requirements**:
  - Every wizard step completable by tap alone; voice/text only ever required at the optional final step
  - Minimum touch target: 48x48dp
  - Color contrast ratio: 4.5:1 minimum

---

## 🔧 Technical Specifications

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **UI Components**: GenUI (A2UI rendering), Flutter Map
- **Styling**: Custom theme matching rural African aesthetic
- **Responsive Design**: Single codebase for Android (web future)

### Backend
- **AI Engine**: Gemini 2.5 Flash via Firebase AI SDK
- **APIs**: Open-Meteo (weather), OpenStreetMap (maps)
- **Serverless**: No backend required for MVP (client-side only)

### Database
- **Local**: SQLite via Drift ORM
- **Schema**: 
  - `reports` table: id, timestamp, location, transcription, risk_level, a2ui_blueprint
  - `conflict_data` table: pre-loaded from farmer_herder_conflict.json
  - `cache` table: A2UI blueprints for offline rehydration

### Infrastructure
- **Hosting**: Firebase App Distribution (APK)
- **Cloud**: None for MVP (all client-side)
- **CI/CD**: GitHub Actions (future)

---

## 📈 Analytics & Monitoring

### Key Metrics
- **User Acquisition**: App installations, daily active users
- **Engagement**: Reports submitted, shares per report, session duration
- **Retention**: Day 7, Day 30 retention rates
- **Performance**: App load time, map render time, API response time
- **Errors**: Crash rate, failed reports, network errors

### Events to Capture
| Event | Description | Data |
|-------|-------------|------|
| app_open | App launched | timestamp, user_id (anonymous) |
| location_detected | GPS fix acquired | lat, lng, accuracy |
| wizard_step_completed | A wizard step was resolved (chip chosen or skipped) | step number, choice or "skipped" |
| wizard_step_back | User navigated back a step | step number |
| voice_report_start | Step 4 recording started | timestamp |
| voice_report_complete | Step 4 recording finished | duration, transcription |
| wizard_create | "Create" tapped, Gemini call fired | chips, has_voice, has_text |
| risk_assessment | Risk level determined | level, confidence |
| a2ui_render | Dynamic UI rendered | blueprint_id, timestamp |
| share_alert | Alert shared | platform, content |
| offline_mode | Offline usage detected | duration |

### Dashboards
- **Overview**: MAU, DAU, installations
- **Engagement**: Reports, shares, session length
- **Performance**: Load times, error rates
- **Geographic**: Conflict reports by region

### Alerting
- **Crash alerts**: Real-time via Sentry
- **Error rate**: Alert if >5% of sessions have errors
- **API failures**: Alert if Open-Meteo API fails

---

## 🚀 Release Planning

### MVP (v1.0) - Hackathon Submission
**Timeline**: September 21, 2026
**Features**:
- [ ] Guided Report Wizard (4-step, tap-first, chip trail, in-context permissions)
- [ ] Voice/text enrichment at Wizard Step 4 via firebase_ai
- [ ] GPS location detection (Wizard Step 1)
- [ ] Conflict hotspot map
- [ ] Dynamic A2UI interface (Wizard Result surface)
- [ ] Social media sharing
- [ ] Offline caching
- [ ] Weather context integration

**Success Criteria**:
- App installable via Firebase App Distribution
- Core user flow works (Guided Wizard → Result → share)
- Offline functionality verified
- Demo video created

### v1.1 - Post-Hackathon (2 weeks)
**Features**:
- Multi-language support (Hausa + English)
- Firestore sync for multi-user reports
- Push notifications for nearby alerts
- Web version deployment

### v1.2 - Expansion (1 month)
**Features**:
- Government authority authentication
- Advanced analytics dashboard
- MCP server integration
- Expanded geographic coverage

### v2.0 - Production (3 months)
**Features**:
- Full backend with user accounts
- Moderation system for reports
- SMS fallback for alerts
- Partnership integrations

---

## ❓ Open Questions & Assumptions

### Open Questions
1. What is the exact format of farmer_herder_conflict.json? Need to verify schema for parsing
2. How will we handle spam/fake reports in MVP? (Current: trust system, future: moderation)
3. What is the optimal risk assessment algorithm? (Current: LLM-based, future: ML model)
4. How will we measure actual conflict reduction? (Partnerships with NGOs needed)

### Assumptions
1. **User Trust**: Users will provide accurate reports for community benefit
2. **Connectivity**: Users have intermittent connectivity (offline-first design)
3. **Device Capability**: Target devices support Flutter and have GPS/microphone
4. **Free Tier Limits**: Gemini free tier (15 RPM, 1500 RPD) sufficient for hackathon demo
5. **Data Accuracy**: Open-Meteo API provides sufficient weather data for Nigeria

---

## 📚 Appendix

### Competitive Analysis
**Direct Competitors**: None identified in Nigerian rural conflict prevention space

**Indirect Competitors**:
- **Ushahidi**: Crowdsourced crisis mapping, but requires internet and form-based reporting
- **ACLED**: Conflict data collection, but not real-time or user-facing
- **WhatsApp Groups**: Currently used, but fragmented and reactive only

**Our Advantages**:
- Voice-first, no forms (lower barrier to entry)
- Offline-capable (works in rural areas)
- Dynamic UI (adapts to context)
- Predictive (not just reactive)

### User Research Findings
- Rural Nigerian farmers/herders prefer voice over text (low literacy)
- Trust in community leaders (Ibrahim, Musa) drives adoption
- WhatsApp is most common social platform, but users want flexibility
- Offline capability is critical (spotty connectivity)

### AI Research Insights
**Round 1 - Concept Validation**: Farmer-herder conflicts in Nigeria causing 10,000+ deaths annually, climate-driven, urgent need for early warning systems

**Round 2 - Feature Prioritization**: Voice input, offline capability, and social sharing ranked highest by similar emergency apps

**Round 3 - Technical Feasibility**: Flutter + firebase_ai + genui stack validated as cost-effective and performant for this use case

**AI-Generated Edge Cases**:
- User speaks in local dialect not understood by LLM
- GPS drift in rural areas causes location errors
- Multiple users reporting same incident (deduplication needed)
- Network returns during offline report submission

**AI-Suggested Improvements**:
- Add voice guidance for first-time users
- Implement report verification system
- Add educational content about conflict prevention

### Glossary
- **A2UI**: Agent-to-User Interface - Dynamic UI generated by AI based on context
- **MCP**: Model Context Protocol - Standard for connecting LLMs to external data/tools
- **GenUI**: Flutter package implementing A2UI protocol
- **ACLED**: Armed Conflict Location & Event Data Project
- **Hausa**: Primary language spoken in Northern Nigeria

---

*Document created: September 20, 2026*  
*Phase: 2 - Product Planning*  
*Based on: idea/idea.md, idea/hackathon_areas.md, idea/tech_stack.md, brainstorm_docs/phase_1_approved.md*
