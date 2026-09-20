import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';

/// Domain-facing contract for reading historical conflict data.
///
/// The implementation lives in
/// `lib/features/conflict_reporting/data/repositories/conflict_repository_impl.dart`
/// rather than under `lib/features/map/data/**` — this split follows
/// task.md's Track A folder ownership, which puts the conflict-data
/// repository implementation in `conflict_reporting/data/repositories` (a
/// sibling of Track D's report/cache repositories) while the map feature
/// owns the domain contract and consumes it. Both folders are owned by
/// Track A, so this cross-feature wiring is intentional, not accidental
/// coupling.
abstract class ConflictRepository {
  /// Loads the bundled dataset into local storage on first run (no-op if
  /// already seeded). Call before [getAllConflicts] to guarantee data is
  /// present.
  Future<void> ensureSeeded();

  /// All historical conflict records currently in local storage.
  Future<List<ConflictDataData>> getAllConflicts();
}
