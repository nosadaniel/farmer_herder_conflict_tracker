import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/conflict_reporting/application/usecases/report_submission_controller.dart';
import '../features/conflict_reporting/presentation/a2ui/widgets/a2ui_surface_view.dart';
import 'app_shell.dart';
import 'routing/app_routes.dart';

/// The main app screen ([HomeRoute]): static frame ([AppShell]) + dynamic
/// canvas (the last-generated A2UI result, which per task.md Phase 5 now
/// embeds its own `MapView` when Gemini judges the report spatially
/// relevant — see `lib/core/genui/map_view_catalog_item.dart`) + a single
/// "Report" CTA that launches the Guided Report Wizard
/// ([ReportWizardRoute]), replacing the old persistent mic/keyboard footer.
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
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => ReportWizardRoute.go(context),
          icon: const Icon(Icons.campaign_outlined),
          label: const Text('Report'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ),
    );
  }
}

class _DynamicCanvas extends StatelessWidget {
  const _DynamicCanvas();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(child: A2uiSurfaceView());
  }
}
