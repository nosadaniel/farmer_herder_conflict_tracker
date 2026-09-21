// Riverpod wiring for the A2UI/GenUI rendering pipeline.
//
// Owns construction of `genui`'s `SurfaceController` + `Conversation`, used
// to render Gemini-authored A2UI blueprints. Per
// docs/a2ui_gemini_contract.md §2, this uses
// `BasicCatalogItems.asNoAssetCatalog()` with zero custom `CatalogItem`s for
// the MVP — every risk state (Low/Medium/High/Offline) is rendered with only
// the basic catalog's Column/Row/Card/Text/Icon/Button/etc.
//
// [conversationProvider] is the seam other tracks plug into:
// - Track B (Gemini-calling code, a different folder/track) triggers
//   generation by overriding [a2uiSendHandlerProvider] with a function that
//   builds the per-turn context block, calls Firebase AI's
//   `generateContentStream`, and pipes response chunks into
//   `ref.read(a2uiTransportProvider).addChunk(chunk)` — see
//   docs/a2ui_gemini_contract.md §4. Callers then trigger a turn via
//   `ref.read(conversationProvider).sendRequest(message)`.
// - Track D (share handling) listens to
//   `ref.read(conversationProvider).events` for the reserved "share_alert"
//   action name (contract §7). No interception is implemented here — this
//   file only guarantees the conversation/events are cleanly exposed for
//   that to be wired in later.
import 'package:farmer_herder_conflict_tracker/core/genui/map_view_catalog_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'a2ui_providers.g.dart';

/// The catalog used to render AI-generated surfaces.
///
/// Per docs/a2ui_gemini_contract.md §2: MVP renders every risk state with
/// the basic (no-asset) catalog plus one required custom `CatalogItem`,
/// `MapView` (see §2's superseded-note) — Gemini can place a live conflict
/// map inside its own generated surface.
@Riverpod(keepAlive: true)
Catalog a2uiCatalog(Ref ref) =>
    BasicCatalogItems.asNoAssetCatalog().copyWith(
      newItems: [mapViewCatalogItem],
    );

/// The seam through which the real Gemini call is plugged in.
///
/// This track (C — rendering) has no access to a live Gemini call, so the
/// default is `null`, which makes any [conversationProvider] `sendRequest`
/// call fail with a clear `StateError` (surfaced as a `ConversationError`
/// event) instead of silently doing nothing. Track B / whichever step wires
/// the real Firebase AI call is expected to override this provider — see
/// docs/a2ui_gemini_contract.md §4 for the exact per-turn context-block +
/// `addChunk` contract the override must follow.
@Riverpod(keepAlive: true)
ManualSendCallback? a2uiSendHandler(Ref ref) => null;

/// The `SurfaceController` backing [conversationProvider].
///
/// Exposed separately so a `Surface` widget (or a test) can bind to
/// `controller.contextFor(surfaceId)` directly.
@Riverpod(keepAlive: true)
SurfaceController a2uiSurfaceController(Ref ref) {
  final catalog = ref.watch(a2uiCatalogProvider);
  final controller = SurfaceController(catalogs: [catalog]);
  ref.onDispose(controller.dispose);
  return controller;
}

/// The `A2uiTransportAdapter` backing [conversationProvider].
///
/// Exposed so whichever code implements [a2uiSendHandlerProvider] (a real
/// Gemini call) can pipe streamed response chunks in via
/// `ref.read(a2uiTransportProvider).addChunk(chunk)`, and so tests can feed
/// fixture text the same way without a live Gemini call.
@Riverpod(keepAlive: true)
A2uiTransportAdapter a2uiTransport(Ref ref) {
  final transport = A2uiTransportAdapter(
    onSend: (message) async {
      final handler = ref.read(a2uiSendHandlerProvider);
      if (handler == null) {
        throw StateError(
          'No Gemini send handler configured. Override '
          'a2uiSendHandlerProvider (see docs/a2ui_gemini_contract.md §4) '
          'before calling Conversation.sendRequest.',
        );
      }
      await handler(message);
    },
  );
  ref.onDispose(transport.dispose);
  return transport;
}

/// The `Conversation` orchestrating the `SurfaceController` and transport.
///
/// This is the primary export other tracks depend on:
/// - `ref.read(conversationProvider).sendRequest(message)` to send a turn.
/// - `ref.read(conversationProvider).events` to listen for
///   `ConversationError` / `ConversationSurfaceAdded` / etc., including
///   intercepting the reserved "share_alert" action (contract §7).
/// - `ref.read(conversationProvider).state` for `isWaiting` / `surfaces`.
@Riverpod(keepAlive: true)
Conversation conversation(Ref ref) {
  final controller = ref.watch(a2uiSurfaceControllerProvider);
  final transport = ref.watch(a2uiTransportProvider);
  final conversation = Conversation(
    controller: controller,
    transport: transport,
  );
  ref.onDispose(conversation.dispose);
  return conversation;
}

/// Mirrors [conversationProvider]'s error state as a stream: emits the
/// error object on a `ConversationError` event, and `null` again once fresh
/// content arrives (`ConversationSurfaceAdded`/`ConversationComponentsUpdated`).
///
/// This is business state (not a UI-owned controller), so per task.md's
/// Phase 2 architecture it's Riverpod's job, not something `A2uiSurfaceView`
/// should track via a manually-managed `StreamSubscription` in its own
/// `State` — a plain `StreamProvider` here does the same job.
final conversationErrorProvider = StreamProvider<Object?>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.events
      .where(
        (event) =>
            event is ConversationError ||
            event is ConversationSurfaceAdded ||
            event is ConversationComponentsUpdated,
      )
      .map((event) => event is ConversationError ? event.error : null);
});
