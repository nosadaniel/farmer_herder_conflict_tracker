import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Firebase.initializeApp() and Sentry wiring land here once Firebase
  // credentials are provided (see task.md "Your responsibilities").
  runApp(const ProviderScope(child: ConflictTrackerApp()));
}

class ConflictTrackerApp extends StatelessWidget {
  const ConflictTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer-Herders Conflict Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(
        dynamicCanvas: const _DynamicCanvasPlaceholder(),
        onMicPressStart: () {},
        onMicPressEnd: () {},
        onTextInputTap: () {},
      ),
    );
  }
}

/// Placeholder until Track C (A2UI/GenUI) wires the real dynamic canvas.
class _DynamicCanvasPlaceholder extends StatelessWidget {
  const _DynamicCanvasPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('A2UI dynamic canvas renders here'),
    );
  }
}
