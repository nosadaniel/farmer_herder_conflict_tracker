/// Compile-time environment values injected via
/// `flutter run --dart-define-from-file=.env` (see .env.example at repo
/// root). Deliberately not using a package (e.g. flutter_dotenv) — Flutter's
/// native --dart-define-from-file flag covers this without adding a
/// dependency.
class Env {
  const Env._();

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get hasSentryDsn => sentryDsn.isNotEmpty;

  /// Web App Check's reCAPTCHA v3 site key (Firebase Console → App Check →
  /// the web app → reCAPTCHA v3 provider). Without this, Firebase App Check
  /// can't be activated on web, so every Gemini call there fails with
  /// "Firebase App Check token is invalid" — see `main.dart`.
  static const String recaptchaSiteKey = String.fromEnvironment(
    'SITE_KEY_RECAPTCHA_SITE_KEY',
  );

  static bool get hasRecaptchaSiteKey => recaptchaSiteKey.isNotEmpty;

  /// Fixed Android App Check debug token (Firebase Console → App Check →
  /// Apps → Manage debug tokens), used by CI-built release APKs so every
  /// tester's install of the same build shares one pre-registered token
  /// instead of each device minting its own unregistered one — see
  /// `main.dart` for why `AndroidDebugProvider` (not Play Integrity) is
  /// used until this ships via the Play Store. Local dev leaves this unset
  /// and falls back to the SDK's own auto-generated per-install token.
  static const String appCheckDebugToken = String.fromEnvironment(
    'APP_CHECK_DEBUG_TOKEN',
  );

  static bool get hasAppCheckDebugToken => appCheckDebugToken.isNotEmpty;
}
