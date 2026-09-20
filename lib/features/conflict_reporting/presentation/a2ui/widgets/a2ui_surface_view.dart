// The Dynamic Canvas content: renders whatever A2UI blueprint Gemini most
// recently generated, using genui's `Surface` widget bound to our
// `SurfaceController` (see ../providers/a2ui_providers.dart).
//
// Per docs/a2ui_gemini_contract.md §1, `SurfaceOperations.createOnly` means
// every turn creates a brand-new surface — so "most recently created
// surface" is simply "the current screen"; there is no reactive
// data-model/update-only case to handle for MVP.
//
// This widget is intentionally a plain `Widget` with no special context
// requirements beyond a `ProviderScope` ancestor (already present at the app
// root), so it can be dropped directly into `AppShell(dynamicCanvas: ...)`
// by a later integration step. It does not touch `AppShell` itself.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

import '../providers/a2ui_providers.dart';

/// Drop-in widget for the app shell's "dynamic canvas" slot.
///
/// Handles the two states the contract asks for, kept deliberately minimal
/// (no animations/transitions):
/// - loading (`Conversation.state.isWaiting`): a small spinner. Shown
///   centered if nothing has rendered yet, or as a small corner indicator
///   over the previous screen while a follow-up turn is in flight.
/// - error (a `ConversationError` event): a simple inline error banner.
class A2uiSurfaceView extends ConsumerStatefulWidget {
  const A2uiSurfaceView({super.key});

  @override
  ConsumerState<A2uiSurfaceView> createState() => _A2uiSurfaceViewState();
}

class _A2uiSurfaceViewState extends ConsumerState<A2uiSurfaceView> {
  Object? _error;
  StreamSubscription<ConversationEvent>? _eventsSubscription;

  @override
  void initState() {
    super.initState();
    final conversation = ref.read(conversationProvider);
    _eventsSubscription = conversation.events.listen(_onEvent);
  }

  void _onEvent(ConversationEvent event) {
    if (!mounted) return;
    if (event is ConversationError) {
      setState(() => _error = event.error);
    } else if (event is ConversationSurfaceAdded ||
        event is ConversationComponentsUpdated) {
      // Fresh content arrived; clear any previously shown error.
      if (_error != null) setState(() => _error = null);
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider);
    final controller = ref.watch(a2uiSurfaceControllerProvider);

    if (_error != null) {
      return _InlineError(error: _error!);
    }

    return ValueListenableBuilder<ConversationState>(
      valueListenable: conversation.state,
      builder: (context, state, _) {
        final String? surfaceId = state.surfaces.isEmpty
            ? null
            : state.surfaces.last;

        if (surfaceId == null) {
          if (state.isWaiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        }

        final Widget surface = Surface(
          key: ValueKey(surfaceId),
          surfaceContext: controller.contextFor(surfaceId),
        );

        if (!state.isWaiting) return surface;

        return Stack(
          children: [
            surface,
            const Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Something went wrong. Please try again.',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
