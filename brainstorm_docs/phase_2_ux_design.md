# User Experience (UX) Design Document: Farmer-Herders Conflict Tracker

**Version**: 1.0.0  
**Last Updated**: September 20, 2026  
**Phase**: 2 - Product Planning  
**Status**: Draft  
**Author**: Based on idea/idea.md, idea/frontend_architecture_idea.md, brainstorm_docs/phase_2_prd.md, brainstorm_docs/phase_2_tech_architecture.md

---

## 🎨 UX Overview

### Purpose
Create an intuitive, accessible, and effective user experience that enables rural Nigerian users with low literacy to report conflicts, receive warnings, and take protective action through a voice-first, context-aware interface that adapts dynamically to their situation.

### Scope
This document covers the complete UX design for MVP (v1.0) including:
- Static Frame (onboarding, persistent elements)
- Dynamic Canvas (A2UI workspace)
- Voice interaction patterns
- Map visualization
- Social sharing flows
- Offline experience

### Alignment with PRD and GTM
- Supports PRD requirements for voice-first, offline-capable, accessible design
- Aligns with GTM focus on rural Nigerian users (Ibrahim, Musa personas)
- Emphasizes simplicity and low cognitive load for low-literacy users
- Highlights community benefit to drive adoption

### Alignment with Technical Architecture
- Works within Flutter constraints (Android 8.0+)
- Leverages GenUI for dynamic UI rendering
- Voice-first approach uses firebase_ai audio streaming
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
  - Voice-first interaction
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

### Principle 1: Voice-First (Text Alternative)
**Description**: All functionality must be accessible via voice input, with text input available as an alternative.  
**Rationale**: Low literacy users struggle with text input, but some users may prefer typing.  
**Implementation**: 
- Microphone button prominently displayed (bottom center, primary method)
- Text input icon beside microphone (secondary method)
- Voice commands for all actions
- Audio feedback for system responses
- Text and voice produce identical results

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
- Maximum 3 steps for any action
- Large, clear buttons with icons
- Consistent color coding (Red=Danger, Yellow=Warning, Green=Safe)
- Progress indicators for loading states

### Principle 5: Community Trust
**Description**: Build trust through transparency and community focus.  
**Rationale**: Users need to trust the system to adopt it.  
**Implementation**:
- Show report source ("Reported by Ibrahim 2km away")
- Verification indicators for trusted reports
- Community leader endorsements
- Clear data usage (no PII collected)

### Principle 6: Cultural Relevance
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

### Screen 3: Onboarding - Permissions
- **Description**:
  - Icon: Microphone + GPS
  - Headline: "We need access to help you"
  - Text: "Location: To show you nearby threats\nMicrophone: To record your voice reports"
  - Allow All button (primary)
  - Allow Later button (secondary)
- **Purpose**: Request necessary permissions
- **Visual**: Permission icons, clear list

### Screen 4: Onboarding - Tutorial
- **Description**:
  - 4-step carousel:
    1. "Press and hold to report" (mic icon)
    2. "Or type your report" (keyboard icon)
    3. "See threats on the map" (map icon)
    4. "Share with your community" (share icon)
  - Swipe indicators
  - Get Started button
- **Purpose**: Quick user education
- **Visual**: Simple illustrations, large icons

### Screen 5: Main App Shell (Static Frame)
- **Description**:
  - **Header**: App name, network status indicator, settings icon
  - **Dynamic Canvas**: Central area for A2UI content (changes based on context)
  - **Persistent Footer**: Large microphone button (press & hold to record) + Text input icon (keyboard)
  - **Share Button**: Floating action button (bottom-right) for sharing current view
- **Purpose**: Primary app container
- **Visual**: Clean, minimal chrome, maximum space for dynamic content
- **Note**: Microphone is primary (larger, center), Text icon is secondary (smaller, right of mic)

### Dynamic Canvas States:

#### State A: Low Risk (Default)
- **Description**:
  - Green header: "Low Risk in Your Area"
  - Map showing user location with green pin
  - Historical conflict hotspots (faded red circles)
  - Weather indicator: "Dry conditions - monitor cattle routes"
  - Action button: "Report Sighting" (voice)
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
  - Enabled: View cached data, share cached alerts
- **Color Scheme**: Orange primary
- **Tone**: Informative, not alarming

