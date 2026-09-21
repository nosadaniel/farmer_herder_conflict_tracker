import 'package:drift/native.dart';
import 'package:farmer_herder_conflict_tracker/core/database/app_database.dart';
import 'package:farmer_herder_conflict_tracker/core/database/database_provider.dart';
import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/application/usecases/report_submission_controller.dart';
import 'package:farmer_herder_conflict_tracker/features/map/application/providers/map_providers.dart';
import 'package:farmer_herder_conflict_tracker/features/map/domain/entities/app_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests exercise [ReportSubmissionController.submitStructured]'s
/// location-resolution bypass (task.md bridge work): when concrete
/// lat/lng are supplied, `_run` must skip the `currentLocationProvider`
/// GPS-resolution read entirely.
///
/// `_run` always funnels into a real `SubmitReport` backed by
/// `GeminiRemoteDataSource.production()` (not injectable from outside the
/// controller), so these tests can't exercise a live/successful Gemini
/// call in a unit-test environment — that's fine: the location-bypass
/// logic runs synchronously *before* any Gemini call, and the controller's
/// own `_run` catches every downstream failure into `ReportFailed` state,
/// so `submitStructured`/`submitVoice`/`submitText` always complete
/// without throwing. What's asserted here is purely whether
/// `currentLocationProvider` was read, via a probe override.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('submitStructured with overrideLat/overrideLng bypasses currentLocationProvider', () async {
    var locationProviderRead = false;

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
        currentLocationProvider.overrideWith((ref) async {
          locationProviderRead = true;
          return const AppLocationKnown(latitude: 1.23, longitude: 4.56);
        }),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(reportSubmissionControllerProvider.notifier)
        .submitStructured(
          wizardAnswers: const {'whatsHappening': 'Herd sighted.'},
          lat: 9.99,
          lng: 8.88,
        );

    expect(
      locationProviderRead,
      isFalse,
      reason:
          'currentLocationProvider must not be read when overrideLat/'
          'overrideLng are both supplied',
    );
  });

  test('submitVoice (no override) still resolves location via currentLocationProvider', () async {
    var locationProviderRead = false;

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
        currentLocationProvider.overrideWith((ref) async {
          locationProviderRead = true;
          return const AppLocationKnown(latitude: 1.23, longitude: 4.56);
        }),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(reportSubmissionControllerProvider.notifier)
        .submitText('A freeform text report.');

    expect(
      locationProviderRead,
      isTrue,
      reason:
          'submitText (no overrideLat/overrideLng) must still resolve '
          'location via currentLocationProvider, unchanged from before '
          'the wizard bridge was added',
    );
  });
}
