import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routing/app_router.dart';
import 'app/wiring/gemini_send_handler.dart';
import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Firebase AI Logic requires App Check — without this, every Gemini call
  // fails with "Firebase App Check token is invalid" (discovered during
  // Phase 3 device testing; see task.md).
  //
  // Android, like web, needs a release-vs-debug split. `AndroidDebugProvider`
  // (debug/profile builds) generates a random debug token per install,
  // logged on first run — fine for one developer's own device (register it
  // under Firebase Console -> App Check -> Manage debug tokens), but
  // unworkable for a release APK handed to multiple testers via Firebase
  // App Distribution: every tester's device would mint its own token, none
  // of them pre-registered, so Gemini calls fail until each one is
  // manually added. `AndroidPlayIntegrityProvider` (kReleaseMode only) is
  // Firebase's production provider instead — it verifies any genuine build
  // signed with the registered release certificate, no per-device token
  // registration needed. Register the release keystore's SHA-256
  // fingerprint (`keytool -list -v -keystore android/app/upload-keystore.jks
  // -alias upload`) under Firebase Console -> App Check -> Apps -> the
  // Android app -> Play Integrity before a release build's Gemini calls
  // will succeed.
  //
  // `activate()`'s web provider (ReCaptchaV3Provider) needs a real site key
  // — without one it throws (`Cannot read properties of null (reading
  // 'initialize')`) before the app even renders. ReCaptchaV3Provider is also
  // a *production* provider: using it in debug/profile builds would either
  // fail (no site key configured for local dev) or burn real reCAPTCHA
  // quota against a key meant for the deployed site. So web debug/profile
  // builds use `WebDebugProvider()` instead (same idea as
  // `AndroidDebugProvider` below — auto-generates a debug token printed to
  // the browser console on first run; register it under Firebase Console ->
  // App Check -> Manage debug tokens). Only `kReleaseMode` web builds use
  // the real `ReCaptchaV3Provider(Env.recaptchaSiteKey)`, and only when a
  // site key is actually configured (via `--dart-define-from-file=.env`,
  // see `.env.example`) — otherwise `null`, so a release web build without
  // a configured key still boots instead of throwing.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
    providerWeb: !kIsWeb
        ? null
        : kReleaseMode
        ? (Env.hasRecaptchaSiteKey
              ? ReCaptchaV3Provider(Env.recaptchaSiteKey)
              : null)
        : WebDebugProvider(),
  );
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
