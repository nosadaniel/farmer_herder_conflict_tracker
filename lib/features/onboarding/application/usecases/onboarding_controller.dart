import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

part 'onboarding_controller.g.dart';

/// Drift `Cache` key used to remember that the user has already been
/// through the onboarding flow, so it doesn't necessarily show on every
/// cold start (see task.md Track E deliverable #3).
const String onboardingCompleteCacheKey = 'has_onboarded';

/// Tracks whether the user has completed onboarding before, backed by the
/// shared Drift `Cache` table (read-only dependency on
/// `appDatabaseProvider` — this track does not own `core/database`).
///
/// [build] resolves to `true`/`false` based on the persisted flag. If the
/// cache read fails for any reason (fresh install, storage error, etc.) it
/// fails open to `false` so onboarding is shown rather than the app getting
/// stuck.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  Future<bool> build() async {
    final db = ref.watch(appDatabaseProvider);
    try {
      final row = await (db.select(
        db.cache,
      )..where((t) => t.key.equals(onboardingCompleteCacheKey))).getSingleOrNull();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  /// Marks onboarding as complete. Best-effort: a failed cache write should
  /// never block the user from entering the app, so callers should proceed
  /// to `onComplete` regardless of whether this throws.
  Future<void> complete() async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    await db
        .into(db.cache)
        .insertOnConflictUpdate(
          CacheCompanion.insert(
            key: onboardingCompleteCacheKey,
            value: 'true',
            timestamp: now,
            // Effectively "forever" for a hackathon demo — there's no
            // separate expiry sweep for this flag.
            expiresAt: now.add(const Duration(days: 3650)),
          ),
        );
    state = const AsyncValue.data(true);
  }
}
