# Technical Architecture Document: Farmer-Herders Conflict Tracker

**Version**: 1.1.0  
**Last Updated**: September 21, 2026  
**Phase**: 2 - Product Planning  
**Status**: Draft — realigned to the Guided Report Wizard (see `docs/report_wizard_ux_flow.md`)  
**Author**: Based on idea/architecture_idea.md, idea/tech_stack.md, brainstorm_docs/phase_2_prd.md
**Related Document**: phase_2_development_patterns.md

---

## 🏗️ System Overview

### Purpose
The Farmer-Herders Conflict Tracker is a mobile-first, AI-powered early-warning system that enables rural Nigerian communities to report, visualize, and share conflict threats in real-time using voice input and dynamic interfaces. The system is designed to work offline in areas with poor connectivity while leveraging free-tier cloud services when available.

### Scope
This document covers the complete technical architecture for the MVP (v1.0) including:
- Flutter mobile application (Android)
- Client-side AI integration (Firebase AI → Gemini 2.5 Flash)
- Dynamic UI rendering (GenUI A2UI protocol)
- Geospatial mapping (Flutter Map + OpenStreetMap)
- Offline data persistence (Drift ORM + SQLite)
- Social media sharing (Share Plus)
- Weather data integration (Open-Meteo API)

### Alignment with PRD
This architecture directly supports the PRD requirements:
- ✅ Voice reporting via firebase_ai
- ✅ GPS location detection via geolocator
- ✅ Dynamic A2UI via genui + firebase_ai
- ✅ Social media sharing via share_plus
- ✅ Offline capability via drift + sqlite3
- ✅ Weather context via Open-Meteo client calls

---

## 🗺️ Architecture Diagram

### High-Level Diagram (Text Description)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FLUTTER MOBILE APP                                │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  ONBOARDING (content-only)          GUIDED REPORT WIZARD              │  │
│  │  ┌─────────────┐    ┌───────────────────────┐    ┌───────────────┐ │  │
│  │  │  Persona/   │    │ Stepper + Chip Trail   │    │ A2UI WORKSPACE │ │  │
│  │  │  benefit    │───▶│ Steps 1-4 (tap-first,  │───▶│ (Result surface,│ │  │
│  │  │  screens    │    │ Speak/Write @ Step 4)  │    │  GenUI Rendered)│ │  │
│  │  └─────────────┘    └───────────┬────────────┘    └───────┬────────┘ │  │
│  │                                 │                  ┌──────┴───────┐  │  │
│  │                                 │                  │ Share Button │  │  │
└─────────────────────────────────────┼──────────────────┴──────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    FIREBASE AI SDK (Client-Side)                        │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Audio Stream → Gemini 2.5 Flash (Free Tier)                        │  │
│  │  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐   │  │
│  │  │ Audio Input  │◄───┤ Transcription │◄───┤ Voice Recording   │   │  │
│  │  └──────────────┘    └──────┬───────┘    └──────────────────┘   │  │
│  │                         │                                      │  │
│  │                         ▼                                      │  │
│  │  ┌─────────────────────────────────────────────────────────┐   │  │
│  │  │  A2UI Blueprint Generation (JSON)                        │   │  │
│  │  │  - Risk level assessment                                   │   │  │
│  │  │  - Map coordinates                                         │   │  │
│  │  │  - Action recommendations                                  │   │  │
│  │  └─────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────────────────┘
                                 │
                    ┌────────────────────────┬────────────────────────┐
                    │                        │                        │
                    ▼                        ▼                        ▼
           ┌────────────────┐      ┌────────────────┐      ┌────────────────┐
           │  Open-Meteo API │      │ farmer_herder   │      │ Hive/Drift     │
           │  (Weather Data) │      │ conflict.json   │      │ (Offline Cache)│
           │                 │      │ (Historical)     │      │                │
           └────────────────┘      └────────────────┘      └────────────────┘
