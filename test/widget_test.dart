import 'package:drift/native.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/database/database_provider.dart';
import 'package:farmer_herder_conflict_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and shows onboarding on first launch', (tester) async {
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
    expect(find.text('Know Before Trouble Arrives'), findsOneWidget);
  });

  testWidgets(
    'Onboarding completes to the wizard, and MainScreen\'s Report CTA '
    'also reaches the wizard',
    (tester) async {
      // Regression coverage for two bugs found via on-device testing
      // (task.md Phase 5): (1) completing onboarding raced appRouter's old
      // rebuild-a-new-GoRouter-on-state-change design, silently landing on
      // Home instead of the wizard — fixed via refreshListenable (see
      // app_router.dart's doc comment); (2) MainScreen's "Report" CTA
      // appeared unresponsive during manual on-device taps — root cause
      // was ultimately in the taps' pixel coordinates, not the app, but
      // this test removes coordinate guessing entirely by finding widgets
      // semantically (find.text/find.byIcon), which is what should have
      // been used for on-device verification from the start.
      final db = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const ConflictTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Welcome screen -> Start.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Start'));
      await tester.pumpAndSettle();

      // Tutorial carousel: 3 "Next" taps to reach the last of 4 steps, then
      // "Get Started" (per docs/report_wizard_ux_flow.md: onboarding ends
      // by dropping the user straight into the wizard, not home).
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
      // Not pumpAndSettle here: the wizard's step-1 skeleton loader
      // (AppSkeleton/Skeletonizer shimmer) repeats indefinitely while
      // ReportWizardController.initialize() attempts a live Gemini call
      // in-flight, which pumpAndSettle can never consider "settled". A
      // handful of bounded pumps is enough for the navigation transition
      // and the (in this Firebase-less test env, immediately-failing)
      // generation attempt to resolve.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }

      // Must land on the wizard's first step ("Where?"), not Home — this is
      // the exact assertion that would have caught the refreshListenable
      // bug: before that fix, this found "Tap Report below..." (MainScreen)
      // instead.
      expect(find.text('Where?'), findsOneWidget);
      expect(find.text('Tap Report below to log what you see.'), findsNothing);

      // Exit the wizard back to Home via the leading back arrow (wired to
      // HomeRoute.go in app_router.dart's ReportWizardScreen builder).
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(
        find.text('Tap Report below to log what you see.'),
        findsOneWidget,
      );

      // MainScreen's "Report" CTA must also reach the wizard.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Report'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(find.text('Where?'), findsOneWidget);
    },
  );
}
