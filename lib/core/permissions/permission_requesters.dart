import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';

/// Requests location permission via geolocator's own permission flow — no
/// `permission_handler` dependency needed. Returns whether permission was
/// granted (`always` or `whileInUse`); never throws.
///
/// Extracted from the old `PermissionsScreen` (task.md Phase 5) so both the
/// onboarding flow and the Report Wizard's Step 1 ("Use my current
/// location") can request it in context, at the moment it's actually
/// needed, instead of as a separate upfront ritual.
Future<bool> requestLocationPermission() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  } catch (_) {
    // Platform channel unavailable (e.g. widget tests) or any other
    // failure — treat as denied, never crash the caller.
    return false;
  }
}

/// Requests microphone permission via `record`'s own `hasPermission()` —
/// no `permission_handler` dependency needed. Never throws.
///
/// Extracted from the old `PermissionsScreen` (task.md Phase 5) so the
/// Report Wizard's Step 4 ("Speak") can request it lazily, the first time
/// the user actually taps it, instead of upfront during onboarding.
Future<bool> requestMicrophonePermission() async {
  final recorder = AudioRecorder();
  try {
    return await recorder.hasPermission();
  } catch (_) {
    return false;
  } finally {
    await recorder.dispose();
  }
}
