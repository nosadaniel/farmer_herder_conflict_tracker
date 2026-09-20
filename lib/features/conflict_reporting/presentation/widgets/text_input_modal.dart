import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Text-input fallback to voice reporting (PRD Flow 3 / contract doc §4:
/// "text input skips transcription and goes straight to building the
/// context block from the typed text" — same downstream pipeline as voice).
///
/// Presented as a modal bottom sheet; returns the submitted, trimmed report
/// text (validated non-empty, capped at [AppConstants.maxReportTextLength])
/// or `null` if the user dismisses without submitting.
class TextInputModal extends StatefulWidget {
  const TextInputModal({super.key});

  /// Shows the modal and returns the submitted report text, or `null` if
  /// dismissed without submitting. The caller feeds a non-null result into
  /// `SubmitReport` via `SubmitReportParams.reportText`.
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TextInputModal(),
    );
  }

  @override
  State<TextInputModal> createState() => _TextInputModalState();
}

class _TextInputModalState extends State<TextInputModal> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Please enter a report');
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Describe what you saw',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLength: AppConstants.maxReportTextLength,
            maxLines: 5,
            minLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. A herd is crossing toward the farms...',
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
