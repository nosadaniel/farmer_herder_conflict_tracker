/// Thrown by data sources (remote/local). Caught at the repository boundary
/// and converted to a [Failure] for the presentation layer — see failures.dart.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class TranscriptionException extends AppException {
  const TranscriptionException([super.message = 'Voice transcription failed']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local cache read/write failed']);
}

class LocationException extends AppException {
  const LocationException([super.message = 'Could not determine location']);
}
