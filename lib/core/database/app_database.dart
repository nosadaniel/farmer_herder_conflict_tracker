import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Reports, ConflictData, Cache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests/tracks that need an in-memory or injected connection instead
  /// of the default on-device file.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'farmer_herder_conflict_tracker');
}
