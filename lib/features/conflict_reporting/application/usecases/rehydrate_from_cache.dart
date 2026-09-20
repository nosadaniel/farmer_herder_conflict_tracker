import 'package:genui/genui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/cache_repository.dart';

/// Offline rehydration (task.md non-negotiable #6 / MVP item 6): when there
/// is no network, the last-rendered A2UI blueprint is replayed into a
/// [SurfaceController] exactly the way a live Gemini response would be —
/// via [A2uiTransportAdapter.addChunk] feeding the same
/// `incomingMessages -> controller.handleMessage` pipeline `Conversation`
/// wires up internally (see genui's `facade/conversation.dart`).
///
/// This project deliberately has no connectivity-checking package
/// (`task.md`/Track D brief): offline handling is "attempt the live path,
/// catch failure, fall back to cache," not a proactive check. This function
/// is the fallback half of that pattern — call it from a `catch` block
/// around the live Gemini call, or use [attemptLiveOrRehydrate] below to get
/// that wiring for free.
///
/// Feeds the last cached blueprint (stored under [cacheKey], defaulting to
/// [AppConstants.lastBlueprintCacheKey]) back into [controller]. No-op if
/// there is nothing cached (or it expired).
Future<void> rehydrateFromCache(
  SurfaceController controller,
  CacheRepository cacheRepository, {
  String cacheKey = AppConstants.lastBlueprintCacheKey,
}) async {
  final String? blueprintJson = await cacheRepository.getLastBlueprint(
    cacheKey,
  );
  if (blueprintJson == null || blueprintJson.isEmpty) return;

  final adapter = A2uiTransportAdapter();
  final subscription = adapter.incomingMessages.listen(
    controller.handleMessage,
  );
  try {
    adapter.addChunk(blueprintJson);
    await adapter.flush();
  } finally {
    await subscription.cancel();
    adapter.dispose();
  }
}

/// Runs [attemptLive] (the real Gemini round-trip, owned by Track B); if it
/// throws for any reason (no network, DNS failure, request timeout, Firebase
/// AI error, etc.) falls back to [rehydrateFromCache] so the user still sees
/// their last known risk state instead of a blank/broken screen.
///
/// This is the "attempt live, catch failure, fall back to cache" pattern
/// called for in the Track D brief, expressed generically so integration
/// can wrap whatever the live call ends up looking like without Track D
/// needing to know its concrete type.
Future<void> attemptLiveOrRehydrate({
  required Future<void> Function() attemptLive,
  required SurfaceController controller,
  required CacheRepository cacheRepository,
  String cacheKey = AppConstants.lastBlueprintCacheKey,
}) async {
  try {
    await attemptLive();
  } catch (_) {
    // Network failures, timeouts, and any other live-path error all fall
    // back the same way: rehydrate whatever we last cached.
    await rehydrateFromCache(controller, cacheRepository, cacheKey: cacheKey);
  }
}
