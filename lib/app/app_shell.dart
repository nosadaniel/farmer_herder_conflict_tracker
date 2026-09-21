import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The Static Frame from phase_2_ux_design.md Screen 5 / frontend_architecture_idea.md:
/// a persistent header + footer wrapping a Dynamic Canvas that Track C
/// (A2UI/GenUI) owns the contents of. This widget only owns the shell —
/// it does not know about risk levels, blueprints, or voice/text state.
///
/// [footer] is composed by the caller. Originally this held the real
/// `MicrophoneButton` + text-input trigger directly; as of task.md Phase 5
/// that persistent mic/keyboard footer was replaced by a single "Report" CTA
/// that launches the Guided Report Wizard (`lib/features/report_wizard/`) —
/// this widget still only owns the shell, not what's in the footer slot.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.dynamicCanvas,
    required this.footer,
    this.isOnline = true,
    super.key,
  });

  /// The A2UI-rendered content area (Track C fills this in).
  final Widget dynamicCanvas;

  /// The persistent footer — mic button + text-input trigger, composed by
  /// the caller.
  final Widget footer;

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflict Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Icon(
                isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: isOnline ? AppColors.success : AppColors.offline,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: dynamicCanvas),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: footer,
        ),
      ),
    );
  }
}
