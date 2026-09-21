// Native (non-GenUI) chrome — a horizontal-wrapping row of chips mirroring
// the wizard's accumulated answers. Per docs/refactor.md §1: this is a
// DataModel subscription's output (ReportWizardController.state.answers),
// not manually-threaded state, and it stays visible across Back navigation
// since it reads controller state, not per-step UI state.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/report_wizard_controller.dart';

/// Chip display order + labels. Only the three structured steps get chips —
/// per the UX doc's wireframes (Steps 2-4 header rows only ever show
/// location/whatsHappening/whoInvolved accumulating), Step 4's free-text
/// detail is additive enrichment, not another chip.
const List<String> _chipOrder = ['location', 'whatsHappening', 'whoInvolved'];

class WizardChipTrail extends ConsumerWidget {
  const WizardChipTrail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(
      reportWizardControllerProvider.select((s) => s.answers),
    );
    final chips = _chipOrder
        .map((key) => answers[key])
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList();

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final label in chips)
            Chip(
              label: Text(label),
              backgroundColor: AppColors.background,
              side: const BorderSide(color: AppColors.primary),
              labelStyle: const TextStyle(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
