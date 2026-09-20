// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'a2ui_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The catalog used to render AI-generated surfaces.
///
/// Per docs/a2ui_gemini_contract.md §2: MVP renders every risk state with
/// only the basic (no-asset) catalog — no custom `CatalogItem`s.

@ProviderFor(a2uiCatalog)
final a2uiCatalogProvider = A2uiCatalogProvider._();

/// The catalog used to render AI-generated surfaces.
///
/// Per docs/a2ui_gemini_contract.md §2: MVP renders every risk state with
/// only the basic (no-asset) catalog — no custom `CatalogItem`s.

final class A2uiCatalogProvider
    extends $FunctionalProvider<Catalog, Catalog, Catalog>
    with $Provider<Catalog> {
  /// The catalog used to render AI-generated surfaces.
  ///
  /// Per docs/a2ui_gemini_contract.md §2: MVP renders every risk state with
  /// only the basic (no-asset) catalog — no custom `CatalogItem`s.
  A2uiCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a2uiCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a2uiCatalogHash();

  @$internal
  @override
  $ProviderElement<Catalog> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Catalog create(Ref ref) {
    return a2uiCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Catalog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Catalog>(value),
    );
  }
}

String _$a2uiCatalogHash() => r'376ceadc74d5037aca7dfe0b48e6c1a68e0f1600';

/// The seam through which the real Gemini call is plugged in.
///
/// This track (C — rendering) has no access to a live Gemini call, so the
/// default is `null`, which makes any [conversationProvider] `sendRequest`
/// call fail with a clear `StateError` (surfaced as a `ConversationError`
/// event) instead of silently doing nothing. Track B / whichever step wires
/// the real Firebase AI call is expected to override this provider — see
/// docs/a2ui_gemini_contract.md §4 for the exact per-turn context-block +
/// `addChunk` contract the override must follow.

@ProviderFor(a2uiSendHandler)
final a2uiSendHandlerProvider = A2uiSendHandlerProvider._();

/// The seam through which the real Gemini call is plugged in.
///
/// This track (C — rendering) has no access to a live Gemini call, so the
/// default is `null`, which makes any [conversationProvider] `sendRequest`
/// call fail with a clear `StateError` (surfaced as a `ConversationError`
/// event) instead of silently doing nothing. Track B / whichever step wires
/// the real Firebase AI call is expected to override this provider — see
/// docs/a2ui_gemini_contract.md §4 for the exact per-turn context-block +
/// `addChunk` contract the override must follow.

final class A2uiSendHandlerProvider
    extends
        $FunctionalProvider<
          ManualSendCallback?,
          ManualSendCallback?,
          ManualSendCallback?
        >
    with $Provider<ManualSendCallback?> {
  /// The seam through which the real Gemini call is plugged in.
  ///
  /// This track (C — rendering) has no access to a live Gemini call, so the
  /// default is `null`, which makes any [conversationProvider] `sendRequest`
  /// call fail with a clear `StateError` (surfaced as a `ConversationError`
  /// event) instead of silently doing nothing. Track B / whichever step wires
  /// the real Firebase AI call is expected to override this provider — see
  /// docs/a2ui_gemini_contract.md §4 for the exact per-turn context-block +
  /// `addChunk` contract the override must follow.
  A2uiSendHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a2uiSendHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a2uiSendHandlerHash();

  @$internal
  @override
  $ProviderElement<ManualSendCallback?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ManualSendCallback? create(Ref ref) {
    return a2uiSendHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManualSendCallback? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManualSendCallback?>(value),
    );
  }
}

String _$a2uiSendHandlerHash() => r'a607a8951da839256a62af9fd469abdd29b27f2c';

/// The `SurfaceController` backing [conversationProvider].
///
/// Exposed separately so a `Surface` widget (or a test) can bind to
/// `controller.contextFor(surfaceId)` directly.

@ProviderFor(a2uiSurfaceController)
final a2uiSurfaceControllerProvider = A2uiSurfaceControllerProvider._();

/// The `SurfaceController` backing [conversationProvider].
///
/// Exposed separately so a `Surface` widget (or a test) can bind to
/// `controller.contextFor(surfaceId)` directly.

