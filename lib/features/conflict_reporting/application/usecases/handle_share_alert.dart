import 'package:genui/genui.dart';
import 'package:share_plus/share_plus.dart';

/// The reserved action-event name Gemini is instructed to emit (per
/// `docs/a2ui_gemini_contract.md` §3 "RESERVED EVENT NAMES" / §7) whenever
/// it offers a share button. The app intercepts this one itself instead of
/// letting it round-trip back to Gemini.
const String shareAlertActionName = 'share_alert';

/// Formats the native share-sheet text for a `share_alert` action.
///
/// Convention from `brainstorm_docs/phase_2_ux_design.md` Screen 8:
/// "Conflict Alert: [summary]. Risk: [level]. Stay safe. -Shared via
/// Conflict Tracker". The UX doc's illustrative `[summary]` was a raw
/// transcription; per the contract, Gemini instead hands us an
/// already-composed one-sentence `summary` suitable for sharing, so it's
/// dropped straight in rather than re-derived.
///
/// Judgment call: [riskLevel] arrives lowercase from Gemini's JSON
/// (`"low"|"medium"|"high"`, per the contract's RESERVED EVENT NAMES spec);
/// this title-cases it for a human-readable share message ("High" not
/// "high"). Unknown/missing risk levels fall back to "Unknown" rather than
/// throwing, since a malformed action shouldn't crash the share flow.
String formatShareAlertText({
  required String summary,
  required String riskLevel,
}) {
  final String trimmedSummary = summary.trim();
  final String level = _titleCase(riskLevel.trim());
  final String body = trimmedSummary.isEmpty
      ? 'Conflict reported nearby.'
      : trimmedSummary;
  return 'Conflict Alert: $body Risk: $level. Stay safe. '
      '-Shared via Conflict Tracker';
}

String _titleCase(String value) {
  if (value.isEmpty) return 'Unknown';
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

/// Signature matching `SharePlus.instance.share`, injectable for tests so
/// they never touch the real native share sheet.
typedef ShareInvoker = Future<ShareResult> Function(ShareParams params);

/// Intercepts genui [UiEvent]s coming out of a rendered `Surface` (per
/// `docs/a2ui_gemini_contract.md` §7): if [event] is the reserved
/// `share_alert` action, this opens the native share sheet with the
/// formatted alert text (pulling `context.summary` + `context.riskLevel`
/// off the event) and returns `true` — the caller should NOT forward the
/// event to Gemini, the app has fully handled it.
///
/// For every other event, this forwards it unchanged to
/// [controller.handleUiEvent] — which is exactly what genui's normal
/// button-tap loop-back to Gemini already does internally (see
/// `SurfaceController.handleUiEvent` / `Conversation`'s
/// `controller.onSubmit.listen(sendRequest)` wiring) — and returns `false`.
///
/// [share] is overridable for tests; defaults to the real
/// `SharePlus.instance.share`.
Future<bool> handleShareAlertInterception(
  UiEvent event,
  SurfaceController controller, {
  ShareInvoker share = _defaultShare,
}) async {
  if (event.isUserAction) {
    final action = UserActionEvent.fromMap(event.toMap());
    if (action.name == shareAlertActionName) {
      final String summary = (action.context['summary'] as String?) ?? '';
      final String riskLevel = (action.context['riskLevel'] as String?) ?? '';
      final String text = formatShareAlertText(
        summary: summary,
        riskLevel: riskLevel,
      );
      await share(ShareParams(text: text, subject: 'Conflict Alert'));
      return true;
    }
  }
  controller.handleUiEvent(event);
  return false;
}

Future<ShareResult> _defaultShare(ShareParams params) {
  return SharePlus.instance.share(params);
}
