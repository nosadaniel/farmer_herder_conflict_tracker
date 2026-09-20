import 'package:firebase_ai/firebase_ai.dart';

/// Minimal seam around [GenerativeModel] so [GeminiRemoteDataSource] (see
/// `gemini_remote_datasource.dart`) can be unit-tested with `mocktail`.
///
/// `firebase_ai`'s [GenerativeModel] is declared `final class`, which means
/// it cannot be subclassed/implemented from outside the package — so it
/// can't be mocked directly. This interface exposes only the two calls we
/// actually use (matching [GenerativeModel.generateContent] and
/// [GenerativeModel.generateContentStream] in spirit) and is implemented by
/// [FirebaseGeminiModelClient] for production and by a `mocktail` `Mock` in
/// tests.
abstract class GeminiModelClient {
  /// Non-streaming call. Used for the lightweight transcription-only turn
  /// (contract doc §4 step 1).
  Future<String> generateContent(Iterable<Content> prompt);

  /// Streaming call. Used for the full A2UI-generation turn (contract doc §4
  /// step 2), yielding accumulated-so-far or incremental text chunks exactly
  /// as `firebase_ai` emits them.
  Stream<String> generateContentStream(Iterable<Content> prompt);
}

/// Production implementation — a thin pass-through to a real
/// [GenerativeModel] configured by [GeminiRemoteDataSource.production].
class FirebaseGeminiModelClient implements GeminiModelClient {
  FirebaseGeminiModelClient(this._model);

  final GenerativeModel _model;

  @override
  Future<String> generateContent(Iterable<Content> prompt) async {
    final response = await _model.generateContent(prompt);
    return response.text ?? '';
  }

  @override
  Stream<String> generateContentStream(Iterable<Content> prompt) {
    return _model
        .generateContentStream(prompt)
        .map((response) => response.text ?? '');
  }
}
