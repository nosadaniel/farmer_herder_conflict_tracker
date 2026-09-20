import 'package:drift/native.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/database/database_provider.dart';
import 'package:farmer_herder_conflict_tracker/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and shows onboarding on first launch', (
    tester,
  ) async {
    // In-memory Drift instance (same pattern as the repository tests) so
    // this never touches a real device DB file, and Firebase.initializeApp()
    // is skipped since we pump ConflictTrackerApp directly rather than
    // going through main().
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const ConflictTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Fresh in-memory DB -> no "has_onboarded" flag -> appRouterProvider's
    // redirect (lib/app/routing/app_router.dart) sends us to /onboarding,
    // not the main shell.
    expect(find.text('Welcome to Conflict Tracker'), findsOneWidget);
  });
}
