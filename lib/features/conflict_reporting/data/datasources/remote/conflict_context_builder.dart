import 'dart:convert';

/// Builds the per-turn plain-text context block prepended to every Gemini
/// call, per `docs/a2ui_gemini_contract.md` §5 — re-sent on *every* turn
/// (fresh report or button-triggered follow-up), never assumed to persist
/// across `firebase_ai` calls (each call is stateless: system instruction +
/// this one context block as the user message).
///
/// Nearby-conflict data is supplied via an injected [getNearbyConflicts]
/// callback rather than imported directly: the historical-conflict
/// datasource is owned by a different track (map/conflict-data) building in
/// a separate git worktree at the same time. A later integration step wires
/// in the real implementation — this builder only needs *something* shaped
/// like `Future<List<Map<String, dynamic>>> Function(double, double)`.
///
/// Expected map keys per conflict record (extra/missing keys degrade
/// gracefully rather than throwing): `distanceKm` (or `distance_km`, num),
/// `date` (String), `severity` (String: LOW/MEDIUM/HIGH), `fatalities`
/// (num), `type` (String).
class ConflictContextBuilder {
  const ConflictContextBuilder();

  /// Builds the context block text.
  ///
  /// Exactly one of [reportText] or [actionEventName] should be provided:
  /// - [reportText]: a fresh voice (already transcribed by
  ///   `GeminiRemoteDataSource.transcribeAudio`) or typed text report.
  /// - [actionEventName] (+ optional [actionContext]): a button-tap
  ///   follow-up from a previously rendered surface (the raw A2UI action
  ///   event Gemini invented on an earlier turn).
  ///
  /// [surfaceId] must be generated client-side by the caller (contract §4:
  /// `'report_${DateTime.now().millisecondsSinceEpoch}'`) — this builder
  /// just places it verbatim in the "Use this surfaceId:" line.
  Future<String> build({
    required double lat,
    required double lng,
    required String surfaceId,
    required Future<List<Map<String, dynamic>>> Function(double lat, double lng)
    getNearbyConflicts,
    String? placeName,
    String? reportText,
    String? actionEventName,
    Map<String, dynamic>? actionContext,
  }) async {
    assert(
      (reportText != null) != (actionEventName != null),
      'Provide exactly one of reportText or actionEventName',
    );

    final conflicts = await getNearbyConflicts(lat, lng);

    final buffer = StringBuffer()
      ..writeln(
        placeName != null && placeName.trim().isNotEmpty
            ? 'Location: $lat, $lng ($placeName)'
            : 'Location: $lat, $lng',
      )
      ..writeln('Use this surfaceId: $surfaceId');

    if (actionEventName != null) {
      buffer.writeln(
        'User tapped: "$actionEventName" '
        '(context: ${jsonEncode(actionContext ?? const <String, dynamic>{})})',
      );
    } else {
      buffer.writeln('Report: "${reportText ?? ''}"');
    }

    buffer.writeln('Nearby historical conflicts (within 25km):');
    if (conflicts.isEmpty) {
      buffer.writeln('- None found.');
    } else {
      for (final conflict in conflicts.take(5)) {
        final distanceKm = _readNum(conflict, const [
          'distanceKm',
          'distance_km',
          'distance',
        ]);
        final date = _readString(conflict, const ['date']);
        final severity = _readString(conflict, const ['severity']);
        final fatalities = _readNum(conflict, const ['fatalities']);
        final type = _readString(conflict, const ['type']);

        buffer.writeln(
          '- ${distanceKm != null ? '${distanceKm}km' : '?km'}, '
          '${date ?? '?'}, '
          'severity ${severity ?? 'UNKNOWN'}, '
          '${fatalities ?? 0} fatalities, '
          '${type ?? 'unspecified'}',
        );
      }
    }

    return buffer.toString().trimRight();
  }

  static num? _readNum(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null) return value.toString();
    }
    return null;
  }
}
