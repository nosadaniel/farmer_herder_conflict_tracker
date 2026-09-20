
name: farmer_herder_conflict_tracker
description: A predictive early-warning and community-reporting ecosystem using GenUI and A2UI over Firebase with Riverpod.
version: 1.0.0+1

# --- 🔥 FIREBASE & CLIENT-SIDE AI INNER CORE ---
firebase_core: 4.15.0         # Initializes core Firebase services in Flutter
cloud_firestore: 6.10.0       # Handles real-time multi-user crowdsourced incident tracking
firebase_ai: 4.0.0            # Google's native serverless client-to-Gemini streaming engine

# --- 🧠 DYNAMIC PRESENTATION ENGINE ---
genui: 0.10.3                # Progressive parser implementing the official A2UI layout protocol

# --- 🗺️ OPEN GEOSPATIAL & OPEN MAPS ---
  flutter_map: 8.3.2           # Vendor-free, keyless map client loaded via OpenStreetMap grids
  latlong2: 0.10.1              # Essential mathematical utilities for managing GPS coordinates

  # --- 🎙️ HARDWARE & SENSOR UTILITIES ---
  record: 7.1.1               # High-efficiency cross-platform microphone intake engine
  geolocator: 14.0.3            # Automated user telemetry grab upon application launch
   Share Plus : 13.3.0              # Cross-platform social media sharing capability
   logger : 2.8.0                   # logging 
   skeletonizer : 3.0.0             # UI shimmer 
   golden_test : 2.0.1              # UI components testing 

  # --- 💾 MODERN RELATIONAL OFFLINE CACHE ---
  # High-performance, type-safe SQLite relational database core
  # Native asynchronous database connector utilities for Flutter
  # for android/ios/web

  drift: 2.35.0
  path_provider: 2.1.6
  path: 1.9.1
  drift_flutter:0.3.1
  sqlite3: 3.6.0


  # --- 🏗️ PRESENTATION STATE MANAGEMENT (RIVERPOD) ---
  flutter_riverpod: 3.4.3       # Compile-safe, highly reactive state management framework
  riverpod_annotation: 4.0.7   # Modern syntax attributes for code-generated providers



  # --- MONITORING ---
  sentry_flutter: 9.30.0

  # --- ANALYTICS ---
  firebase_analytics: 12.6.0  # for ios
  firebase_analytics_web: 0.6.1+13 # for web


dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: 2.35.0            # Generates safe serialization tables and database schema
  riverpod_generator: 4.0.9     # Compiles riverpod annotations into functional type-safe providers
  build_runner: 2.16.1        # Code generation framework trigger


