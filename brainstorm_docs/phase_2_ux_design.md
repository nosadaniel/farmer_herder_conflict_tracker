# User Experience (UX) Design Document: Farmer-Herders Conflict Tracker

**Version**: 1.1.0  
**Last Updated**: September 21, 2026  
**Phase**: 2 - Product Planning  
**Status**: Draft — realigned to the Guided Report Wizard  
**Author**: Based on idea/idea.md, idea/frontend_architecture_idea.md, brainstorm_docs/phase_2_prd.md, brainstorm_docs/phase_2_tech_architecture.md, docs/report_wizard_ux_flow.md

---

## 🎨 UX Overview

### Purpose
Create an intuitive, accessible, and effective user experience that enables rural Nigerian users with low literacy to report conflicts, receive warnings, and take protective action. The app's core job is to **guide the user, one small decision at a time, all the way to a finished result** — never a blank input field, never a form. This guided-wizard model is now the app's central mechanism, not one flow among several.

> **Canonical spec**: The step-by-step screens, chip-trail behavior, and permission-timing rules are fully specified in [`docs/report_wizard_ux_flow.md`](../docs/report_wizard_ux_flow.md), inspired by a Gemini-image-creation guided-creation pattern (see `inspiration_design.md`). This document should be read alongside it — the wireframes here are condensed summaries; that doc is the source of truth for exact screen contracts.