```

### Key Interactions
1. **User → App**: Structured tap choices from the Guided Report Wizard (location, situation, who's-involved chips) plus optional voice/text enrichment at the wizard's last step; GPS/mic permissions requested in-context at Steps 1 and 4 respectively, not during onboarding
2. **App → Firebase AI**: Audio stream for transcription (Step 4 only) + LLM processing of the full context block
3. **Firebase AI → App**: A2UI JSON blueprint stream
4. **App → Open-Meteo**: Weather data request (client-side)
5. **App → GenUI**: A2UI blueprint rendering
6. **App → Drift**: Local caching for offline rehydration
7. **App → Share Plus**: Social media sharing
8. **App → OpenStreetMap**: Map tiles rendering

---

## 🛠️ Technology Stack

### Core Dependencies (from idea/tech_stack.md)

#### 🔥 Firebase & Client-Side AI Inner Core
| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | 4.15.0 | Initializes core Firebase services in Flutter |
| cloud_firestore | 6.10.0 | Handles real-time multi-user crowdsourced incident tracking |
| firebase_ai | 4.0.0 | Google's native serverless client-to-Gemini streaming engine |

#### 🧠 Dynamic Presentation Engine
| Package | Version | Purpose |
|---------|---------|---------|
| genui | 0.10.3 | Progressive parser implementing the official A2UI layout protocol |

#### 🗺️ Open Geospatial & Open Maps
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_map | 8.3.2 | Vendor-free, keyless map client loaded via OpenStreetMap grids |
| latlong2 | 0.10.1 | Essential mathematical utilities for managing GPS coordinates |

#### 🎙️ Hardware & Sensor Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| record | 7.1.1 | High-efficiency cross-platform microphone intake engine |
| geolocator | 14.0.3 | Automated user telemetry grab upon application launch |
| share_plus | 13.3.0 | Cross-platform social media sharing capability |
| logger | 2.8.0 | Logging |
| skeletonizer | 3.0.0 | UI shimmer |


#### 💾 Modern Relational Offline Cache
| Package | Version | Purpose |
|---------|---------|---------|
| drift | 2.35.0 | High-performance, type-safe SQLite relational database core |
| path_provider | 2.1.6 | Native asynchronous database connector utilities for Flutter |
| path | 1.9.1 | for android/ios/web |
| drift_flutter | 0.3.1 | Native asynchronous database connector utilities for Flutter |
| sqlite3 | 3.6.0 | SQLite database |

#### 🏗️ Presentation State Management (Riverpod)
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | 3.4.3 | Compile-safe, highly reactive state management framework |
| riverpod_annotation | 4.0.7 | Modern syntax attributes for code-generated providers |

#### 📊 Monitoring & Analytics
| Package | Version | Purpose |
|---------|---------|---------|
| sentry_flutter | 9.30.0 | Crash reporting |
| firebase_analytics | 12.6.0 | User engagement tracking (iOS) |
| firebase_analytics_web | 0.6.1+13 | User engagement tracking (Web) |

### Dev Dependencies (from idea/tech_stack.md)
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_test | sdk: flutter | Flutter test framework |
| drift_dev | 2.35.0 | Generates safe serialization tables and database schema |
| riverpod_generator | 4.0.9 | Compiles riverpod annotations into functional type-safe providers |
| build_runner | 2.16.1 | Code generation framework trigger |
| golden_toolkit | 2.0.1 | UI components testing |

---

## 🧩 System Components

| Component | Description | Responsibilities | Dependencies |
|-----------|-------------|-----------------|--------------|
| **Mobile App** | Flutter cross-platform application | User interface, voice/text input, map display | Flutter, Riverpod |
| **Voice Processor** | Audio capture and streaming | Record audio, stream to Firebase AI | record, firebase_ai |
| **Text Processor** | Text input handling | Capture text, send to LLM for processing | Flutter TextField, firebase_ai |
| **AI Engine** | Client-side LLM integration | Process wizard chips plus optional voice/text enrichment, generate A2UI, assess risk | firebase_ai, Gemini 2.5 Flash |
| **A2UI Renderer** | Dynamic UI engine | Parse A2UI JSON, render components | genui |
| **Map Engine** | Geospatial display | Render maps, show hotspots, calculate routes | flutter_map, latlong2 |
| **Weather Service** | Climate data provider | Fetch drought index, rainfall data | http, Open-Meteo API |
| **Data Cache** | Offline persistence | Store reports, A2UI blueprints, conflict data | drift, sqlite3 |
| **Share Manager** | Social sharing | Open share sheet, pre-fill content | share_plus |
| **GPS Service** | Location detection | Get coordinates, track movement | geolocator |

---

## 💾 Data Architecture

### Database Schema (Drift/SQLite)

```dart
// Tables defined in Drift

