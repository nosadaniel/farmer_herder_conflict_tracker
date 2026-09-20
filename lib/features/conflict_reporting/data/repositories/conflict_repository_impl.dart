import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/data/datasources/local/conflict_local_datasource.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/repositories/conflict_repository.dart';

/// Concrete [ConflictRepository] backed by [ConflictLocalDataSource]
/// (bundled-asset + Drift `ConflictData` table).
///
/// Named `conflict_repository_impl.dart` (not `conflict_repository.dart`)
/// deliberately: Track D also owns files under
/// `conflict_reporting/data/repositories` (report/cache repositories) and
/// this name keeps the two tracks' files unambiguous when merged.
class ConflictRepositoryImpl implements ConflictRepository {
  const ConflictRepositoryImpl(this._localDataSource);

  final ConflictLocalDataSource _localDataSource;

  @override
  Future<void> ensureSeeded() {
    return _localDataSource.seedFromBundledDatasetIfEmpty();
  }

  @override
  Future<List<ConflictDataData>> getAllConflicts() {
    return _localDataSource.getAll();
  }
}