### Scope
This document covers the complete UX design for MVP (v1.0) including:
- Onboarding (persona/benefit screens only — zero permission requests)
- The Guided Report Wizard (chip trail + stepper + per-step tap-only choices, the app's single reporting mechanism)
- In-context permission requests (location at Wizard Step 1, microphone at Wizard Step 4 — no separate "permissions" screen)
- Dynamic Canvas / Result surface (A2UI workspace rendered at the end of the wizard)
- Map visualization
- Social sharing flows
- Offline experience

### Alignment with PRD and GTM
- Supports PRD requirements for guided, low-typing, offline-capable, accessible design
- Aligns with GTM focus on rural Nigerian users (Ibrahim, Musa personas)
- Emphasizes simplicity and low cognitive load for low-literacy users — one decision per screen, tap-only until the very last optional step
- Highlights community benefit to drive adoption

### Alignment with Technical Architecture
- Works within Flutter constraints (Android 8.0+)
- Leverages GenUI for dynamic UI rendering — the Report Wizard is a **separate, bounded GenUI session** (see `docs/refactor.md`) from the existing Result-surface flow: each wizard step has a fixed `surfaceId` and is bound to a `createAndUpdate(dataModel: false)` `Conversation`, so tap selections write straight to that step's `DataModel` (no Gemini call), and Back/forward navigation between already-visited steps never re-triggers Gemini either — it just re-shows a cached surface. Only the Result surface itself (produced once, at Create) uses the existing `createOnly` `.chat()` flow, unchanged
- Voice input (via firebase_ai audio streaming) is retained, but only as optional enrichment on the wizard's last step, not the primary entry point
- Offline capability via Drift caching

---

## 👥 User Personas

### Persona 1: Ibrahim - Community Leader & Farmer
- **Demographics**: 45 years old, Male, Primary education, Farmer, Southern Kaduna
- **Technical Proficiency**: Low (basic phone usage, limited literacy)
- **Goals**: Protect village from conflicts, coordinate with neighboring communities
- **Pain Points**: Complex interfaces, typing difficulties, reactive responses
- **UX Needs**: 
  - Large touch targets (48x48dp minimum)
  - Tap-first interaction, with voice available when he wants to add detail
  - Clear visual hierarchy
  - Minimal text, maximum icons/symbols
  - High contrast colors for outdoor visibility

### Persona 2: Musa - Herder Leader
- **Demographics**: 38 years old, Male, No formal education, Herder, Kano State
- **Technical Proficiency**: Low (basic phone usage)
- **Goals**: Safely move cattle, avoid conflicts
- **Pain Points**: No mapping tools, language barriers, trust issues
- **UX Needs**:
  - Simple navigation (1-2 taps max for any action)
  - Visual map representation
  - Audio feedback for actions
  - Hausa language support (future)

### Persona 3: Amina - NGO Worker (Future)
- **Demographics**: 35 years old, Female, University educated, NGO employee
- **Technical Proficiency**: High
- **Goals**: Monitor conflicts, coordinate responses
- **Pain Points**: Lack of real-time data
- **UX Needs**:
  - Web dashboard access
  - Filter and search capabilities
  - Export functionality

---

## 🎯 Design Principles

### Principle 1: Guided, Tap-First (Voice/Text as Enrichment)
**Description**: The primary path through the app is a sequence of tap-only choices (chips, `ChoicePicker`, `Button`) — no free-text or free-speech input is required until the final, optional step.  
**Rationale**: Tapping a pre-written option is even lower-friction than speaking for low-literacy users, removes ambiguity for the LLM, and still lets users add nuance by voice or text when they want to.  
**Implementation**:
- Steps 1–3 of the Report Wizard are 100% tap-only (location choice, situation chips, who's-involved chips)
- Step 4 offers **Speak** and **Write** side by side as optional, additive enrichment on top of the structured chips — not a fork in the flow
- A persistent chip trail at the top of the wizard shows everything decided so far, in plain words
- Text and voice, when used, produce identical downstream results (both become plain text appended to the context block)

### Principle 2: Context-Aware
**Description**: UI adapts based on user location, risk level, and history.  
**Rationale**: Users need relevant information for their specific situation.  
**Implementation**: 
- Dynamic A2UI changes based on context
- Risk level affects color scheme and urgency indicators
- Location affects map view and data displayed

### Principle 3: Offline-First
**Description**: Full functionality without network connectivity.  
**Rationale**: Rural Nigeria has spotty connectivity.  
**Implementation**: 
- All data cached locally
- A2UI blueprints stored for offline rehydration
- Clear offline/online indicators

### Principle 4: Minimal Cognitive Load
**Description**: Reduce thinking required for all interactions.  
**Rationale**: Low literacy users need simple, obvious actions.  
**Implementation**:
- One decision per wizard screen — never more than a handful of options visible at once
- A 4-dot stepper and chip trail always show where the user is and what's already decided, so nothing has to be held in memory
- Every step (except the Result) offers a **Skip** — the final report always works with whatever chips exist
- Large, clear buttons with icons
- Consistent color coding (Red=Danger, Yellow=Warning, Green=Safe)
- Progress indicators for loading states

### Principle 5: Guided Progression, Not a One-Time Ritual
**Description**: There is no separate "setup" experience the user has to get through before the app is useful. The Report Wizard *is* the app's core functionality, and it's identical the first time and the hundredth time.  
**Rationale**: A standalone permissions/setup screen shown before the user has done anything creates a moment of friction with no visible payoff, which is exactly where low-trust, low-literacy users drop off.  
**Implementation**:
- Onboarding is content-only (persona/benefit screens), requests zero permissions, and ends by dropping the user straight into the wizard for their first report
- Location permission is requested at Wizard Step 1, in context, the first time the user wants a prediction for "here"
- Microphone permission is requested at Wizard Step 4, in context, the first time the user taps "Speak"
- Denying a permission never dead-ends the flow: "Choose my state" replaces GPS, "Write" replaces Speak

### Principle 6: Community Trust
**Description**: Build trust through transparency and community focus.  
**Rationale**: Users need to trust the system to adopt it.  
**Implementation**:
- Show report source ("Reported by Ibrahim 2km away")
- Verification indicators for trusted reports
- Community leader endorsements
- Clear data usage (no PII collected)

### Principle 7: Cultural Relevance
**Description**: Design that respects and reflects Nigerian rural culture.  
**Rationale**: Increase adoption through cultural familiarity.  
**Implementation**:
- Earth tone color palette (browns, greens, oranges)
- Local symbols and imagery
- Hausa/English language support
- Respect for traditional authority figures

---

## 🖼️ Wireframes and Mockups

### Screen 1: Splash Screen
- **Description**: App logo with loading spinner, "Farmer-Herders Conflict Tracker" text
- **Purpose**: Brand recognition, app loading
- **Visual**: Earth tone background, simple icon (shield + map pin)
- **Duration**: 2-3 seconds

### Screen 2: Onboarding - Welcome
- **Description**: 
  - Large icon (farmer + herder shaking hands)
  - Headline: "Welcome to Conflict Tracker"
  - Subheadline: "Protect your community, report threats"
  - Start button (large, green, center)
  - Skip button (small, top-right)
- **Purpose**: Introduce app purpose
- **Visual**: Illustrated figures, warm colors

### Screen 3: Onboarding - Tutorial
- **Description**:
  - 3-step carousel, content-only, **zero permission requests**:
    1. "Answer a few quick taps about what you're seeing" (chip icon)
    2. "See threats on the map" (map icon)
    3. "Share with your community" (share icon)
  - Swipe indicators
  - Get Started button — drops the user directly into Wizard Step 1 for their first report
- **Purpose**: Quick user education
- **Visual**: Simple illustrations, large icons
- **Note**: The old standalone "Permissions" screen is gone. There is no separate ritual for granting location/microphone access — see Screen 5 (Report Wizard), where each permission is requested in context, the first time it's actually needed.

### Screen 4: Main App Shell (Static Frame)
- **Description**:
  - **Header**: App name, network status indicator, settings icon
  - **Dynamic Canvas**: Central area for A2UI content — shows the current risk state for the user's last-known area (see Dynamic Canvas States below)
  - **Footer**: A single primary CTA, **"Report"**, that launches the Report Wizard (Screen 5)
  - **Share Button**: Floating action button (bottom-right) for sharing the current view
- **Purpose**: Primary app container / home state
- **Visual**: Clean, minimal chrome, maximum space for dynamic content
- **Note**: The old persistent mic-button + keyboard-icon footer is removed entirely. One CTA replaces both — reporting always goes through the wizard now, whether by voice, tap, or text.

### Dynamic Canvas States (shown on the Main App Shell and mirrored on the Wizard's Result screen):

#### State A: Low Risk (Default)
- **Description**:
  - Green header: "Low Risk in Your Area"
  - Map showing user location with green pin
  - Historical conflict hotspots (faded red circles)
  - Weather indicator: "Dry conditions - monitor cattle routes"
  - Action button: "Report Sighting" → launches the wizard
- **Color Scheme**: Green primary, neutral secondary
- **Tone**: Calm, informative

#### State B: Medium Risk
- **Description**:
  - Yellow header: "⚠️ Medium Risk - Be Alert"
  - Map zoomed to show nearby conflict zones
  - Recent reports list (last 5 from nearby)
  - Weather overlay showing drought index
  - Action buttons: "Report Sighting", "View Safety Tips"
- **Color Scheme**: Yellow primary, orange accents
- **Tone**: Cautious, action-oriented

#### State C: High Risk
- **Description**:
  - Red header: "❗ HIGH RISK - Immediate Action Needed"
  - Map centered on threat location with red radius
  - Large "DANGER" banner pulsing
  - Real-time reports from nearby users
  - Action buttons: "Report Sighting", "Share Alert", "Call for Help"
  - Audio alert (if enabled): Beeping sound
- **Color Scheme**: Red primary, white text on red
- **Tone**: Urgent, clear actions

#### State D: Offline Mode
- **Description**:
  - Orange header: "Offline Mode - Last updated: [time]"
  - Cached map view
  - Cached A2UI blueprint
  - Disabled: Real-time weather, new reports
  - Enabled: View cached data, share cached alerts, still run the wizard (report queues for sync)
- **Color Scheme**: Orange primary
- **Tone**: Informative, not alarming

### Screen 5: The Report Wizard (Steps 1–4)
This screen is the app's single reporting mechanism — the same 4-step flow runs every time, first report or the hundredth. Full step-by-step wireframes, copy, and behavior notes (chip trail, Back/Skip semantics, permission timing) live in [`docs/report_wizard_ux_flow.md`](../docs/report_wizard_ux_flow.md). Condensed summary:

| Step | Question | Input type | In-context permission |
|------|----------|-----------|------------------------|
| 1 — Where? | How should we find your area? | Tap: "Use my location" / "Choose my state" (`ChoicePicker`) | GPS, first time only |
| 2 — What's happening? | What are you seeing? | Tap: single-select chips (herd sighting, moving toward farmland, confrontation, just checking) | — |
| 3 — Who's involved? | Who's there? | Tap: single-select chips (herders, farmers, both, not sure) | — |
| 4 — Add detail (optional) | Want to add more? | Speak or Write, additive on top of Steps 1–3 | Microphone, first time "Speak" is tapped |

- A **chip trail** at the top accumulates one chip per resolved step and persists across Back navigation.
- **Skip** is available on every step except the Result — the final Gemini call runs with whatever chips exist.
- **Back** never re-triggers Gemini — each step is a pre-rendered `Surface` the wizard just walks back to.
- Tapping **Speak** swaps in a compact recording control (waveform + timer) in place, reusing the existing `MicrophoneButton` recording UI. Tapping **Write** swaps in a single-line field reusing `TextInputModal` validation. Neither is a separate screen or modal takeover.
- Tapping **Create** fires the one Gemini call: accumulated chips + optional detail text/transcript → existing report-generation system prompt + context block.

### Screen 6: Result
- **Description**:
  - ✕ close/restart control, top-left
  - `MapView` catalog item (live map, hotspots + user pin) — same component as the Dynamic Canvas states, now embedded inside the wizard's final surface
  - Risk headline (e.g. "⚠ Medium risk nearby")
  - 1–2 sentence summary
  - Action buttons, Gemini-authored (e.g. "Report Sighting", "View Safety Tips")
  - "Share Alert" button (reserved action, intercepted client-side — unchanged `share_alert` handling)
- **Purpose**: The single, final output the entire wizard has been building toward
- **Visual**: Map-forward, risk-colored accent, generous spacing around the headline
- **Note**: Tapping ✕ clears the chip trail and local surface history, returning to Step 1 — the flow's only "start a new report" affordance.

### Screen 7: Share Sheet
- **Description**:
  - Native Android share sheet
  - Pre-filled text: "Conflict Alert: [summary] at [location]. Risk: [level]. Stay safe. -Shared via Conflict Tracker"
  - Suggested apps: WhatsApp, Messenger, Twitter, SMS
  - Copy to clipboard option
- **Purpose**: Distribute alerts to community
- **Visual**: Native OS UI, app icons visible

---

## 🔄 Interaction Flows

### Flow 1: First-Time User Onboarding
1. **Splash Screen** → Auto-load (2s)
2. **Welcome Screen** → User reads purpose
3. **Tutorial Screen** → User swipes through 3 content-only steps (no permission prompts)
4. **Report Wizard, Step 1** → User is dropped straight into their first report; GPS permission is requested here, in context, only if they tap "Use my location"

**Alternative Path**: Skip onboarding
- User can skip directly into the Report Wizard
- No permissions are required just to view the Main App Shell's cached/default risk state — they're only requested inside the wizard, and only for the step that needs them

**Error State**: Permission denied mid-wizard
- Location denied at Step 1 → falls back to "Choose my state" (`ChoicePicker`), flow continues unblocked
- Microphone denied at Step 4 → "Speak" becomes disabled, "Write" remains available, flow continues unblocked

### Flow 2: Report via the Guided Wizard (Primary Flow)
1. **Main App** → User sees current risk state, taps the single "Report" CTA
2. **Step 1 — Where?** → Taps "Use my location" (GPS permission requested first time) or "Choose my state"; chip trail gains one chip
3. **Step 2 — What's happening?** → Taps one situation chip (herd sighting / moving toward farmland / confrontation / just checking); chip trail grows
4. **Step 3 — Who's involved?** → Taps one chip (herders / farmers / both / not sure); chip trail grows
5. **Step 4 — Add detail (optional)** → User may tap **Speak** (mic permission requested first time, then waveform + timer recording control in place) or **Write** (inline single-line field) or skip straight to Create
6. **Create** → Fires the single Gemini call: accumulated chips + optional transcript/text → context block
7. **Result** → `MapView` + risk headline + summary + action buttons + Share Alert render in one surface
8. **Share** → User taps Share Alert, selects app, alert distributed
9. **Close (✕)** → Clears chip trail and local surface history, returns to Step 1 for the next report

**Alternative Path**: Back navigation
- Back walks to the previous already-rendered `Surface` locally — no extra Gemini call. Choosing something different on a re-visited step produces a fresh forward turn.

**Alternative Path**: Skip
- Available on Steps 1–4; skipping a step just omits that chip. The final Create call still runs with whatever chips exist.

**Error States**:
- No location permission and no state chosen: user can still Skip Step 1 entirely — Gemini receives no location context
- No microphone permission: "Speak" is disabled at Step 4, "Write" remains fully available
- Network error at Create: cache the accumulated chips locally, queue for sync, show cached/offline result if available
- Transcription failed (Speak used): show inline error at Step 4, offer "Write instead" without losing Steps 1–3's chips

### Flow 3: View Map and Hotspots
1. **Main App** → Map displayed with user location
2. **Zoom In/Out** → User pinches to zoom
3. **Tap Hotspot** → Details panel slides up from bottom
4. **View Details** → See date, type, severity of historical conflict
5. **Filter** → User taps filter icon, selects date range

**Alternative Path**: Search for location
- User taps search, enters location name
- Map centers on searched location

**Error State**: Data loading failed
- Show retry button
- Display cached data if available

### Flow 4: Offline Usage
1. **App Launch (No Network)** → Offline mode activated
2. **Cached View** → Last online state displayed
3. **Cached Reports** → Previous 50 reports available
4. **Run the Wizard** → Steps 1–4 work identically offline (all tap-only, plus Speak/Write); Create queues the report locally instead of calling Gemini live
5. **Network Returns** → Auto-sync cached reports
6. **Fresh Data** → New reports and weather data loaded

**Error State**: Storage full
- Show warning: "Storage almost full, delete old reports?"
- Provide cleanup options

### Flow 5: Receive Proximity Alert (Future - Push Notifications)
1. **Background** → Nearby report submitted
2. **Proximity Check** → System calculates distance
3. **Notification** → Push notification: "Conflict reported 2km away"
4. **Tap Notification** → App opens to High Risk state
5. **View Details** → User sees report and map

---

## 🎨 Visual Design

### Color Scheme
| Color | Name | Hex | Usage |
|-------|------|-----|-------|
| Primary | Earth Brown | #8B4513 | App bars, buttons |
| Secondary | Forest Green | #228B22 | Safe/Low risk indicators |
| Warning | Golden Yellow | #FFD700 | Medium risk indicators |
| Danger | Blood Red | #DC143C | High risk indicators, alerts |
| Neutral | Warm Gray | #A9A9A9 | Text, borders, backgrounds |
| Success | Lime Green | #32CD32 | Confirmation, success states |
| Background | Cream | #FFFDD0 | App background |

### Typography
| Type | Font | Size | Weight | Usage |
|------|------|------|--------|-------|
| Headline | Roboto | 24sp | Bold | Screen titles |
| Subhead | Roboto | 20sp | Medium | Section headers |
| Body | Roboto | 16sp | Regular | Main text |
| Caption | Roboto | 14sp | Regular | Labels, helpers |
| Button | Roboto | 18sp | Medium | Button text |

### Icons and Imagery
- **Icon Style**: Simple, flat, high contrast
- **Size**: 24x24dp for standard, 48x48dp for touch targets
- **Sources**: Material Icons (built-in), custom for Nigerian symbols
- **Imagery**: Illustrated figures (farmer, herder, cattle) in earth tones

### Spacing System
- **xs**: 4dp - Tight spacing
- **sm**: 8dp - Small spacing
- **md**: 16dp - Medium spacing
- **lg**: 24dp - Large spacing
- **xl**: 32dp - Extra large spacing

---

## 🧩 UI Component Design (GenUI Catalog)

### Overview
GenUI requires a **UI Component Catalog** - a collection of reusable, composable widgets that the A2UI system can dynamically assemble based on AI-generated blueprints. This section defines the component library for Farmer-Herders Conflict Tracker.

### Design Principles for Components
1. **Reusability**: Each component should be usable in multiple contexts
2. **Composability**: Components should nest and combine easily
3. **Consistency**: Uniform styling, spacing, and behavior
4. **Accessibility**: All components must meet WCAG 2.1 AA standards
5. **Offline-Friendly**: No external dependencies, cached where needed

### Component Catalog

#### 1. Layout Components

**Container** (`A2UI_Container`)
- **Purpose**: Root wrapper for A2UI blueprints
- **Props**: `backgroundColor`, `padding`, `borderRadius`
- **Variants**: 
  - `default` (white background)
  - `urgent` (red border for high-risk states)
  - `warning` (yellow border for medium-risk states)
- **Usage**: Wraps all dynamic content in the canvas

**Section** (`A2UI_Section`)
- **Purpose**: Organize content into logical groups
- **Props**: `title`, `subtitle`, `icon`, `spacing`
- **Variants**: 
  - `header` (large, bold)
  - `body` (standard)
  - `footer` (small, muted)
- **Usage**: Groups related UI elements

**Divider** (`A2UI_Divider`)
- **Purpose**: Visual separation between sections
- **Props**: `thickness`, `color`, `margin`
- **Variants**: Horizontal, Vertical
- **Usage**: Separate content areas

#### 2. Display Components

**Header** (`A2UI_Header`)
- **Purpose**: Display risk level and primary information
- **Props**: `title`, `subtitle`, `riskLevel`, `icon`
- **Variants**:
  - `lowRisk` (Green, "✅ Low Risk")
  - `mediumRisk` (Yellow, "⚠️ Medium Risk")
  - `highRisk` (Red, "❗ HIGH RISK")
  - `offline` (Orange, "Offline Mode")
- **Usage**: Top of dynamic canvas showing current state

**StatusBanner** (`A2UI_StatusBanner`)
- **Purpose**: Highlight important status messages
- **Props**: `text`, `type`, `dismissible`, `autoHideDuration`
- **Variants**: 
  - `info` (Blue)
  - `warning` (Yellow)
  - `error` (Red)
  - `success` (Green)
- **Usage**: Alerts, confirmations, errors

**TextBlock** (`A2UI_TextBlock`)
- **Purpose**: Display paragraphs of text
- **Props**: `text`, `style`, `maxLines`, `overflow`
- **Variants**:
  - `headline` (24sp, bold)
  - `body` (16sp, regular)
  - `caption` (14sp, muted)
- **Usage**: Descriptions, instructions, details

**StatCard** (`A2UI_StatCard`)
- **Purpose**: Display key metrics in card format
- **Props**: `label`, `value`, `icon`, `color`
- **Variants**: 
  - `large` (full width)
  - `small` (compact)
- **Usage**: Weather data, report counts, distance to threat

#### 3. Map Components

**MapView** (`A2UI_MapView`)
- **Purpose**: Interactive map display
- **Props**: `center`, `zoom`, `markers`, `onTap`
- **Features**:
  - OpenStreetMap tiles
  - Conflict hotspot markers (red circles)
  - User location pin (blue)
  - Grazing corridor overlays
  - Weather data heatmap
- **Usage**: Main conflict visualization

**MapMarker** (`A2UI_MapMarker`)
- **Purpose**: Individual markers on the map
- **Props**: `position`, `type`, `label`, `color`, `size`
- **Variants**:
  - `conflict` (red, pin icon)
  - `user` (blue, person icon)
  - `herd` (brown, cattle icon)
  - `safe` (green, checkmark icon)
- **Usage**: Mark specific locations

**MapOverlay** (`A2UI_MapOverlay`)
- **Purpose**: Additional data layers on map
- **Props**: `type`, `data`, `opacity`, `visible`
- **Variants**:
  - `heatmap` (conflict density)
  - `polygon` (danger zones)
  - `path` (grazing routes)
- **Usage**: Visualize spatial data

#### 4. Input Components

**MicrophoneButton** (`A2UI_MicrophoneButton`)
- **Purpose**: Voice input, now scoped to Wizard Step 4's optional enrichment
- **Props**: `onPressed`, `onReleased`, `isRecording`, `disabled`
- **States**:
  - `idle` (ready to record)
  - `recording` (pulsing animation)
  - `processing` (spinner)
  - `disabled` (no mic permission)
- **Size**: 64x64dp (minimum touch target)
- **Placement**: Inline, swapped in on Wizard Step 4 when "Speak" is tapped — **not** a persistent footer element anymore
- **Usage**: Optional detail enrichment (Step 4 only)

**TextInput** (`A2UI_TextInput`, reused as `TextInputModal`)
- **Purpose**: Optional detail enrichment as an alternative to Speak
- **Props**: `hintText`, `maxLength`, `onSubmit`, `inputType`
- **Features**:
  - Single-line field (short detail, not a full report form)
  - Character counter
  - Clear button
  - Submit button
- **Size**: Full width, single-line height
- **Placement**: Inline, swapped in on Wizard Step 4 when "Write" is tapped
- **Usage**: Optional detail enrichment (Step 4 only)

**ChoicePicker** (`A2UI_ChoicePicker`)
- **Purpose**: Tap-only selection for Wizard Steps 1–3 — the app's primary input mechanism
- **Props**: `options`, `selected`, `onChanged`, `multiSelect`
- **Variants**:
  - `radio` (single selection — used for Steps 2/3 today)
  - `checkbox` (multi-selection — reserved for a future step, per the reference pattern)
  - `chips` (horizontal selection — used for Step 1's state list)
- **Usage**: Steps 1–3 of the Report Wizard

**ChipTrail** (`A2UI_ChipTrail`)
- **Purpose**: Native-chrome (not GenUI-rendered) running summary of every choice made so far in the wizard
- **Props**: `chips` (ordered list of resolved-step labels)
- **Features**:
  - Accumulates one chip per resolved step
  - Persists across Back navigation
  - Wraps to multiple lines as chips accumulate
- **Placement**: Top of every wizard screen, below the header/stepper
- **Usage**: Orientation and memory aid across all 4 wizard steps

**WizardStepper** (`A2UI_WizardStepper`)
- **Purpose**: 4-dot progress indicator showing which wizard step is active/done
- **Props**: `totalSteps`, `activeStep`, `completedSteps`
- **Usage**: Top of every wizard screen, above the chip trail

#### 5. Action Components

**ActionButton** (`A2UI_ActionButton`)
- **Purpose**: Trigger actions
- **Props**: `text`, `icon`, `onPressed`, `style`, `size`
- **Variants**:
  - `primary` (filled, accent color)
  - `secondary` (outlined)
  - `danger` (red, for critical actions)
  - `iconOnly` (icon button)
- **Sizes**: Small (40dp), Medium (48dp), Large (56dp)
- **Usage**: Share, Confirm, Cancel, etc.

**ShareButton** (`A2UI_ShareButton`)
- **Purpose**: Share alerts to social media
- **Props**: `content`, `onShared`, `platforms`
- **Features**:
  - Pre-filled share text
  - Platform selection
  - Share confirmation
- **Placement**: Floating action button (bottom-right)
- **Usage**: Distribute alerts

**ReportButton** (`A2UI_ReportButton`)
- **Purpose**: The single CTA on the Main App Shell that launches the Report Wizard
- **Props**: `onPressed`
- **States**: `idle`, `disabled` (rare — offline queue full)
- **Placement**: Footer bar, replaces the old dual voice/text footer entirely
- **Usage**: Entry point into Wizard Step 1 — no `type` prop, since voice/text are now internal to Step 4, not top-level choices

#### 6. Feedback Components

**LoadingIndicator** (`A2UI_LoadingIndicator`)
- **Purpose**: Show processing state
- **Props**: `size`, `color`, `message`
- **Variants**:
  - `spinner` (circular progress)
  - `linear` (horizontal progress)
  - `waveform` (audio visualization)
- **Usage**: Voice processing, API calls

**ProgressBar** (`A2UI_ProgressBar`)
- **Purpose**: Show completion progress
- **Props**: `value`, `max`, `color`
- **Variants**: 
  - `determinate` (known progress)
  - `indeterminate` (unknown duration)
- **Usage**: Report submission, data loading

**SuccessFeedback** (`A2UI_SuccessFeedback`)
- **Purpose**: Confirm successful actions
- **Props**: `message`, `duration`, `onDismiss`
- **Features**:
  - Checkmark animation
  - Auto-dismiss (3 seconds)
  - Optional undo action
- **Usage**: Report submitted, share successful

**ErrorFeedback** (`A2UI_ErrorFeedback`)
- **Purpose**: Display error messages
- **Props**: `message`, `retryAction`, `dismissible`
- **Features**:
  - Error icon (warning sign)
  - Red color scheme
  - Retry button
- **Usage**: Network errors, permission denied

#### 7. Data Display Components

**ReportCard** (`A2UI_ReportCard`)
- **Purpose**: Display individual conflict report
- **Props**: `report`, `onTap`, `showActions`
- **Features**:
  - Timestamp
  - Location
  - Description
  - Risk level badge
  - Reporter info (optional)
  - Verification status
- **Usage**: Recent reports list, report details

**ReportList** (`A2UI_ReportList`)
- **Purpose**: List multiple reports
- **Props**: `reports`, `onItemTap`, `filter`
- **Features**:
  - Virtualized (performance optimized)
  - Grouped by date/time
  - Filterable
  - Searchable
- **Usage**: View recent community reports

**ConflictHotspot** (`A2UI_ConflictHotspot`)
- **Purpose**: Display historical conflict data
- **Props**: `conflict`, `onTap`
- **Features**:
  - Date of conflict
  - Type (farmer-herder, cattle rustling)
  - Severity (Low/Medium/High)
  - Fatalities (if applicable)
- **Usage**: Historical data visualization on map

**WeatherInfo** (`A2UI_WeatherInfo`)
- **Purpose**: Display climate data
- **Props**: `weatherData`, `location`
- **Features**:
  - Temperature
  - Drought index
  - Rainfall deficit
  - Last updated time
- **Usage**: Context for risk assessment

#### 8. Specialized Components (A2UI-Specific)

**A2UI_Workspace** (`Root Container`)
- **Purpose**: Main container for dynamic A2UI content
- **Props**: `blueprint`, `onRendered`, `fallback`
- **Features**:
  - Renders from A2UI JSON blueprint
  - Handles dynamic layout changes
  - Offline cache support
  - Error fallback
- **Usage**: Central dynamic canvas area

**RiskLevelIndicator** (`A2UI_RiskLevelIndicator`)
- **Purpose**: Visual risk level display
- **Props**: `level`, `size`, `animate`
- **Variants**:
  - `low` (Green, static)
  - `medium` (Yellow, gentle pulse)
  - `high` (Red, urgent pulse + sound)
- **Sizes**: Small (24dp), Medium (48dp), Large (96dp)
- **Usage**: Current risk state, report risk level

**QuickActionBar** (`A2UI_QuickActionBar`)
- **Purpose**: Context-aware action buttons
- **Props**: `actions`, `context`
- **Features**:
  - Dynamic button set based on context
  - Auto-hidden when not applicable
  - Priority-based ordering
- **Usage**: Bottom of dynamic canvas

### Component Hierarchy & Composition

The old single "Dynamic Canvas" tree is now split across two contexts: the **Report Wizard shell** (native chrome + one GenUI `Surface` per step) and the **Result surface** it produces.

**Report Wizard shell** (native chrome wrapping each step's `Surface`):
```
Wizard Shell (native, not GenUI)
├── A2UI_WizardStepper (4-dot progress)
├── A2UI_ChipTrail (accumulated chips)
└── Surface (GenUI, one per step — Back walks these locally)
    ├── Step 1: A2UI_ChoicePicker (chips — "Use my location" / "Choose my state")
    ├── Step 2: A2UI_ChoicePicker (radio — situation)
    ├── Step 3: A2UI_ChoicePicker (radio — who's involved)
    └── Step 4: A2UI_MicrophoneButton | A2UI_TextInput (mutually swapped, optional)
```

**Result surface** (rendered once, after "Create"):
```
A2UI_Workspace (Root)
└── A2UI_Container
    ├── A2UI_MapView
    │   ├── A2UI_MapMarker (User Location)
    │   └── A2UI_MapMarker (Conflict Hotspots)
    ├── A2UI_Header (Risk Level)
    │   ├── A2UI_RiskLevelIndicator
    │   └── A2UI_TextBlock (Status)
    ├── A2UI_TextBlock (1-2 sentence summary)
    └── A2UI_QuickActionBar
        ├── A2UI_ActionButton (Primary, Gemini-authored)
        ├── A2UI_ActionButton (Secondary, Gemini-authored)
        └── A2UI_ShareButton (reserved `share_alert` action)
```

The Main App Shell's home-state Dynamic Canvas (Low/Medium/High/Offline, Screen 4) reuses the same Result-surface tree — it's the same component composition, just rendered from the last cached report instead of a fresh wizard run.

### GenUI Integration Requirements

1. **Component Registration**
   - All components must be registered in GenUI catalog
   - Each component needs unique identifier
   - Component properties must be well-documented

2. **Blueprint Schema**
   - Define JSON schema for each component type
   - Include required and optional properties
   - Support nested components

3. **Offline Support**
   - All components must work offline
   - Static assets bundled with app
   - Cache dynamic data locally

4. **Performance Optimization**
   - Lazy load heavy components
   - Virtualize lists
   - Memoize expensive computations

5. **Accessibility Compliance**
   - All components must have accessibility labels
   - Support screen readers
   - Minimum touch targets (48x48dp)
   - Color contrast ratios (4.5:1)

### Component Development Workflow

1. **Design**: Create component specs (props, states, variants)
2. **Implement**: Build Flutter widget with GenUI compatibility
3. **Test**: Verify rendering from JSON blueprint
4. **Document**: Add to component catalog
5. **Register**: Add to GenUI catalog
6. **Validate**: Test with sample A2UI blueprints

### Sample A2UI Blueprint (JSON)

```json
{
  "type": "A2UI_Workspace",
  "children": [
    {
      "type": "A2UI_Container",
      "props": {
        "backgroundColor": "#FFFDD0",
        "padding": 16
      },
      "children": [
        {
          "type": "A2UI_Header",
          "props": {
            "title": "Medium Risk - Be Alert",
            "riskLevel": "medium",
            "icon": "warning"
          }
        },
        {
          "type": "A2UI_MapView",
          "props": {
            "center": {"lat": 9.0820, "lng": 8.6753},
            "zoom": 12,
            "markers": [
              {
                "type": "conflict",
                "position": {"lat": 9.0820, "lng": 8.6753}
              }
            ]
          }
        },
        {
          "type": "A2UI_QuickActionBar",
          "props": {
            "actions": [
              {
                "type": "primary",
                "text": "Report Sighting",
                "icon": "microphone"
              },
              {
                "type": "secondary",
                "text": "View Safety Tips",
                "icon": "info"
              }
            ]
          }
        }
      ]
    }
  ]
}
```

### Implementation Priority (MVP)

| Priority | Component | Complexity | Notes |
|----------|-----------|------------|-------|
| ⭐⭐⭐⭐⭐ | A2UI_Workspace | Medium | Root container, must have |
| ⭐⭐⭐⭐⭐ | A2UI_Container | Low | Basic layout wrapper |
| ⭐⭐⭐⭐⭐ | A2UI_Header | Medium | Risk level display |
| ⭐⭐⭐⭐⭐ | A2UI_StatusBanner | Low | Alert messages |
| ⭐⭐⭐⭐⭐ | A2UI_MapView | High | Core functionality |
| ⭐⭐⭐⭐⭐ | A2UI_MapMarker | Medium | Location indicators |
| ⭐⭐⭐⭐⭐ | A2UI_ChoicePicker | Medium | Primary input for Wizard Steps 1-3 |
| ⭐⭐⭐⭐⭐ | A2UI_ChipTrail | Low | Native chrome, wizard orientation |
| ⭐⭐⭐⭐⭐ | A2UI_WizardStepper | Low | Native chrome, wizard progress |
| ⭐⭐⭐⭐ | A2UI_MicrophoneButton | Medium | Voice input, Step 4 only |
| ⭐⭐⭐⭐ | A2UI_TextInput | Medium | Text alternative, Step 4 only |
| ⭐⭐⭐⭐ | A2UI_ActionButton | Low | Generic button |
| ⭐⭐⭐⭐ | A2UI_ShareButton | Medium | Social sharing |
| ⭐⭐⭐⭐ | A2UI_TextBlock | Low | Text display |
| ⭐⭐⭐ | A2UI_ReportCard | Medium | Report details |
| ⭐⭐⭐ | A2UI_RiskLevelIndicator | Medium | Risk visualization |
| ⭐⭐ | A2UI_LoadingIndicator | Low | Processing state |
| ⭐⭐ | A2UI_SuccessFeedback | Low | Confirmation |
| ⭐⭐ | A2UI_ErrorFeedback | Low | Error messages |

---

## ♿ Accessibility

### Compliance Level
- **Target**: WCAG 2.1 AA (where applicable for mobile)
- **Rationale**: Ensure usability for all users, including those with disabilities

### Specific Requirements

#### Visual
- **Color Contrast**: 4.5:1 minimum for all text
- **Color Blind Safe**: No reliance on color alone for information
- **Text Size**: Minimum 16sp for body text, scalable to 200%
- **Touch Targets**: Minimum 48x48dp for all interactive elements

#### Audio
- **Voice Feedback**: Audio confirmation for all actions
- **Error Tones**: Distinct sounds for different error types
- **Volume**: Configurable, follows device volume

#### Navigation
- **Screen Reader**: All elements labeled for VoiceOver/TalkBack
- **Focus Order**: Logical tab order for keyboard navigation
- **Skip Links**: Direct access to main content

#### Alternative Input
- **Tap-First**: Steps 1–3 require no voice or text at all — every core decision is a tap
- **Voice**: Available as optional Step 4 enrichment, for users who want to add nuance
- **Text**: Available as an equal alternative to voice at Step 4, same validation, same result
- **Switching**: Easy to switch between Speak and Write at Step 4 without losing Steps 1–3's chips
- **Swipe Gestures**: Optional swipe navigation between screens
- **Large Touch Areas**: Easy to tap even with limited dexterity

---

## 📱 Responsive Design

### Device Support
| Device Type | Screen Size | Orientation | Notes |
|-------------|-------------|------------|-------|
| Phone | 5" - 6.5" | Portrait | Primary target |
| Phablet | 6.5" - 7" | Portrait/Landscape | Supported |
| Tablet | 7"+ | Both | Future consideration |

### Layout Adaptations
- **Portrait**: 
  - Main App Shell: static header/footer, Dynamic Canvas in center (80% of screen), single "Report" CTA fixed at bottom
  - Wizard: stepper + chip trail fixed at top, step content fills center, Next/Back/Skip (or Create) fixed at bottom

- **Landscape** (if supported):
  - Main App Shell: static frame on left side, Dynamic Canvas on right (70% of screen)
  - Wizard: stepper + chip trail on left, step content on right

### Density Settings
- **Default**: Standard spacing, medium-sized elements
- **Compact**: Reduced spacing for small screens
- **Comfortable**: Increased spacing for large screens

---

## 📝 Content Strategy

### Tone and Voice
- **Tone**: Urgent but not alarming, helpful, community-focused
- **Voice**: Direct, clear, minimal jargon
- **Language**: Simple English (Hausa translation future)

### Messaging Examples
| Context | Message | Tone |
|---------|---------|------|
| Low Risk | "No immediate threats. Stay vigilant." | Calm, reassuring |
| Medium Risk | "Herds reported nearby. Monitor cattle routes." | Cautious, informative |
| High Risk | "CONFLICT DETECTED NEARBY! Take action now." | Urgent, direct |
| Offline | "Working offline. Data from [time]." | Informative |
| Error | "Could not connect. Try again later." | Helpful, not blaming |
| Wizard step header | "Use Next to continue." | Instructional, unobtrusive |
| Wizard Step 4 subhead | "Optional — Create works without this too." | Reassuring, low-pressure |
| Wizard skip | "Skip" | Neutral, never guilt-inducing |

### Localization (Future)
- **Primary**: English
- **Secondary**: Hausa
- **Approach**: String resources with language toggle
- **Priorities**: UI labels, error messages, action buttons

---

## 🧪 Testing and Validation

### Usability Tests
| Test | Participants | Metrics | Timeline |
|------|-------------|---------|----------|
| First-time wizard completion | 5 rural users | Time to complete report, error rate, drop-off step | Week 1 post-launch |
| Tap-only steps (1-3) | 10 users | Comprehension of chip options, selection accuracy | Week 1 |
| Step 4 enrichment (Speak) | 10 users | Accuracy of transcription, user satisfaction | Week 2 |
| Step 4 enrichment (Write) | 8 users | Input speed, error rate, satisfaction | Week 2 |
| Enrichment method preference | 15 users | % choosing Speak vs Write vs Skip, reasons | Week 3 |
| Offline usage | 5 users | Ability to complete the wizard offline | Week 3 |
| Share flow | 5 users | Share completion rate, preferred platforms | Week 4 |

### Test Scenarios
1. **Complete the Wizard, Tap-Only**: User sees herd, taps through Steps 1-3, skips Step 4, sees Result, shares alert
2. **Complete the Wizard with Speak**: User taps through Steps 1-3, uses Speak at Step 4, shares alert
3. **Complete the Wizard with Write**: User taps through Steps 1-3, uses Write at Step 4, shares alert
4. **Switch Enrichment Methods**: User taps Speak, then switches to Write at Step 4 without losing earlier chips
5. **Navigate Map**: User zooms, pans, taps hotspots
6. **Offline Operation**: User turns off data, completes the wizard using cached/queued state
7. **Permission Handling**: User denies location at Step 1 (falls back to "Choose my state") and denies microphone at Step 4 (falls back to Write), completes the report either way

### Success Criteria
- **Task Completion Rate**: >90% for core flows
- **Time on Task**: <30s for voice report
- **Error Rate**: <5% for primary actions
- **User Satisfaction**: >4/5 rating

### Feedback Mechanisms
- **In-App Feedback**: Thumbs up/down on reports
- **Rating Prompt**: After 5 successful reports
- **Contact**: Support email/phone in settings

---

## ⚠️ Risks and Mitigation

### UX Risks
| Risk | Severity | Mitigation |
|------|----------|------------|
| Low literacy users confused | High | Voice-first design, minimal text, clear icons |
| Cultural mismatches | Medium | User testing with target audience, iterate based on feedback |
| Offline UX unclear | Medium | Clear offline indicators, explain cached data |
| Voice recognition errors | Medium | Provide edit option, use context to improve accuracy |
| Color blindness issues | Low | Use patterns in addition to colors, test with color-blind users |

### Implementation Risks
| Risk | Severity | Mitigation |
|------|----------|------------|
| Complex animations slow | Medium | Use simple animations, test on low-end devices |
| Icon meaning unclear | Medium | User testing, add text labels if needed |
| Font rendering issues | Low | Use system fonts, test on multiple devices |

---

## 📚 Appendix

### AI Research Insights

**Round 1 - Persona Validation**:
- Confirmed: Rural Nigerian farmers/herders have low literacy rates
- Confirmed: Voice is preferred input method
- Confirmed: Community leaders (Ibrahim, Musa) are trusted figures

**Round 2 - Design Trend Analysis**:
- Voice-first apps gaining adoption in emerging markets
- Dynamic UI patterns effective for context-aware applications
- Earth tone color palettes preferred in agricultural regions
- Large touch targets standard for rural user interfaces

**Round 3 - Accessibility Review**:
- WCAG 2.1 AA compliance feasible for mobile apps
- Voice feedback critical for low-literacy users
- High contrast mode support important for outdoor use
- Touch targets must be >48x48dp for rural users

**Round 4 - UX Risk Identification**:
- Low literacy users may need additional guidance
- Cultural differences may affect icon interpretation
- Offline experience must be clearly communicated
- Voice recognition may struggle with local dialects

**Round 5 - Design Review**:
- Voice-first approach validated
- Dynamic A2UI pattern appropriate for use case
- Color scheme culturally appropriate
- Navigation simple and intuitive

### Competitor UX Analysis
**Ushahidi**:
- Strengths: Comprehensive crisis mapping
- Weaknesses: Form-based reporting (not voice-first), requires internet
- Our advantage: Voice-first, offline-capable

**WhatsApp Groups**:
- Strengths: Familiar, widely used
- Weaknesses: Fragmented, reactive only, no mapping
- Our advantage: Centralized, proactive, visual

**ACLED**:
- Strengths: Comprehensive conflict data
- Weaknesses: Not real-time, not user-facing
- Our advantage: Real-time, actionable, user-generated

### Design System Recommendations
1. **Icon Library**: Use Material Icons with custom Nigerian symbols
2. **Animation**: Simple fade/slide transitions, no complex animations
3. **Feedback**: Immediate visual/audio feedback for all actions
4. **Consistency**: Reuse patterns across all screens

### Glossary
- **A2UI**: Agent-to-User Interface - Dynamic UI generated by AI
- **Report Wizard**: The app's single reporting mechanism — a 4-step, tap-first flow (Where? / What's happening? / Who's involved? / Add detail) ending in one generated Result
- **Chip Trail**: Native-chrome running summary of every choice made so far in the wizard
- **Static Frame**: Non-changing parts of the UI (headers, footers)
- **Dynamic Canvas**: Central area that changes based on context; also the Main App Shell's home-state rendering of the last Result
- **Guided, Tap-First**: Design principle prioritizing pre-written tap choices over free text/speech for the primary flow, with voice/text reserved for optional enrichment
- **Offline-First**: Design principle prioritizing offline functionality

---

*Document created: September 20, 2026*  
*Last aligned to the Guided Report Wizard: September 21, 2026*  
*Phase: 2 - Product Planning*  
*Based on: idea/idea.md, idea/frontend_architecture_idea.md, brainstorm_docs/phase_2_prd.md, brainstorm_docs/phase_2_tech_architecture.md*