@DriftDatabase(tables: [Reports, ConflictData, Cache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
}

// Reports table - User-submitted conflict reports
@DriftTable()
class Reports {
  @DriftColumn(primaryKey: true, autoIncrement: true)
  int id;
  
  @DriftColumn()
  DateTime timestamp;
  
  @DriftColumn()
  double latitude;
  
  @DriftColumn()
  double longitude;
  
  @DriftColumn()
  String transcription; // Voice report text
  
  @DriftColumn()
  String riskLevel; // LOW, MEDIUM, HIGH
  
  @DriftColumn()
  String a2uiBlueprint; // JSON string for offline rehydration
  
  @DriftColumn()
  bool synced; // Whether report synced to server (future)
}

// ConflictData table - Pre-loaded historical data
@DriftColumn()
class ConflictData {
  @DriftColumn(primaryKey: true)
  int id;
  
  @DriftColumn()
  DateTime date;
  
  @DriftColumn()
  double latitude;
  
  @DriftColumn()
  double longitude;
  
  @DriftColumn()
  String type; // e.g., "farmer-herder", "cattle rustling"
  
  @DriftColumn()
  String severity; // LOW, MEDIUM, HIGH
  
  @DriftColumn()
  int fatalities;
  
  @DriftColumn()
  String locationName;
}

// Cache table - A2UI blueprints for offline
@DriftColumn()
class Cache {
  @DriftColumn(primaryKey: true)
  String key; // e.g., "kaduna_latest_threat"
  
  @DriftColumn()
  String value; // JSON blueprint
  
  @DriftColumn()
  DateTime timestamp;
  
  @DriftColumn()
  DateTime expiresAt;
}
```

### Data Flows

```
1. Voice Report Flow:
   User → Record Package → Firebase AI → Transcription → Gemini → A2UI Blueprint → Drift Cache → GenUI Render

2. Text Report Flow:
   User → TextField → Input Text → Send to Firebase AI → Process Text → Gemini → A2UI Blueprint → Drift Cache → GenUI Render

3. Weather Context Flow:
   User Location → Open-Meteo API → Weather Data → LLM Context → Risk Assessment

4. Offline Rehydration Flow:
   App Launch → Check Network → If Offline → Load from Drift Cache → GenUI Render → Normal Operation

5. Social Sharing Flow:
   User Tap Share → Share Plus Package → Native Share Sheet → User Selects App → Content Shared

6. Conflict Data Flow:
   App Launch → Load farmer_herder_conflict.json → Parse JSON → Display on Map → Cache in Drift
```

### Storage Requirements
- **Reports**: ~1KB per report, estimate 500 reports = 0.5MB
- **Conflict Data**: farmer_herder_conflict.json ~2-5MB (pre-loaded)
- **A2UI Cache**: ~5KB per blueprint, estimate 50 cached = 0.25MB
- **Total**: ~6MB storage required

### Data Privacy
- **No PII**: No personally identifiable information collected
- **Anonymized**: Location data stored locally only, not linked to identity
- **Local-Only**: All data stored on device for MVP (no cloud sync)
- **Deletion**: Users can clear cache/data from app settings

---

## ☁️ Infrastructure

### Hosting
- **MVP**: Firebase App Distribution (for APK hosting)
- **Future**: GitHub Pages (web version), Google Play Store

### Scaling Strategy
- **MVP**: No scaling needed (client-side only, free tier limits)
- **Post-MVP**: 
  - Add Firestore for multi-user sync
  - Implement rate limiting
  - Add CDN for static assets

### CI/CD Pipeline (Future)
```
GitHub Push → GitHub Actions → Build APK → Run Tests → Deploy to Firebase App Distribution
```

### Monitoring
- **Crash Reporting**: Sentry Flutter integration
- **Error Tracking**: All errors logged with context
- **Performance**: App load time, map render time metrics
- **Usage**: Firebase Analytics for user engagement

---

## 🔒 Security Considerations

### Authentication
- **MVP**: None (anonymous reporting for low friction)
- **Future**: Optional Firebase Auth for verified users

### Authorization
- **MVP**: All users have same permissions (read/write reports)
- **Future**: Role-based access (user, moderator, admin)

### Data Encryption
- **Local**: SQLite database encrypted by default (Drift)
- **In Transit**: HTTPS for all API calls (Open-Meteo, Firebase)
- **At Rest**: Local storage encrypted via Flutter secure storage

### Compliance
- **Google Play**: Data safety form completed
- **Privacy Policy**: Required for app store submission
- **GDPR**: Not applicable (no EU users, no PII)

---

## 📈 Scalability and Performance

### Scalability Plan
| Stage | Users | Architecture |
|-------|-------|--------------|
| MVP | <1000 | Client-side only, free tier |
| Growth | 1000-10000 | Add Firestore for sync |
| Scale | 10000+ | Add backend services, load balancing |

### Performance Targets
| Metric | Target | Current |
|--------|--------|---------|
| App Load Time | <5s | TBD |
| Map Render Time | <3s | TBD |
| A2UI Update Time | <2s | TBD |
| Voice Processing | <10s | TBD |
| Memory Usage | <200MB | TBD |

### Optimization Strategies
1. **Caching**: A2UI blueprints cached in Drift for offline
2. **Lazy Loading**: Conflict data loaded on-demand
3. **Compression**: JSON data compressed before storage
4. **Batch Processing**: Multiple reports batched for future sync

---

## 💻 Development and Deployment

### Development Tools
- **IDE**: Android Studio / VS Code
- **Version Control**: Git / GitHub
- **Package Manager**: Flutter pub
- **Testing**: flutter_test, integration_test

### Testing Strategy
| Type | Coverage | Tools |
|------|----------|-------|
| Unit Tests | Core functions | flutter_test |
| Widget Tests | UI components | flutter_test |
| Integration Tests | User flows | integration_test |
| Manual Testing | Full app | Android device |

### Deployment Process
1. **Development**: Code in feature branches
2. **Testing**: Run all tests, manual verification
3. **Build**: `flutter build apk --release`
4. **Distribution**: Upload to Firebase App Distribution
5. **Release**: Create GitHub release with APK

### Timeline
| Milestone | Date | Deliverables |
|-----------|------|--------------|
| MVP Complete | Sept 21, 2026 | Working APK, demo video, pitch deck |
| v1.1 Alpha | Oct 5, 2026 | Multi-language, Firestore sync |
| v1.1 Beta | Oct 15, 2026 | Push notifications, web version |
| v1.2 | Nov 15, 2026 | Authority auth, analytics dashboard |

---

> **➡️ Development Patterns & Architecture**: See [phase_2_development_patterns.md](phase_2_development_patterns.md) for detailed development standards, architecture patterns, and Riverpod best practices.

## ⚠️ Risks and Mitigation

### Technical Risks
| Risk | Severity | Mitigation |
|------|----------|------------|
| Free tier limits exceeded | High | Optimize API calls, implement caching |
| LLM accuracy issues | Medium | Provide user feedback mechanism |
| GPS accuracy in rural areas | Medium | Use last known location, manual override |
| Offline data loss | Low | Auto-sync when network returns |
| Device compatibility | Low | Test on multiple Android versions |

### Business Risks
| Risk | Severity | Mitigation |
|------|----------|------------|
| Low user adoption | High | Community leader onboarding |
| Spam/fake reports | Medium | User verification (future), trust system |
| Network costs for users | Low | Minimal data usage, offline-first |

### External Risks
| Risk | Severity | Mitigation |
|------|----------|------------|
| Open-Meteo API downtime | Medium | Cache weather data, fallback to cached |
| Firebase AI API changes | Medium | Use stable versions, monitor deprecations |

---

## 📚 Appendix

### AI Research Insights
**Round 1 - Technology Stack Validation**: 
- Flutter + firebase_ai + genui confirmed as production-ready stack
- Open-Meteo API validated for Nigerian weather data
- Drift ORM confirmed for offline SQLite

**Round 2 - Infrastructure Assessment**:
- Firebase App Distribution suitable for hackathon demo
- Free tier limits sufficient for 1000+ users
- No backend required for MVP

**Round 3 - Security Review**:
- Anonymous reporting acceptable for MVP
- Local encryption sufficient for initial launch
- No PII collection reduces compliance burden

**Round 4 - Risk Identification**:
- Free tier limits: 15 RPM, 1500 RPD for Gemini
- Open-Meteo: 1000 calls/day free
- Solution: Cache aggressively, batch requests

**Round 5 - Architecture Review**:
- Client-side architecture validated
- Offline-first design confirmed
- Zero backend cost for MVP

### Technology Recommendations
1. **State Management**: Riverpod chosen over Bloc/Provider for compile-time safety
2. **Database**: Drift chosen over Hive for type safety and SQL support
3. **Maps**: Flutter Map chosen over Google Maps for no API key requirement
4. **AI**: Firebase AI chosen for native audio streaming and free tier

### Cost Analysis
| Service | Cost (MVP) | Notes |
|---------|------------|-------|
| Firebase AI | $0 | Free tier: 15 RPM, 1500 RPD |
| Open-Meteo | $0 | Free tier: 1000 calls/day |
| OpenStreetMap | $0 | Free for non-commercial use |
| Firebase App Distribution | $0 | Free for unlimited testers |
| **Total** | **$0** | All services free for MVP |

### AI Architecture Validation Tools
To validate and optimize the Firebase AI integration, the following Vibe skills are recommended:

**Primary Recommendations:**
1. **`firebase/agent-skills@firebase-ai-logic-basics`** (116.4K installs)
   - Official Firebase skill for AI Logic SDK basics
   - Validates firebase_ai + Gemini 2.5 Flash integration
   - Install: `npx skills add firebase/agent-skills@firebase-ai-logic-basics`
   - [Learn more](https://skills.sh/firebase/agent-skills/firebase-ai-logic-basics)

2. **`firebase/agent-skills@firebase-ai-logic`** (34.6K installs)
   - Official Firebase skill for advanced AI Logic patterns
   - Reviews client-side AI architecture and best practices
   - Install: `npx skills add firebase/agent-skills@firebase-ai-logic`
   - [Learn more](https://skills.sh/firebase/agent-skills/firebase-ai-logic)

**Flutter-Specific Recommendations:**
3. **`evanca/flutter-ai-rules@firebase-ai`** (107 installs)
   - Flutter + Firebase AI integration patterns
   - Specific to our Flutter stack with firebase_ai
   - Install: `npx skills add evanca/flutter-ai-rules@firebase-ai`
   - [Learn more](https://skills.sh/evanca/flutter-ai-rules/firebase-ai)





**Validation Use Cases:**
- Review free tier usage and optimization strategies
- Validate voice streaming implementation
- Check offline capability patterns
- Optimize AI prompt engineering for A2UI generation
- Verify error handling and edge cases

### Glossary
- **A2UI**: Agent-to-User Interface - Dynamic UI generated by AI
- **MCP**: Model Context Protocol - Standard for LLM tool integration
- **GenUI**: Flutter package for A2UI rendering
- **Drift**: ORM for SQLite in Flutter
- **Riverpod**: State management library for Flutter

---

*Document created: September 20, 2026*  
*Phase: 2 - Product Planning*  
*Based on: idea/architecture_idea.md, idea/tech_stack.md, brainstorm_docs/phase_2_prd.md*
