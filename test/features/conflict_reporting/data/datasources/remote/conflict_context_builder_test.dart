import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/datasources/remote/conflict_context_builder.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<Map<String, dynamic>>> _noNearbyConflicts(
  double lat,
  double lng,
) async => const [];

void main() {
  const builder = ConflictContextBuilder();

  group('ConflictContextBuilder.build with wizardAnswers', () {
    test('assembles all three keys into the expected Report: line shape', () async {
      final block = await builder.build(
        lat: 9.0,
        lng: 8.5,
        surfaceId: 'report_1',
        getNearbyConflicts: _noNearbyConflicts,
        wizardAnswers: const {
          'whatsHappening': 'Herd moving toward farmland.',
          'whoInvolved': 'Both',
          'detailText': 'the herd crossed near the stream this morning',
        },
      );

      expect(
        block,
        contains(
          'Report: "Herd moving toward farmland. People involved: Both. '
          'Additional detail: "the herd crossed near the stream this morning""',
        ),
      );
    });

    test('omits missing parts when only whatsHappening is present', () async {
      final block = await builder.build(
        lat: 9.0,
        lng: 8.5,
        surfaceId: 'report_2',
        getNearbyConflicts: _noNearbyConflicts,
        wizardAnswers: const {'whatsHappening': 'Herd moving toward farmland.'},
      );

      expect(
        block,
        contains('Report: "Herd moving toward farmland."'),
      );
      expect(block, isNot(contains('People involved:')));
      expect(block, isNot(contains('Additional detail:')));
    });

    test('falls back to a neutral string for an empty wizardAnswers map', () async {
      final block = await builder.build(
        lat: 9.0,
        lng: 8.5,
        surfaceId: 'report_3',
        getNearbyConflicts: _noNearbyConflicts,
        wizardAnswers: const {},
      );

      expect(block, contains('Report: "Report submitted via guided wizard."'));
    });

    test('does not break quoting when detailText has special characters', () async {
      final block = await builder.build(
        lat: 9.0,
        lng: 8.5,
        surfaceId: 'report_4',
        getNearbyConflicts: _noNearbyConflicts,
        wizardAnswers: const {
          'whatsHappening': 'Tension near the market.',
          'detailText': 'She said "run now" and pointed north — very tense.',
        },
      );

      expect(
        block,
        contains(
          'Report: "Tension near the market. Additional detail: "She said '
          '"run now" and pointed north — very tense.""',
        ),
      );
      // The context block must still be well-formed line-by-line: the
      // Report: line begins right after "Use this surfaceId:" and doesn't
      // swallow the following "Nearby historical conflicts" line.
      expect(block, contains('Nearby historical conflicts (within 25km):'));
    });

    test('treats blank-only values as absent', () async {
      final block = await builder.build(
        lat: 9.0,
        lng: 8.5,
        surfaceId: 'report_5',
        getNearbyConflicts: _noNearbyConflicts,
        wizardAnswers: const {
          'whatsHappening': 'Herd sighted.',
          'whoInvolved': '   ',
          'detailText': '',
        },
      );

      expect(block, contains('Report: "Herd sighted."'));
      expect(block, isNot(contains('People involved:')));
      expect(block, isNot(contains('Additional detail:')));
    });
  });

  group('ConflictContextBuilder.build exactly-one-of assertion', () {
    test('providing none of reportText/actionEventName/wizardAnswers asserts', () {
      expect(
        () => builder.build(
          lat: 9.0,
          lng: 8.5,
          surfaceId: 'report_6',
          getNearbyConflicts: _noNearbyConflicts,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('providing more than one of them asserts', () {
      expect(
        () => builder.build(
          lat: 9.0,
          lng: 8.5,
          surfaceId: 'report_7',
          getNearbyConflicts: _noNearbyConflicts,
          reportText: 'text',
          wizardAnswers: const {'whatsHappening': 'x'},
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('ConflictContextBuilder.build existing reportText/actionEventName paths', () {
    test('reportText path is unchanged', () async {
      final block = await builder.build(
        lat: 1.0,
        lng: 2.0,
        surfaceId: 'report_8',
        getNearbyConflicts: _noNearbyConflicts,
        reportText: 'Freeform voice/text report.',
      );

      expect(block, contains('Report: "Freeform voice/text report."'));
    });

    test('actionEventName path is unchanged', () async {
      final block = await builder.build(
        lat: 1.0,
        lng: 2.0,
        surfaceId: 'report_9',
        getNearbyConflicts: _noNearbyConflicts,
        actionEventName: 'call_help',
        actionContext: const {'foo': 'bar'},
      );

      expect(
        block,
        contains('User tapped: "call_help" (context: {"foo":"bar"})'),
      );
    });
  });
}
