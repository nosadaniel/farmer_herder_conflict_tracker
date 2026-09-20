import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The Static Frame from phase_2_ux_design.md Screen 5 / frontend_architecture_idea.md:
/// a persistent header + footer wrapping a Dynamic Canvas that Track C
/// (A2UI/GenUI) owns the contents of. This widget only owns the shell —
/// it does not know about risk levels, blueprints, or voice/text state.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.dynamicCanvas,
    required this.onMicPressStart,
    required this.onMicPressEnd,
    required this.onTextInputTap,
    this.isOnline = true,
    super.key,
  });

  /// The A2UI-rendered content area (Track C fills this in).
  final Widget dynamicCanvas;

  final VoidCallback onMicPressStart;
  final VoidCallback onMicPressEnd;
  final VoidCallback onTextInputTap;
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPressStart: (_) => onMicPressStart(),
                onLongPressEnd: (_) => onMicPressEnd(),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.mic, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: onTextInputTap,
                icon: const Icon(Icons.keyboard),
                iconSize: 32,
                tooltip: 'Type your report',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