### Screen 6: Input Mode Selection
- **Description**:
  - Bottom sheet with two options:
    - "🎙️ Speak your report" (primary, large)
    - "⌨️ Type your report" (secondary, smaller)
  - Cancel button
- **Purpose**: Let user choose input method
- **Visual**: Clear icons, voice option more prominent

### Screen 7: Voice Recording
- **Description**:
  - Modal overlay with large microphone icon pulsing
  - "Recording..." text
  - Timer (00:00 to max 2:00)
  - Cancel button
  - Visual waveform for audio input
- **Purpose**: Voice report capture
- **Visual**: Animated microphone, clear visual feedback

### Screen 8: Text Input
- **Description**:
  - Full-screen or modal with text field
  - Input field: "Describe what you see..." (placeholder)
  - Character counter: "0/500"
  - Submit button (disabled when empty)
  - Cancel button
  - Keyboard: Standard with emoji picker (optional)
- **Purpose**: Text report capture
- **Visual**: Clean text field, large input area, clear submit button

### Screen 9: Report Confirmation
- **Description**:
  - "Report Received" headline
  - Transcription text (large, readable)
  - Map showing report location
  - Risk level assessment (Low/Medium/High)
  - Share button (primary)
  - Edit button (if transcription wrong)
- **Purpose**: Confirm and share report
- **Visual**: Checkmark icon, clear confirmation

### Screen 8: Share Sheet
- **Description**:
  - Native Android share sheet
  - Pre-filled text: "Conflict Alert: [transcription] at [location]. Risk: [level]. Stay safe. -Shared via Conflict Tracker"
  - Suggested apps: WhatsApp, Messenger, Twitter, SMS
  - Copy to clipboard option
- **Purpose**: Distribute alerts to community
- **Visual**: Native OS UI, app icons visible

---

## 🔄 Interaction Flows

### Flow 1: First-Time User Onboarding
1. **Splash Screen** → Auto-load (2s)
2. **Welcome Screen** → User reads purpose
3. **Permissions Screen** → User grants location + microphone access
4. **Tutorial Screen** → User swipes through 3 steps
5. **Main App** → GPS detected, risk level assessed, appropriate state displayed

**Alternative Path**: Skip onboarding
- User can skip directly to main app
- Permissions still required for core functionality

**Error State**: Permissions denied
- Show error: "Microphone access required for voice reports. You can still use text input."
- Button: "Open Settings" to enable permissions OR "Use Text Instead"

### Flow 2: Report Conflict (Primary Flow - Voice)
1. **Main App** → User sees current risk state
2. **Press & Hold Microphone** → Recording starts, modal appears
3. **Speak Report** → User says: "Large herd crossing river near my farm"
4. **Release Microphone** → Recording stops, processing starts
5. **AI Processing** → Transcription + risk assessment (10s max)
6. **A2UI Update** → Dynamic canvas updates with report details
7. **Confirmation** → User reviews transcription and risk level
8. **Share** → User taps share, selects app, alert distributed

**Alternative Path**: Long press cancelled
- User releases outside microphone button
- Recording cancelled, return to main app

**Error States**:
- No microphone permission: Show permission request OR "Use Text Instead"
- Network error: Cache report locally, sync later
- Transcription failed: Show error, retry option OR "Try Text Input"

### Flow 3: Report Conflict (Text Alternative)
1. **Main App** → User sees current risk state
2. **Tap Text Icon** → Input mode selection bottom sheet appears
3. **Select Text** → User taps "⌨️ Type your report"
4. **Type Report** → User enters: "Large herd crossing river near my farm"
5. **Submit** → Text sent to AI (no transcription needed, ~5s faster)
6. **A2UI Update** → Dynamic canvas updates with report details (same as voice)
7. **Confirmation** → User reviews text and risk level
8. **Share** → User taps share, selects app, alert distributed

**Alternative Path**: Switch to voice
- User can tap microphone icon in text field to switch to voice
- Existing text preserved as fallback for voice input

**Error States**:
- Empty input: Show validation "Please describe the conflict"
- Input too long: Show error "Maximum 500 characters" OR auto-truncate
- Network error: Cache text report locally, sync later

### Flow 4: View Map and Hotspots
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
4. **Record Report** → Voice report recorded, cached locally
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
- **Purpose**: Voice input for reports
- **Props**: `onPressed`, `onReleased`, `isRecording`, `disabled`
- **States**:
  - `idle` (ready to record)
  - `recording` (pulsing animation)
  - `processing` (spinner)
  - `disabled` (no mic permission)
