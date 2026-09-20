/// Keyless third-party API endpoints. No secrets live here — see
/// lib/core/config/env.dart for the one value that does (Sentry DSN).
class ApiEndpoints {
  const ApiEndpoints._();

  /// Open-Meteo forecast API — keyless, client-side calls only.
  static const String openMeteoBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  /// OpenStreetMap tile template used by flutter_map.
  static const String osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
