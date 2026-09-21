import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routing/app_router.dart';
import 'app/wiring/gemini_send_handler.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Firebase AI Logic requires App Check — without this, every Gemini call
  // fails with "Firebase App Check token is invalid" (discovered during
  // Phase 3 device testing; see task.md). AndroidProvider.debug generates a
  // debug token logged on first run — register it under Firebase Console →
  // App Check → Manage debug tokens, OR set the Gemini API's App Check
  // enforcement to "Unenforced" there instead (faster, no token needed) if
  // you don't need enforcement for the hackathon demo.
  //
  // Only Android has a registered debug provider so far. `activate()` on
  // web defaults its web provider to ReCaptchaV3Provider with no site key,
  // which throws (`Cannot read properties of null (reading 'initialize')`)
  // before the app even renders — so skip activation on web until a
  // reCAPTCHA site key is configured for the web app in Firebase Console.
  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: const AndroidDebugProvider(),
    );
  }
  // Sentry wiring (lib/core/config/env.dart's Env.sentryDsn) lands here if
  // time allows — see task.md cut list.
  runApp(
    ProviderScope(
      // Wires the real Gemini call into Track C's a2uiSendHandlerProvider
      // seam — see lib/app/wiring/gemini_send_handler.dart for why this is
      // an override here rather than edited directly into a2ui_providers.dart.
      overrides: [geminiSendHandlerOverride],
      child: const ConflictTrackerApp(),
    ),
  );
}

class ConflictTrackerApp extends ConsumerWidget {
  const ConflictTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Farmer-Herders Conflict Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
