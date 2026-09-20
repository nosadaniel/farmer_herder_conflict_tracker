import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';

/// Parsed representation of one record from the bundled
/// `assets/data/farmer_herder_conflict.json` dataset (see
/// [ConflictRecordModel.fromJson] for the exact source shape), already
/// mapped onto the fields the Drift `ConflictData` table expects.
///
/// Field mapping (per task.md Track A + phase_2_tech_architecture.md):
/// - `deaths.best_estimate` -> [fatalities]
/// - `adm_1` -> [locationName] (falls back to `location.description`)
/// - `dyad_name` -> [type] (falls back to a fixed "farmer-herder" string)
/// - [severity] is derived from [fatalities] (see [severityForFatalities])
class ConflictRecordModel {
  const ConflictRecordModel({
    required this.id,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.severity,
    required this.fatalities,
    required this.locationName,
  });

  final int id;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String type;
  final String severity;
  final int fatalities;
  final String locationName;

  /// Parses one raw record from the `data` array of the bundled dataset.
  ///
  /// Returns `null` (rather than throwing) when the record is missing
  /// fields essential for placing it on a map (id/lat/lng) — this keeps a
  /// handful of malformed rows from aborting the entire bundled-dataset
  /// load. As of the current bundled dataset (555 records) every record has
  /// all required fields, so this is a defensive fallback, not the
  /// expected path.
  static ConflictRecordModel? fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    final lat = (json['latitude'] as num?)?.toDouble();
    final lng = (json['longitude'] as num?)?.toDouble();
    if (id == null || lat == null || lng == null) return null;

    final deaths = json['deaths'] as Map<String, dynamic>? ?? const {};
    final fatalities = (deaths['best_estimate'] as num?)?.toInt() ?? 0;

    final location = json['location'] as Map<String, dynamic>? ?? const {};
    final adm1 = (json['adm_1'] as String?)?.trim();
    final locationDescription = (location['description'] as String?)?.trim();
    final locationName = (adm1 != null && adm1.isNotEmpty)
        ? adm1
        : (locationDescription != null && locationDescription.isNotEmpty)
        ? locationDescription
        : 'Unknown location';

    final dyadName = (json['dyad_name'] as String?)?.trim();
    final type = (dyadName != null && dyadName.isNotEmpty)
        ? dyadName
        : 'farmer-herder';

    final dateString =
        (json['date_start'] as String?) ?? (json['date_end'] as String?);
    final date = dateString != null
        ? (DateTime.tryParse(dateString) ?? DateTime.fromMillisecondsSinceEpoch(0))
        : DateTime.fromMillisecondsSinceEpoch(0);

    return ConflictRecordModel(
      id: id,
      date: date,
      latitude: lat,
      longitude: lng,
      type: type,
      severity: severityForFatalities(fatalities),
      fatalities: fatalities,
      locationName: locationName,
    );
  }

  /// Judgment call (flagged in Track A's final report): thresholds are our
  /// own choice, not specified by the dataset or UX doc.
  /// 0 fatalities -> LOW, 1-9 -> MEDIUM, 10+ -> HIGH.
  static String severityForFatalities(int fatalities) {
    if (fatalities <= 0) return 'LOW';
    if (fatalities < 10) return 'MEDIUM';
    return 'HIGH';
  }

  ConflictDataCompanion toCompanion() {
    return ConflictDataCompanion.insert(
      id: Value(id),
      date: date,
      latitude: latitude,
      longitude: longitude,
      type: type,
      severity: severity,
      fatalities: Value(fatalities),
      locationName: locationName,
    );
  }
}

/// Result of parsing the bundled dataset's top-level JSON object: both the
/// `metadata.total_records` count (used by the smoke test to verify nothing
/// was silently dropped) and the successfully-parsed records.
class ConflictDatasetParseResult {
  const ConflictDatasetParseResult({
    required this.totalRecordsMetadata,
    required this.records,
  });

  /// `metadata.total_records` as declared by the dataset file itself.
  final int totalRecordsMetadata;

  /// Successfully parsed records (see [ConflictRecordModel.fromJson] for
  /// when a record is skipped).
  final List<ConflictRecordModel> records;
}

/// Pure JSON parsing for the bundled `farmer_herder_conflict.json` asset —
/// deliberately has no dependency on Flutter's asset bundle so it can be
/// unit-tested by reading the file straight off disk (see
/// `test/features/conflict_reporting/data/datasources/local/conflict_local_datasource_test.dart`).
ConflictDatasetParseResult parseConflictDataset(String jsonString) {
  final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  final metadata = decoded['metadata'] as Map<String, dynamic>? ?? const {};
  final totalRecords = (metadata['total_records'] as num?)?.toInt() ?? 0;

  final rawList = decoded['data'] as List<dynamic>? ?? const [];
  final records = <ConflictRecordModel>[];
  for (final raw in rawList) {
    final record = ConflictRecordModel.fromJson(raw as Map<String, dynamic>);
    if (record != null) records.add(record);
  }

  return ConflictDatasetParseResult(
    totalRecordsMetadata: totalRecords,
    records: records,
  );
}
