import 'package:drift/drift.dart';

/// User-submitted conflict reports (voice or text), including the A2UI
/// blueprint returned for that report so it can be replayed offline.
class Reports extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get transcription => text()();
  TextColumn get riskLevel => text()(); // LOW, MEDIUM, HIGH
  TextColumn get a2uiBlueprint => text()(); // JSON string
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

/// Historical conflict records, pre-loaded from the bundled
/// farmer_herder_conflict.json dataset asset.
class ConflictData extends Table {
  IntColumn get id => integer()();
  DateTimeColumn get date => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get type => text()(); // e.g. "farmer-herder"
  TextColumn get severity => text()(); // LOW, MEDIUM, HIGH
  IntColumn get fatalities => integer().withDefault(const Constant(0))();
  TextColumn get locationName => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A2UI blueprint cache for offline rehydration — keyed by a semantic key
/// such as `${AppConstants.lastBlueprintCacheKey}_<sector>`.
class Cache extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()(); // JSON blueprint
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
