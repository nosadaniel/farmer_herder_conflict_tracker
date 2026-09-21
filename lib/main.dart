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
  // **Correction (2026-09-22, real-device testing of an App-Distribution
  // release build)**: this briefly split Android the same way as web —
  // `AndroidPlayIntegrityProvider` for kReleaseMode, on the theory that it's
  // Firebase's production provider and avoids per-device debug-token
  // registration. That's true for a Play Store release, but **Firebase App
  // Check's built-in Play Integrity provider only works for apps distributed
  // through Google Play** (confirmed via multiple open
  // firebase/firebase-android-sdk and firebase/flutterfire issues, 2026):
  // Play Integrity attestation fails *client-side* — it can't even obtain a
  // token — for a sideloaded/App-Distribution APK, regardless of a
  // correctly-registered release-certificate fingerprint. The failure
  // surfaces deep in whatever screen first calls Gemini as a generic
  // "[firebase_app_check/unknown] ... 403 ... App attestation failed", with
  // no indication it's a distribution-channel issue. Setting App Check
  // enforcement to "Unenforced" in Firebase Console does NOT help either —
  // that only changes whether the *server* requires a token; the *client*
  // never successfully gets one in the first place.
  //
  // Until this ships via the Play Store, `AndroidDebugProvider` is the only
  // provider that actually works for every distribution channel used during
  // development (local debug, Firebase App Distribution). Its default
  // behavior — auto-generate a random debug token per install — doesn't
  // scale to multiple testers (each device's token needs manual Console
  // registration), so CI-built release APKs pass a fixed, pre-registered
  // token instead (`Env.appCheckDebugToken`, via deploy-android.yml's
  // `--dart-define=APP_CHECK_DEBUG_TOKEN=...`): every tester's install of
  // the same release build then shares that one already-registered token.
  // Local dev leaves this unset and falls back to the SDK's own
  // auto-generated token (register it yourself under Firebase Console ->
  // App Check -> Manage debug tokens, same as before). Revisit
  // `AndroidPlayIntegrityProvider` if/when this is ever published to Play.
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
    providerAndroid: AndroidDebugProvider(
      debugToken: Env.hasAppCheckDebugToken ? Env.appCheckDebugToken : null,
    ),
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
