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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

import '../../../../../core/widgets/app_skeleton.dart';
import '../providers/a2ui_providers.dart';

/// Drop-in widget for the app shell's "dynamic canvas" slot.
///
/// Handles the two states the contract asks for, kept deliberately minimal
/// (no animations/transitions):
/// - loading (`Conversation.state.isWaiting`): if nothing has rendered yet,
///   an [AppSkeleton]-shimmered placeholder shaped like a typical A2UI
///   response (icon + headline + body + buttons, per the contract doc's
///   component composition) — gives an expectant sense of the incoming
///   layout rather than a blank spinner. If a surface is already showing
///   and a follow-up turn is in flight, a small corner spinner overlays the
///   existing content instead — skeletons are for "nothing to show yet,"
///   not for covering content that's already visible.
/// - error (`conversationErrorProvider`, mirroring `ConversationError`
///   events — see a2ui_providers.dart): a simple inline error banner.
///
/// A plain `ConsumerWidget`, not `ConsumerStatefulWidget` — task.md's Phase
/// 2 architecture: the error state it used to track via a manually-managed
/// `StreamSubscription` in local `State` is business state Riverpod already
/// owns (`conversationErrorProvider`), not a UI-owned controller object, so
/// it belongs in a provider, not here.
class A2uiSurfaceView extends ConsumerWidget {
  const A2uiSurfaceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(conversationProvider);
    final controller = ref.watch(a2uiSurfaceControllerProvider);
    final error = ref.watch(conversationErrorProvider).value;

    if (error != null) {
      return _InlineError(error: error);
    }

    return ValueListenableBuilder<ConversationState>(
      valueListenable: conversation.state,
      builder: (context, state, _) {
        final String? surfaceId = state.surfaces.isEmpty
            ? null
            : state.surfaces.last;

        if (surfaceId == null) {
          if (state.isWaiting) {
            return const _A2uiSkeletonLoader();
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

/// Shimmered placeholder shown while waiting for Gemini's first response —
/// a fake layout shaped like a typical risk-state screen (icon, headline,
/// body text, 1-2 action buttons; see `docs/a2ui_gemini_contract.md` §3
/// "WHAT TO GENERATE" and §6's worked example), composed with the shared
/// [AppSkeleton] wrapper so the shimmer traces the *shape* of what's coming
/// rather than a content-free spinner, with the same brand-consistent
/// shimmer every other loading state in the app uses.
class _A2uiSkeletonLoader extends StatelessWidget {
  const _A2uiSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 32),
            const SizedBox(height: 12),
            Text(
              'Assessing the situation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'One or two sentences describing what is happening and what '
              'to do next will appear here shortly.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Primary action'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: null,
                child: const Text('Secondary action'),
              ),
            ),
          ],
        ),
      ),
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
