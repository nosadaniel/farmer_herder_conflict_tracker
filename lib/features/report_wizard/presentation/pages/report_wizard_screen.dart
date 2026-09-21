// The Guided Report Wizard's screen: native chrome (AppBar, step dots, chip
// trail, Back/Next/Skip/Create buttons) wrapping the active step's GenUI
// `Surface`, per docs/report_wizard_ux_flow.md's wireframes. Switches to the
// existing, unmodified Result session's `A2uiSurfaceView` once
// `createReport()` has kicked off.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../conflict_reporting/presentation/a2ui/widgets/a2ui_surface_view.dart';
import '../../../conflict_reporting/presentation/widgets/microphone_button.dart';
import '../../domain/report_wizard_step.dart';
import '../providers/report_wizard_controller.dart';
import '../widgets/wizard_chip_trail.dart';

class ReportWizardScreen extends ConsumerStatefulWidget {
  const ReportWizardScreen({super.key});

  @override
  ConsumerState<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends ConsumerState<ReportWizardScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off Step 1's surface generation once, after the first frame —
    // not from build(), so a rebuild never re-triggers it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(reportWizardControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(reportWizardControllerProvider);

    // Step 1's "Choose my state" selection is an app-owned intent, not a
    // GenUI-rendered picker (docs/refactor.md §4) — the controller flips
    // this flag rather than opening UI itself.
    ref.listen(
      reportWizardControllerProvider.select((s) => s.showStatePicker),
      (previous, next) {
        if (next) _showStatePicker(context, ref);
      },
    );

    if (wizardState.showingResult) {
      return _ResultMode(
        onRestart: () =>
            ref.read(reportWizardControllerProvider.notifier).restart(),
      );
    }

    return _WizardStepMode(wizardState: wizardState);
  }

  void _showStatePicker(BuildContext context, WidgetRef ref) {
    final controller = ref.read(reportWizardControllerProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose your state',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final stateName in reportWizardStateCentroids.keys)
              ListTile(
                title: Text(stateName),
                onTap: () {
                  controller.resolveStateLocation(stateName);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    ).whenComplete(controller.dismissStatePicker);
  }
}

/// Wizard-step render mode: AppBar + 4-dot stepper + chip trail + the active
/// step's `Surface` (or a skeleton while it's generating) + Back/Next/Skip
/// (or, on Step 4, Skip-this-step/Create/Back).
class _WizardStepMode extends ConsumerWidget {
  const _WizardStepMode({required this.wizardState});

  final ReportWizardState wizardState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = wizardState.step;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: 'Exit',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(step.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final s in ReportWizardStep.values)
                    _WizardStepDot(
                      active: s == step,
                      done: s.index < step.index,
                    ),
                ],
              ),
            ),
            const WizardChipTrail(),
            if (wizardState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  wizardState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStepContent(context, ref, wizardState),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildButtonRow(context, ref, wizardState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    WidgetRef ref,
    ReportWizardState wizardState,
  ) {
    final controller = ref.read(reportWizardControllerProvider.notifier);
    final step = wizardState.step;
    final bool ready = wizardState.stepGenerated.contains(step);
    final SurfaceContext? surfaceContext = ready
        ? controller.surfaceContextFor(step)
        : null;

    if (surfaceContext == null) {
      return const _WizardStepSkeleton();
    }

    final Widget surfaceWidget = Surface(
      key: ValueKey(step.surfaceId),
      surfaceContext: surfaceContext,
    );

    if (step != ReportWizardStep.addDetail) {
      return surfaceWidget;
    }

    // Step 4's Speak button is native chrome, not part of the generated
    // surface (docs/refactor.md §4) — MicrophoneButton already handles
    // press-and-hold + mic-permission-on-first-use + recording errors.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: MicrophoneButton(
              radius: 28,
              onRecordingComplete: (bytes) =>
                  controller.submitSpokenDetail(bytes),
              onError: (message) =>
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message))),
            ),
          ),
        ),
        surfaceWidget,
      ],
    );
  }

  Widget _buildButtonRow(
    BuildContext context,
    WidgetRef ref,
    ReportWizardState wizardState,
  ) {
    final controller = ref.read(reportWizardControllerProvider.notifier);
    final step = wizardState.step;
    final bool busy = wizardState.isGeneratingStep;
    final bool canGoBack = step.previous != null;

    if (step == ReportWizardStep.addDetail) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy ? null : controller.skip,
              icon: const Icon(Icons.skip_next_outlined),
              label: const Text('Skip this step'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: busy ? null : controller.createReport,
              icon: const Text('✦'),
              label: const Text('Create'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: canGoBack ? controller.back : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (wizardState.validationMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              wizardState.validationMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: busy ? null : controller.next,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: busy ? null : controller.skip,
            icon: const Icon(Icons.skip_next_outlined),
            label: const Text('Skip'),
          ),
        ),
        if (canGoBack) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: controller.back,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ),
        ],
      ],
    );
  }
}

/// 4-dot step-progress indicator — same visual idiom as
/// `TutorialScreen._SwipeIndicatorDot`, but with a third ("done") state
/// since, unlike the tutorial carousel, wizard steps are visited in order
/// and stay "completed" once passed.
class _WizardStepDot extends StatelessWidget {
  const _WizardStepDot({required this.active, required this.done});

  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final Color color = active || done
        ? AppColors.secondary
        : AppColors.neutral;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Shimmered placeholder shown while a step's surface is being generated —
/// a fake layout shaped like a typical `ChoicePicker` step, composed with
/// the shared [AppSkeleton] wrapper for the same brand-consistent shimmer
/// every other loading state in the app uses (see `_A2uiSkeletonLoader` in
/// `a2ui_surface_view.dart` for the sibling pattern on the Result session).
class _WizardStepSkeleton extends StatelessWidget {
  const _WizardStepSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Loading options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < 4; i++)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Result render mode: the existing, unmodified `A2uiSurfaceView` (owned by
/// a different track's already-wired Result session) plus a close/restart
/// "X" — this wizard's only "start a new report" affordance.
class _ResultMode extends StatelessWidget {
  const _ResultMode({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close and start a new report',
          onPressed: onRestart,
        ),
      ),
      body: const A2uiSurfaceView(),
    );
  }
}
