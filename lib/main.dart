import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Sentry wiring (lib/core/config/env.dart's Env.sentryDsn) lands here if
  // time allows — see task.md cut list.
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
