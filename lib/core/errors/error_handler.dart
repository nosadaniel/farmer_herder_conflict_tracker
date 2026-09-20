import 'exceptions.dart';
import 'failures.dart';

/// Maps a caught [AppException] (or any error) to a [Failure] for the
/// presentation layer. Use in repository implementations' catch blocks.
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    NetworkException(:final message) => NetworkFailure(message),
    TranscriptionException(:final message) => TranscriptionFailure(message),
    CacheException(:final message) => CacheFailure(message),
    LocationException(:final message) => LocationFailure(message),
    _ => const UnknownFailure(),
  };
}
