import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Press-and-hold voice-report capture button (PRD Flow 1 steps 3-4).
///
/// Starts recording on press-down, stops on release, and auto-stops after
/// [AppConstants.maxRecordingDuration] if still held. The recorded audio
/// bytes (AAC/`.m4a`) are handed to [onRecordingComplete] — the caller (a
/// later integration step) feeds those into `SubmitReport` via
/// `SubmitReportParams.audioBytes`.
///
/// Permission handling goes entirely through `record`'s own
/// `AudioRecorder.hasPermission()` API — no separate `permission_handler`
/// package needed. A denial (or any mid-recording platform error) is
/// reported via [onError] instead of throwing, so the caller can show a
/// SnackBar and/or fall back to [TextInputModal].
///
/// Note: recording requires the `RECORD_AUDIO` permission to be declared in
/// `android/app/src/main/AndroidManifest.xml`, which is outside this
/// widget's/track's file ownership — flagged separately for integration.
class MicrophoneButton extends StatefulWidget {
  const MicrophoneButton({
    required this.onRecordingComplete,
    this.onError,
    this.onRecordingStart,
    this.onRecordingStop,
    this.radius = 32,
    super.key,
  });

  /// Called with the recorded audio bytes once recording stops successfully.
  final ValueChanged<Uint8List> onRecordingComplete;

  /// Called with a human-readable message on permission denial or any
  /// recording failure.
  final ValueChanged<String>? onError;

  /// Called the moment recording actually starts (after permission checks).
  final VoidCallback? onRecordingStart;

  /// Called when recording stops, before [onRecordingComplete]/[onError].
  final VoidCallback? onRecordingStop;

  final double radius;

  @override
  State<MicrophoneButton> createState() => _MicrophoneButtonState();
}

class _MicrophoneButtonState extends State<MicrophoneButton> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _maxDurationTimer;
  bool _isRecording = false;

  @override
  void dispose() {
    _maxDurationTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        widget.onError?.call(
          'Microphone permission denied. Use text input instead.',
        );
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      if (!mounted) return;
      setState(() => _isRecording = true);
      widget.onRecordingStart?.call();

      _maxDurationTimer?.cancel();
      _maxDurationTimer = Timer(
        AppConstants.maxRecordingDuration,
        _stopRecording,
      );
    } catch (e) {
      widget.onError?.call('Could not start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    _maxDurationTimer?.cancel();
    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();
      if (mounted) setState(() => _isRecording = false);
      widget.onRecordingStop?.call();

      if (path == null) {
        widget.onError?.call('Recording produced no audio.');
        return;
      }

      final bytes = await File(path).readAsBytes();
      if (bytes.isEmpty) {
        widget.onError?.call('Recording produced no audio.');
        return;
      }
      widget.onRecordingComplete(bytes);
    } catch (e) {
      if (mounted) setState(() => _isRecording = false);
      widget.onError?.call('Could not finish recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    _maxDurationTimer?.cancel();
    if (!_isRecording) return;
    if (mounted) setState(() => _isRecording = false);
    widget.onRecordingStop?.call();
    try {
      await _recorder.cancel();
    } catch (_) {
      // Best-effort cleanup on gesture cancel; nothing actionable for the
      // user here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      onLongPressCancel: _cancelRecording,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: _isRecording ? AppColors.danger : AppColors.primary,
        child: Icon(
          _isRecording ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: widget.radius,
        ),
      ),
    );
  }
}
