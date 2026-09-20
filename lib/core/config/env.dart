/// Compile-time environment values injected via
/// `flutter run --dart-define-from-file=.env` (see .env.example at repo
/// root). Deliberately not using a package (e.g. flutter_dotenv) — Flutter's
/// native --dart-define-from-file flag covers this without adding a
/// dependency.
class Env {
  const Env._();

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get hasSentryDsn => sentryDsn.isNotEmpty;
}