final class A2uiSurfaceControllerProvider
    extends
        $FunctionalProvider<
          SurfaceController,
          SurfaceController,
          SurfaceController
        >
    with $Provider<SurfaceController> {
  /// The `SurfaceController` backing [conversationProvider].
  ///
  /// Exposed separately so a `Surface` widget (or a test) can bind to
  /// `controller.contextFor(surfaceId)` directly.
  A2uiSurfaceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a2uiSurfaceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a2uiSurfaceControllerHash();

  @$internal
  @override
  $ProviderElement<SurfaceController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SurfaceController create(Ref ref) {
    return a2uiSurfaceController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SurfaceController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SurfaceController>(value),
    );
  }
}

String _$a2uiSurfaceControllerHash() =>
    r'1c67dbc1a22e193181eaa920ab1b3fec47d4a591';

/// The `A2uiTransportAdapter` backing [conversationProvider].
///
/// Exposed so whichever code implements [a2uiSendHandlerProvider] (a real
/// Gemini call) can pipe streamed response chunks in via
/// `ref.read(a2uiTransportProvider).addChunk(chunk)`, and so tests can feed
/// fixture text the same way without a live Gemini call.

@ProviderFor(a2uiTransport)
final a2uiTransportProvider = A2uiTransportProvider._();

/// The `A2uiTransportAdapter` backing [conversationProvider].
///
/// Exposed so whichever code implements [a2uiSendHandlerProvider] (a real
/// Gemini call) can pipe streamed response chunks in via
/// `ref.read(a2uiTransportProvider).addChunk(chunk)`, and so tests can feed
/// fixture text the same way without a live Gemini call.

final class A2uiTransportProvider
    extends
        $FunctionalProvider<
          A2uiTransportAdapter,
          A2uiTransportAdapter,
          A2uiTransportAdapter
        >
    with $Provider<A2uiTransportAdapter> {
  /// The `A2uiTransportAdapter` backing [conversationProvider].
  ///
  /// Exposed so whichever code implements [a2uiSendHandlerProvider] (a real
  /// Gemini call) can pipe streamed response chunks in via
  /// `ref.read(a2uiTransportProvider).addChunk(chunk)`, and so tests can feed
  /// fixture text the same way without a live Gemini call.
  A2uiTransportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a2uiTransportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a2uiTransportHash();

  @$internal
  @override
  $ProviderElement<A2uiTransportAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  A2uiTransportAdapter create(Ref ref) {
    return a2uiTransport(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(A2uiTransportAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<A2uiTransportAdapter>(value),
    );
  }
}

String _$a2uiTransportHash() => r'f42014e49b1801d7faa4454bafce950dfe6e938f';

/// The `Conversation` orchestrating the `SurfaceController` and transport.
///
/// This is the primary export other tracks depend on:
/// - `ref.read(conversationProvider).sendRequest(message)` to send a turn.
/// - `ref.read(conversationProvider).events` to listen for
///   `ConversationError` / `ConversationSurfaceAdded` / etc., including
///   intercepting the reserved "share_alert" action (contract §7).
/// - `ref.read(conversationProvider).state` for `isWaiting` / `surfaces`.

@ProviderFor(conversation)
final conversationProvider = ConversationProvider._();

/// The `Conversation` orchestrating the `SurfaceController` and transport.
///
/// This is the primary export other tracks depend on:
/// - `ref.read(conversationProvider).sendRequest(message)` to send a turn.
/// - `ref.read(conversationProvider).events` to listen for
///   `ConversationError` / `ConversationSurfaceAdded` / etc., including
///   intercepting the reserved "share_alert" action (contract §7).
/// - `ref.read(conversationProvider).state` for `isWaiting` / `surfaces`.

final class ConversationProvider
    extends $FunctionalProvider<Conversation, Conversation, Conversation>
    with $Provider<Conversation> {
  /// The `Conversation` orchestrating the `SurfaceController` and transport.
  ///
  /// This is the primary export other tracks depend on:
  /// - `ref.read(conversationProvider).sendRequest(message)` to send a turn.
  /// - `ref.read(conversationProvider).events` to listen for
  ///   `ConversationError` / `ConversationSurfaceAdded` / etc., including
  ///   intercepting the reserved "share_alert" action (contract §7).
  /// - `ref.read(conversationProvider).state` for `isWaiting` / `surfaces`.
  ConversationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationHash();

  @$internal
  @override
  $ProviderElement<Conversation> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Conversation create(Ref ref) {
    return conversation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Conversation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Conversation>(value),
    );
  }
}

String _$conversationHash() => r'b4d62f117152ddfcaccaf4282bafeab32fb5610e';
