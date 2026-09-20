# Product Requirements Document: Farmer-Herders Conflict Tracker

**Version**: 1.0.0  
**Last Updated**: September 20, 2026  
**Phase**: 2 - Product Planning  
**Status**: Draft  
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
| Conflict reports submitted | 500+/month | Voice reports |
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
  1. Opens app → Sees location on map with risk level
  2. Presses microphone → Reports herd sighting via voice
  3. Sees dynamic UI update with alert details
  4. Shares alert to community groups via social media

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
  4. Reports safe passage or issues to community

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
| **Voice Reporting** | Users can report conflicts via voice input | As Ibrahim, I want to speak my report so I don't need to type | **Must** | Voice transcribed accurately, report logged | firebase_ai, record |
| **Text Reporting** | Users can report conflicts via text input as alternative | As a user, I want to type my report when voice is not convenient | **Should** | Text input submitted, processed same as voice | Flutter TextField |
| **GPS Location** | App automatically detects user location | As a user, I want my location auto-detected so reports are accurate | **Must** | Location accurate within 50m, works offline | geolocator |
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

### Flow 1: Report Conflict (Primary Flow)
1. **App Launch**: User opens app, GPS location detected
2. **Risk Assessment**: App loads and displays current risk level (Low/Medium/High)
3. **Voice Input**: User presses and holds microphone button
4. **Audio Processing**: Audio streamed to firebase_ai for transcription
5. **Context Enrichment**: Transcription + location + weather data sent to Gemini
6. **A2UI Generation**: Gemini generates appropriate UI blueprint
7. **UI Render**: genui renders dynamic interface with:
   - Risk level banner (color-coded)
   - Map with incident location
   - Action buttons (Share, Report to authorities, etc.)
8. **Share Alert**: User taps share button, chooses social media app

**Alternative Path**: Offline mode
- If no network: Use cached A2UI blueprint from last online session
- Queue voice report for sync when network returns

**Alternative Path**: Text input
- User taps text input icon instead of microphone
- User types report description
- Submit button sends text directly to LLM (no transcription needed)

**Error States**:
- No GPS: Show manual location entry, default to last known location
- No microphone permission: Show error, request permission OR show text input alternative
- Network error: Show offline indicator, cache report locally
- Empty input: Show validation error "Please enter a report"

### Flow 2: View Conflict Hotspots
1. User opens app, map loads with current location
2. Historical conflict data (farmer_herder_conflict.json) displays as heatmap
3. User can tap hotspots to see details (date, severity, type)
4. Weather overlay shows drought-index regions

**Alternative Path**: Filter by date range
**Error State**: Data loading error - show retry button

### Flow 3: Text Report
1. **Text Input Mode**: User taps text icon (alternative to microphone)
2. **Type Report**: User enters description in text field
3. **Submit**: User taps submit button
4. **Processing**: Text sent directly to Gemini (no transcription needed)
5. **A2UI Generation**: Same as voice flow - context enrichment, blueprint generation
6. **UI Render**: Same as voice flow - dynamic interface with report details
7. **Share**: Same sharing options as voice reports

**Alternative Path**: Switch to voice
- User can switch from text to voice mid-report
- Text content preserved as fallback

**Error States**:
- Empty input: Show validation "Report cannot be empty"
- Input too long: Truncate or show error (max 500 chars)

### Flow 4: Receive Alert (Push Notification - Future)
1. Nearby user reports conflict
2. System calculates proximity
3. Alert notification sent to affected users
4. User taps notification, opens app to see details

---

**Note**: Voice reporting is the primary, preferred method. Text input is provided as an alternative for users who prefer typing or when voice input is not available.

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
  - Voice-first interface for low-literacy users
  - High contrast mode support
  - Screen reader compatible

### Accessibility
- **Compliance Level**: WCAG 2.1 AA (where applicable)
- **Specific Requirements**:
  - All functionality accessible via voice
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
| voice_report_start | Recording started | timestamp |
| voice_report_complete | Recording finished | duration, transcription |
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
- [ ] Voice reporting with firebase_ai
- [ ] GPS location detection
- [ ] Conflict hotspot map
- [ ] Dynamic A2UI interface
- [ ] Social media sharing
- [ ] Offline caching
- [ ] Weather context integration

**Success Criteria**:
- App installable via Firebase App Distribution
- Core user flow works (voice report → A2UI → share)
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
