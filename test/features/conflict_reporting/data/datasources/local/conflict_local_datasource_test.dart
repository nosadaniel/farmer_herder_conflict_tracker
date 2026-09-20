import 'dart:io';

import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/models/conflict_record_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test for deliverable #1 (task.md): the bundled dataset must parse
/// into the number of records `metadata.total_records` declares, without
/// throwing.
///
/// Reads the asset straight off disk via `dart:io` rather than through
/// `rootBundle`, so this test needs no Flutter widget/asset-bundle test
/// bindings — [parseConflictDataset] is pure JSON parsing with no Flutter
/// dependency.
void main() {
  test(
    'parses the bundled farmer_herder_conflict.json into metadata.total_records rows',
    () async {
      final file = File('assets/data/farmer_herder_conflict.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Bundled dataset asset not found at ${file.path}',
      );

      final jsonString = await file.readAsString();

      final result = parseConflictDataset(jsonString);

      expect(result.totalRecordsMetadata, greaterThan(0));
      expect(result.records.length, result.totalRecordsMetadata);
    },
  );

  test('every parsed record has valid coordinates and a severity label', () {
    final file = File('assets/data/farmer_herder_conflict.json');
    final jsonString = file.readAsStringSync();

    final result = parseConflictDataset(jsonString);

    for (final record in result.records) {
      expect(record.latitude, inInclusiveRange(-90, 90));
      expect(record.longitude, inInclusiveRange(-180, 180));
      expect(['LOW', 'MEDIUM', 'HIGH'], contains(record.severity));
      expect(record.fatalities, greaterThanOrEqualTo(0));
    }
  });

  group('severityForFatalities thresholds', () {
    test('0 fatalities is LOW', () {
      expect(ConflictRecordModel.severityForFatalities(0), 'LOW');
    });

    test('1-9 fatalities is MEDIUM', () {
      expect(ConflictRecordModel.severityForFatalities(1), 'MEDIUM');
      expect(ConflictRecordModel.severityForFatalities(9), 'MEDIUM');
    });

    test('10+ fatalities is HIGH', () {
      expect(ConflictRecordModel.severityForFatalities(10), 'HIGH');
      expect(ConflictRecordModel.severityForFatalities(952), 'HIGH');
    });
  });
}
