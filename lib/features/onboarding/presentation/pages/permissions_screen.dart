import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';

import '../../../../core/theme/app_colors.dart';

enum _PermissionStatus { unknown, granted, denied }

/// Onboarding Screen 3 (UX doc): location + microphone rationale, requested
/// via `geolocator`'s and `record`'s own built-in permission APIs (no
/// `permission_handler` dependency). Denial never blocks progress — per
/// Flow 1's "Error State: Permissions denied" the user can always continue
/// and fall back to text input / cached map data later.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({
    required this.onContinue,
    this.requestLocation,
    this.requestMicrophone,
    super.key,
  });

  final VoidCallback onContinue;

  /// Overridable hooks for the actual permission requests — default to the
  /// real geolocator/record-backed implementations below. Widget tests
  /// inject fakes here instead, since there's no real OS permission dialog
  /// to drive (and no platform channel) in a test harness.
  final Future<bool> Function()? requestLocation;
  final Future<bool> Function()? requestMicrophone;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  _PermissionStatus _locationStatus = _PermissionStatus.unknown;
  _PermissionStatus _microphoneStatus = _PermissionStatus.unknown;
  bool _requesting = false;
  bool _requested = false;

  bool get _anyDenied =>
      _locationStatus == _PermissionStatus.denied ||
      _microphoneStatus == _PermissionStatus.denied;

  Future<void> _requestAll() async {
    setState(() => _requesting = true);

    final requestLocation = widget.requestLocation ?? _requestLocationImpl;
    final requestMicrophone =
        widget.requestMicrophone ?? _requestMicrophoneImpl;

    final locationGranted = await requestLocation();
    final microphoneGranted = await requestMicrophone();

    if (!mounted) return;
    setState(() {
      _locationStatus = locationGranted
          ? _PermissionStatus.granted
          : _PermissionStatus.denied;
      _microphoneStatus = microphoneGranted
          ? _PermissionStatus.granted
          : _PermissionStatus.denied;
      _requesting = false;
      _requested = true;
    });
  }

  /// Uses geolocator's own permission flow — no permission_handler needed.
  Future<bool> _requestLocationImpl() async {
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
      // failure — treat as denied, never crash the onboarding flow.
      return false;
    }
  }

  /// Uses record's own `hasPermission()`, which requests the OS microphone
  /// permission and returns whether it was granted — no permission_handler
  /// needed.
  Future<bool> _requestMicrophoneImpl() async {
    final recorder = AudioRecorder();
    try {
      return await recorder.hasPermission();
    } catch (_) {
      return false;
    } finally {
      await recorder.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 48, color: AppColors.primary),
                  SizedBox(width: 16),
                  Icon(Icons.mic, size: 48, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'We need access to help you',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              _PermissionLine(
                icon: Icons.location_on_outlined,
                text: 'Location: To show you nearby threats',
                status: _locationStatus,
              ),
              const SizedBox(height: 12),
              _PermissionLine(
                icon: Icons.mic_outlined,
                text: 'Microphone: To record your voice reports',
                status: _microphoneStatus,
              ),
              if (_requested && _anyDenied) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Text(
                    'No problem — you can still use text input and view the '
                    'map. You can turn these on anytime in your phone '
                    'Settings.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
              const Spacer(),
              if (!_requested) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requesting ? null : _requestAll,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: _requesting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Allow All'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.onContinue,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Allow Later'),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionLine extends StatelessWidget {
  const _PermissionLine({
    required this.icon,
    required this.text,
    required this.status,
  });

  final IconData icon;
  final String text;
  final _PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        if (status == _PermissionStatus.granted)
          const Icon(Icons.check_circle, color: AppColors.success, size: 24)
        else if (status == _PermissionStatus.denied)
          const Icon(Icons.cancel, color: AppColors.danger, size: 24),
      ],
    );
  }
}
