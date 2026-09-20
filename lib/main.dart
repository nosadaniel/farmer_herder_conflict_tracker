import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'app/wiring/gemini_send_handler.dart';
import 'core/theme/app_theme.dart';
import 'features/conflict_reporting/application/usecases/report_submission_controller.dart';
import 'features/conflict_reporting/presentation/a2ui/widgets/a2ui_surface_view.dart';
import 'features/conflict_reporting/presentation/widgets/microphone_button.dart';
import 'features/conflict_reporting/presentation/widgets/text_input_modal.dart';
import 'features/map/presentation/widgets/conflict_map.dart';
import 'features/onboarding/application/usecases/onboarding_controller.dart';
import 'features/onboarding/presentation/onboarding_flow.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Sentry wiring (lib/core/config/env.dart's Env.sentryDsn) lands here if
  // time allows — see task.md cut list.
  runApp(
    ProviderScope(
      // Wires the real Gemini call into Track C's a2uiSendHandlerProvider
      // seam — see lib/app/wiring/gemini_send_handler.dart for why this is
      // an override here rather than edited directly into a2ui_providers.dart.
      overrides: [geminiSendHandlerOverride],
      child: const ConflictTrackerApp(),
    ),
  );
}

class ConflictTrackerApp extends StatelessWidget {
  const ConflictTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer-Herders Conflict Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _RootRouter(),
    );
  }
}

/// Decides onboarding vs. the main app shell, driven entirely by watching
/// [onboardingControllerProvider] — no local state needed. [OnboardingFlow]
/// calls the controller's `complete()` internally, which flips this
/// provider's value and rebuilds this router to show [_MainScreen].
class _RootRouter extends ConsumerWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardedAsync = ref.watch(onboardingControllerProvider);
    return onboardedAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // Fail open to onboarding rather than getting stuck on an error
      // screen — matches OnboardingController's own fail-open behavior.
      error: (_, _) => OnboardingFlow(onComplete: () {}),
      data: (onboarded) => onboarded
          ? const _MainScreen()
          : OnboardingFlow(onComplete: () {
              // No-op: watching onboardingControllerProvider above already
              // rebuilds this router once OnboardingFlow's internal
              // complete() call updates it.
            }),
    );
  }
}

/// The main app screen: static frame (AppShell) + dynamic canvas (map +
/// A2UI surface) + the real mic/text-input triggers wired to
/// [ReportSubmissionController].
class _MainScreen extends ConsumerWidget {
  const _MainScreen();

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