- **Size**: 64x64dp (minimum touch target)
- **Placement**: Persistent footer (center)
- **Usage**: Primary report input

**TextInput** (`A2UI_TextInput`)
- **Purpose**: Alternative text input
- **Props**: `hintText`, `maxLength`, `onSubmit`, `inputType`
- **Features**:
  - Multi-line support
  - Character counter
  - Clear button
  - Submit button
- **Size**: Full width, 100dp height minimum
- **Placement**: Modal or inline
- **Usage**: Text report alternative

**ChoiceSelector** (`A2UI_ChoiceSelector`)
- **Purpose**: Select from predefined options
- **Props**: `options`, `selected`, `onChanged`, `multiSelect`
- **Variants**:
  - `radio` (single selection)
  - `checkbox` (multi-selection)
  - `chips` (horizontal selection)
- **Usage**: Risk level confirmation, input mode selection

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
- **Purpose**: Initiate new report
- **Props**: `type`, `onPressed`
- **States**:
  - `voice` (microphone icon)
  - `text` (keyboard icon)
- **Placement**: Footer bar
- **Usage**: Start report flow

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

```
A2UI_Workspace (Root)
├── A2UI_Container
│   ├── A2UI_Header (Risk Level)
│   │   ├── A2UI_RiskLevelIndicator
│   │   └── A2UI_TextBlock (Status)
│   │
│   ├── A2UI_StatusBanner (if applicable)
│   │
│   ├── A2UI_MapView
│   │   ├── A2UI_MapMarker (User Location)
│   │   ├── A2UI_MapMarker (Conflict Hotspots)
│   │   └── A2UI_MapOverlay (Weather)
│   │
│   ├── A2UI_ReportList (Recent Reports)
│   │   └── A2UI_ReportCard (xN)
│   │
│   ├── A2UI_TextBlock (Instructions/Details)
│   │
│   └── A2UI_QuickActionBar
│       ├── A2UI_ActionButton (Primary)
│       └── A2UI_ActionButton (Secondary)
│
└── A2UI_Section (Footer)
    ├── A2UI_ActionButton (Report)
    ├── A2UI_MicrophoneButton
    └── A2UI_ShareButton
```

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
| ⭐⭐⭐⭐⭐ | A2UI_MicrophoneButton | Medium | Voice input |
| ⭐⭐⭐⭐ | A2UI_TextInput | Medium | Text alternative |
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
- **Voice Commands**: All actions available via voice
- **Text Input**: All actions available via text (alternative to voice)
- **Switching**: Easy to switch between voice and text mid-report
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
  - Static frame at top and bottom
  - Dynamic canvas in center (80% of screen)
  - Microphone button fixed at bottom
  
- **Landscape** (if supported):
  - Static frame on left side
  - Dynamic canvas on right (70% of screen)
  - Microphone button floating

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
| First-time use | 5 rural users | Time to complete report, error rate | Week 1 post-launch |
| Voice reporting | 10 users | Accuracy of transcription, user satisfaction | Week 2 |
| Text reporting | 8 users | Input speed, error rate, satisfaction | Week 2 |
| Input method preference | 15 users | % choosing voice vs text, reasons | Week 3 |
| Offline usage | 5 users | Ability to complete tasks offline | Week 3 |
| Share flow | 5 users | Share completion rate, preferred platforms | Week 4 |

### Test Scenarios
1. **Report a Conflict (Voice)**: User sees herd, reports via voice, shares alert
2. **Report a Conflict (Text)**: User sees herd, reports via text, shares alert
3. **Switch Input Methods**: User starts with voice, switches to text mid-report
4. **Navigate Map**: User zooms, pans, taps hotspots
5. **Offline Operation**: User turns off data, uses cached information
6. **Permission Handling**: User denies microphone permission, uses text input instead

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
- **Static Frame**: Non-changing parts of the UI (headers, footers)
- **Dynamic Canvas**: Central area that changes based on context
- **Voice-First**: Design principle prioritizing voice input over text
- **Offline-First**: Design principle prioritizing offline functionality

---

*Document created: September 20, 2026*  
*Phase: 2 - Product Planning*  
*Based on: idea/idea.md, idea/frontend_architecture_idea.md, brainstorm_docs/phase_2_prd.md, brainstorm_docs/phase_2_tech_architecture.md*
