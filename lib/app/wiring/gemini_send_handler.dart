// The real implementation of a2uiSendHandlerProvider (Track C's seam,
// lib/features/conflict_reporting/presentation/a2ui/providers/a2ui_providers.dart)
// — wired via a ProviderScope override here rather than editing that file
// directly, to avoid a circular import (report_submission_controller.dart
// already imports a2ui_providers.dart for the transport/surface-controller
// providers it needs).
//
// This is the one thing genui calls automatically for button-tap
// follow-ups: SurfaceController.handleUiEvent -> Conversation's internal
// `controller.onSubmit.listen(sendRequest)` -> A2uiTransportAdapter.onSend
// -> this handler. Fresh voice/text reports bypass this entirely —
// ReportSubmissionController.submitVoice/submitText are called directly by
// the mic button / text modal, not via Conversation.sendRequest.
import 'dart:convert';

import 'package:genui/genui.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/conflict_reporting/application/usecases/handle_share_alert.dart';
import '../../features/conflict_reporting/application/usecases/report_submission_controller.dart';
import '../../features/conflict_reporting/presentation/a2ui/providers/a2ui_providers.dart';

final geminiSendHandlerOverride = a2uiSendHandlerProvider.overrideWith((ref) {
  return (ChatMessage message) async {
    final interactionParts = message.parts.uiInteractionParts.toList();
    if (interactionParts.isEmpty) {
      // We only expect button-tap follow-ups to arrive here — fresh
      // voice/text reports never go through Conversation.sendRequest.
      return;
    }

    final decoded =
        jsonDecode(interactionParts.first.interaction) as Map<String, dynamic>;
    final action = decoded['action'] as Map<String, dynamic>? ?? const {};
    final name = action['name'] as String? ?? '';
    final context =
        (action['context'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    // share_alert is handled entirely client-side (docs/a2ui_gemini_contract.md
    // §7) — never forwarded to Gemini. Reuses handle_share_alert.dart's
    // formatting logic directly rather than its
    // handleShareAlertInterception helper, which expects to intercept a raw
    // UiEvent before SurfaceController.handleUiEvent is called; by the time
    // a ChatMessage reaches this onSend callback, that dispatch has already
    // happened — the important part (not forwarding to Gemini) still holds,
    // we just share here and return instead of calling SubmitReport.
    if (name == shareAlertActionName) {
      final summary = context['summary'] as String? ?? '';
      final riskLevel = context['riskLevel'] as String? ?? '';
      await SharePlus.instance.share(
        ShareParams(
          text: formatShareAlertText(summary: summary, riskLevel: riskLevel),
          subject: 'Conflict Alert',
        ),
      );
      return;
    }

    await ref
        .read(reportSubmissionControllerProvider.notifier)
        .handleActionFollowUp(name, context);
  };
});
