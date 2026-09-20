/// Presentation-facing counterpart to [AppException] — repositories return
/// these (not exceptions) so the UI layer never needs a try/catch.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TranscriptionFailure extends Failure {
  const TranscriptionFailure([super.message = 'Voice transcription failed']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache read/write failed']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Could not determine location']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
