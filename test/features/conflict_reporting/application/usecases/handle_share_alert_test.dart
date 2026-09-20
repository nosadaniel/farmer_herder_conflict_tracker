import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/application/usecases/handle_share_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatShareAlertText', () {
    test('formats summary + risk level per the UX Screen 8 convention', () {
      final text = formatShareAlertText(
        summary: 'Herd crossing toward farms near Kaduna.',
        riskLevel: 'high',
      );

      expect(
        text,
        'Conflict Alert: Herd crossing toward farms near Kaduna. Risk: High. '
        'Stay safe. -Shared via Conflict Tracker',
      );
    });

    test('title-cases a lowercase risk level', () {
      final text = formatShareAlertText(
        summary: 'Herd sighted nearby.',
        riskLevel: 'medium',
      );

      expect(text, contains('Risk: Medium.'));
    });

    test('falls back to a default sentence when summary is empty', () {
      final text = formatShareAlertText(summary: '', riskLevel: 'high');

      expect(text, startsWith('Conflict Alert: Conflict reported nearby.'));
    });

    test('falls back to "Unknown" when risk level is empty', () {
      final text = formatShareAlertText(
        summary: 'Herd sighted nearby.',
        riskLevel: '',
      );

      expect(text, contains('Risk: Unknown.'));
    });
  });
}
