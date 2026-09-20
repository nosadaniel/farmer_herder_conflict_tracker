import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/conflict_reporting/application/usecases/report_submission_controller.dart';
import '../features/conflict_reporting/presentation/a2ui/widgets/a2ui_surface_view.dart';
import '../features/conflict_reporting/presentation/widgets/microphone_button.dart';
import '../features/conflict_reporting/presentation/widgets/text_input_modal.dart';
import '../features/map/presentation/widgets/conflict_map.dart';
import 'app_shell.dart';

/// The main app screen ([HomeRoute]): static frame ([AppShell]) + dynamic
/// canvas (map + A2UI surface) + the real mic/text-input triggers wired to
/// [ReportSubmissionController].
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(reportSubmissionControllerProvider, (previous, next) {
      if (next is ReportFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit report: ${next.message}')),
        );
      }
    });

    return AppShell(
      dynamicCanvas: const _DynamicCanvas(),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MicrophoneButton(
            onRecordingComplete: (bytes) => ref
                .read(reportSubmissionControllerProvider.notifier)
                .submitVoice(bytes),
            onError: (message) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message))),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () async {
              final text = await TextInputModal.show(context);
              if (text != null && context.mounted) {
                await ref
                    .read(reportSubmissionControllerProvider.notifier)
                    .submitText(text);
              }
            },
            icon: const Icon(Icons.keyboard),
            iconSize: 32,
            tooltip: 'Type your report',
          ),
        ],
      ),
    );
  }
}

/// Historical-hotspot map above the AI-generated risk-state surface — the
/// live map is deliberately NOT part of the AI-generated content itself
/// (docs/a2ui_gemini_contract.md §2: no custom map CatalogItem for MVP).
class _DynamicCanvas extends StatelessWidget {
  const _DynamicCanvas();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(flex: 3, child: ConflictMap()),
        Divider(height: 1),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(child: A2uiSurfaceView()),
        ),
      ],
    );
  }
}
