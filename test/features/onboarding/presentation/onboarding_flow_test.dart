import 'package:drift/native.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/database/database_provider.dart';
import 'package:farmer_herder_conflict_tracker/features/onboarding/presentation/onboarding_flow.dart';
import 'package:farmer_herder_conflict_tracker/features/onboarding/presentation/pages/permissions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory Drift DB per test — never touches the real on-device cache.
    db = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: child),
    );
  }

  testWidgets(
    'onboarding flow renders and swiping to the last tutorial step then '
    'tapping Get Started invokes onComplete',
    (tester) async {
      var completed = false;

      await tester.pumpWidget(
        wrap(OnboardingFlow(onComplete: () => completed = true)),
      );
      // Resolve the initial "has onboarded?" cache lookup.
      await tester.pumpAndSettle();

      // Welcome screen.
      expect(find.text('Welcome to Conflict Tracker'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Permissions screen.
      expect(find.text('We need access to help you'), findsOneWidget);
      expect(find.text('Allow All'), findsOneWidget);
      expect(find.text('Allow Later'), findsOneWidget);

      await tester.tap(find.text('Allow Later'));
      await tester.pumpAndSettle();

      // Tutorial screen — first step.
      expect(find.text('Press and hold to report'), findsOneWidget);
      expect(completed, isFalse);

      // Swipe through steps 2-4 via the "Next" button.
      for (final expectedText in [
        'Or type your report',
        'See threats on the map',
        'Share with your community',
      ]) {
        expect(find.text('Next'), findsOneWidget);
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text(expectedText), findsOneWidget);
      }

      // Last step shows "Get Started" instead of "Next".
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    },
  );

  testWidgets(
    'skipping from the welcome screen invokes onComplete without showing '
    'the rest of the flow',
    (tester) async {
      var completed = false;

      await tester.pumpWidget(
        wrap(OnboardingFlow(onComplete: () => completed = true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    },
  );

  testWidgets(
    'permissions screen renders location/microphone rationale copy and '
    'does not crash or block progress when permissions are denied',
    (tester) async {
      var continued = false;

      await tester.pumpWidget(
        wrap(
          PermissionsScreen(
            onContinue: () => continued = true,
            // Fakes standing in for the real geolocator/record plugin
            // calls — there's no OS permission dialog or platform channel
            // to drive in a widget test, so this simulates the user
            // denying both permissions.
            requestLocation: () async => false,
            requestMicrophone: () async => false,
          ),
        ),
      );

      expect(
        find.text('Location: To show you nearby threats'),
        findsOneWidget,
      );
      expect(
        find.text('Microphone: To record your voice reports'),
        findsOneWidget,
      );

      // Exercises the denied path — it must not throw, and must still
      // leave the user a way to continue (no blocking on denial).
      await tester.tap(find.text('Allow All'));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
      expect(
        find.textContaining('you can still use text input'),
        findsOneWidget,
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(continued, isTrue);
    },
  );

  testWidgets(
    'a previously-completed onboarding flag skips straight to onComplete',
    (tester) async {
      final now = DateTime.now();
      await db
          .into(db.cache)
          .insertOnConflictUpdate(
            CacheCompanion.insert(
              key: 'has_onboarded',
              value: 'true',
              timestamp: now,
              expiresAt: now.add(const Duration(days: 1)),
            ),
          );

      var completed = false;
      await tester.pumpWidget(
        wrap(OnboardingFlow(onComplete: () => completed = true)),
      );
      // Deliberately not pumpAndSettle: the flow stays on its loading gate
      // (indeterminate spinner) after calling onComplete — it expects the
      // caller to swap it out for the real app shell rather than
      // transitioning itself, so there's no "settled" state to await here.
      await tester.pump();
      await tester.pump();

      expect(completed, isTrue);
      expect(find.text('Welcome to Conflict Tracker'), findsNothing);
    },
  );
}
