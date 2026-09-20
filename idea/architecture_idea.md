## 🗺️ System Architecture Overview
The system relies on an Agent-to-User Interface (A2UI) paradigm. Instead of the client app pulling static data fields, the Gemini 2.5 Flash agent acts as a dynamic interface designer, streaming structural layout blueprints directly into a local Flutter design catalog. By leveraging Model Context Protocol (MCP), the LLM stays completely decoupled from the data sorcery, allowing you to swap spreadsheet entries, climate inputs, or code logic without modifying your Flutter frontend.

                   ┌────────────────────────────────────────────────────────┐
                  │              FLUTTER CROSS-PLATFORM CLIENT             │
                  │  (Web: GitHub Pages  |  Mobile: Firebase App Distrib)  │
                  └───────────────────────────┬────────────────────────────┘
                                              │
                    ▲                         ▼                         ▲
                    │        [Online: Network Request Stream]           │
       [Offline Fallback]                     │                         │
     Loads A2UI JSON Snapshots                ▼                         │
                    │         ┌──────────────────────────────┐          │
                    │         │    firebase_ai Client SDK    │          │
                    │         │ (Gemini 2.5 Flash w/ Audio)  │          │
                    │         └───────────────┬──────────────┘          │
                    │                         │                         │
                    │                         ▼ [In-App Function Calls] │ [Streams A2UI Layout]
             ┌──────┴──────┐          ┌───────┴────────┐                │
             │ Local Cache │          │ Custom In-App  │                │
             │ Hive/Drift  │◀─────────┤ Function Tools ├────────────────┘
             └─────────────┘  Caches  └───────┬────────┘
                               Payload        │
                                              ▼ [Direct Client Connections]
                        ┌─────────────────────┴─────────────────────┐
                        │        DECOUPLED DATA & CONTEXT LAYER     │
                        └──────────┬──────────────┬──────────────┬──┘
                                   │              │              │
                                   ▼              ▼              ▼
                           [Historical Dataset] [Cloud Firestore] [Open-Meteo]
                             Static ACLED    Real-time User    Live Keyless
                             Historic Dataset   Incident Reports   Weather API

------------------------------
## 🛠️ Complete Technology Stack## Frontend & Presentation

* Cross-Platform Framework: Flutter (Compiling a single codebase to Web for desk officials and Android/iOS for field operators).
* Dynamic UI Engine: genui package implementing the A2UI protocol spec.
* Geospatial Engine: flutter_map + latlong2 mapping packages.

## Backend & Core Logic (Serverless)

* Intelligence Engine: Gemini 2.5 Flash via Google AI Studio/Vertex AI.
* Cost: $0 (Free Tier).
   * Limits: 10–15 Requests per minute (RPM) / 1,500 Requests per day (RPD) — ideal for hackathon evaluation.
* Client Gateway: Firebase AI Logic Dart SDK (Direct client-to-LLM streaming with zero custom middleware endpoints required).

## Storage & Resilience

* Local Offline Cache: Hive or Drift (No-SQL/Relational internal persistence).
* dataset store in the application bundle: farmer_herder_conflict.json

------------------------------
## 🔌 Model Context Protocol (MCP) Configuration
To keep the application modular, Gemini does not store data inside its prompt. Instead, it hooks into three specific MCP tool environments:
   1. Climate Stressors Tool (weather-mcp)
   * Source: Open-Source Open-Meteo API.
      * Function: A keyless tool that fetches real-time rainfall deficits and dry spell anomalies. If a drought index surges in Northern regions, the agent identifies premature southward nomadic migration trends.
   2. Infrastructure Mapping Tool (osm-spatial-mcp)
   * Source: OpenStreetMap (OSM) data registries.
      * Function: Extracts vector paths of traditional grazing reserves and legal cattle corridors to calculate coordinate intersections against active farming grids.
   
------------------------------
## 🔄 Lifecycle of a User Interaction## Step 1: The Query
A community leader opens the Flutter app and typing: "What is the threat assessment for Kaduna State today?"
## Step 2: Agent Tool Aggregation
The Firebase AI Logic SDK pipes the query to Gemini. Realizing it needs localized context, Gemini triggers its parallel MCP framework:

   1. It queries the google-sheets-mcp for historical incidents in Kaduna.
   2. It hits the weather-mcp to verify if immediate drying trends exist.
   3. It references coordinates from the osm-spatial-mcp.

## Step 3: A2UI Blueprint Generation
Instead of returning boring text or a locked JSON schema, Gemini constructs a modular layout blueprint following the standard A2UI specification:

* It declares a Container block.
* Inside, it injects an atomic Header ("Medium Risk Assessment"), an interactive OpenStreetMap MapWidget featuring calculated coordinate pinpoints, and a WarningBanner advising farmers to complete agricultural actions early.

## Step 4: UI Rendering & Local Cache Sync
The A2UI layout JSON payload streams directly through the Flutter client connection.

* The Render: The genui package grabs the stream, instantiates components from its local widget catalog, and renders the layout on the fly.
* The Cache Sync: Simultaneously, the raw A2UI JSON layout string is mirrored into the Hive/Drift database under the key kaduna_latest_threat.

## Step 5: Offline Rehydration Fallback
If that same user loses network coverage completely due to regional cellular instability and opens the app later:

   1. The app detects a network disconnect.
   2. It bypasses the Firebase Gemini instance completely.
   3. It fetches the raw JSON string matching kaduna_latest_threat out of Hive/Drift.
   4. The local genui package reads the string and renders the exact interactive dashboard locally without requiring data packets or a backend check.

------------------------------
## 🚀 Hackathon Validation Thoughts
This architecture is a massive strategic win for a hackathon environment because it solves the classic engineering constraints judges look for:

* Production Realism on a $0 Budget: By choosing Open-Meteo, OpenStreetMap, and Gemini's developer free tier, your architecture costs completely nothing to present, but can scale instantly to a production workload.
* Elite Separation of Concerns: Your data is completely separated from your interface logic. If judges ask: "Can this track conflicts in Kenya instead of Nigeria?", you only change the rows in your dataset and OpenStreetMap bounding box—your Flutter application remains completely untouched.
* Solves Real Infrastructure Limits: Acknowledge to the judges that rural connectivity is spotty. Showing them that your design saves layout blueprints directly via A2UI into Hive for zero-network execution proves you engineered the app for real-world field conditions.


### Monitoring
1. use sentry



### Analytics
1. to be done




