// Domain/state layer for the Guided Report Wizard (docs/report_wizard_ux_flow.md,
// docs/refactor.md §6). Owns the wizard's bounded GenUI session, mirrors its
// DataModel writes into a chip-trail-friendly `answers` map, and drives the
// 4-step FSM (`ReportWizardStep`).
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/permissions/permission_requesters.dart';
import '../../../conflict_reporting/application/usecases/report_submission_controller.dart';
import '../../../conflict_reporting/data/datasources/remote/gemini_remote_datasource.dart';
import '../../application/report_wizard_catalog.dart';
import '../../application/report_wizard_session.dart';
import '../../data/datasources/remote/report_wizard_prompt.dart';
import '../../domain/report_wizard_step.dart';
import '../../domain/wizard_binding.dart';

part 'report_wizard_controller.g.dart';

/// Approximate centroids for the six Middle Belt states offered by Step 1's
/// "Choose my state" picker. Exact values as specified by the UX/implementation
/// brief — do not adjust without updating that brief.
const Map<String, (double, double)> reportWizardStateCentroids = {
  'Kaduna': (10.5222, 7.4383),
  'Kano': (12.0022, 8.5920),
  'Plateau': (9.2182, 9.5179),
  'Benue': (7.3369, 8.7404),
  'Nasarawa': (8.5378, 8.3206),
  'Taraba': (7.9994, 10.7740),
};

/// Middle Belt centroid used when location can't be resolved any other way
/// — mirrors `ReportSubmissionController._run`'s existing fallback.
const (double, double) _middleBeltFallback = (9.0, 8.5);

/// Mirrors `report_submission_controller.dart`'s `_log` convention (a
/// module-level `Logger()`, not a field) — this is the newest, least
/// on-device-tested part of the app (a second GenUI session, its own
/// Gemini calls per step, permission flows), so logging here matters for
/// diagnosing exactly where a live run goes wrong.
final _log = Logger();

/// Exact option strings `ReportWizardStep.where.rules` asks Gemini to offer.
/// A selection matching either of these is an app-owned intent, not a
/// human-readable answer — the DataModel write it triggers is immediately
/// superseded by a human-readable place name (see [_onBindingValueChanged]).
const String _useCurrentLocationOption = 'Use my current location';
const String _chooseStateOption = 'Choose my state';

/// Builds the wizard's [WizardSession]. Kept as an overridable provider
/// (rather than a plain field the controller `new`s up itself) so tests can
/// substitute a fake session built from real, Firebase-free `genui`
/// primitives — see [WizardSession]'s doc comment for why that matters.
final Provider<WizardSession Function()> reportWizardSessionFactoryProvider =
    Provider<WizardSession Function()>((ref) {
      return () => ReportWizardSession(
        catalog: reportWizardCatalog,
        systemInstruction: reportWizardPromptFragment,
      );
    });

/// UI-facing state for the wizard flow.
///
/// A plain data class with `copyWith`, not a sealed hierarchy like
/// `ReportSubmissionState` — unlike that controller's mutually-exclusive
/// Idle/Processing/Failed phases, these fields (current step, accumulated
/// answers, per-step generation cache, result-mode flag, transient
/// error/validation text) all co-exist at once, so a sealed variant type
/// would just mean unpacking every field from every variant anyway.
class ReportWizardState {
  const ReportWizardState({
    this.step = ReportWizardStep.where,
    this.answers = const {},
    this.stepGenerated = const {},
    this.showingResult = false,
    this.isGeneratingStep = false,
    this.showStatePicker = false,
    this.validationMessage,
    this.error,
  });

  /// The step currently on screen.
  final ReportWizardStep step;

  /// Mirrors every DataModel write across all steps, keyed by
  /// `WizardBinding.key` — the chip trail's data source and the payload
  /// (minus `location`) handed to `submitStructured`.
  final Map<String, String> answers;

  /// Which steps' surfaces have already been generated at least once, so
  /// `next()`/`skip()` only calls Gemini the first time a step is visited —
  /// revisiting via Back is always free.
  final Set<ReportWizardStep> stepGenerated;

  /// True once `createReport()` has kicked off — the screen switches to
  /// rendering the (separate, frozen) Result session instead of a wizard
  /// step.
  final bool showingResult;

  /// True while a step's surface is being generated (the only time this
  /// wizard makes a Gemini call).
  final bool isGeneratingStep;

  /// True when Step 1's "Choose my state" was just selected — the screen
  /// reacts to this by opening a native state picker (a listener shouldn't
  /// open UI itself, so this is a flag the screen watches instead).
  final bool showStatePicker;

  /// Client-side "please choose an option" message from `next()`; cleared on
  /// any successful navigation.
  final String? validationMessage;

  /// Surfaced when step generation (a Gemini call) itself fails.
  final String? error;

  ReportWizardState copyWith({
    ReportWizardStep? step,
    Map<String, String>? answers,
    Set<ReportWizardStep>? stepGenerated,
    bool? showingResult,
    bool? isGeneratingStep,
    bool? showStatePicker,
    String? validationMessage,
    bool clearValidationMessage = false,
    String? error,
    bool clearError = false,
  }) {
    return ReportWizardState(
      step: step ?? this.step,
      answers: answers ?? this.answers,
      stepGenerated: stepGenerated ?? this.stepGenerated,
      showingResult: showingResult ?? this.showingResult,
      isGeneratingStep: isGeneratingStep ?? this.isGeneratingStep,
      showStatePicker: showStatePicker ?? this.showStatePicker,
      validationMessage: clearValidationMessage
          ? null
          : (validationMessage ?? this.validationMessage),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class ReportWizardController extends _$ReportWizardController {
  WizardSession? _session;

  /// `(lat, lng)` resolved by Step 1 — kept out of the DataModel/chip trail
  /// (which only ever shows human-readable strings) and out of `answers`,
  /// since `createReport()` needs it as numbers, not a chip label.
  (double, double)? _coords;
  String? _placeName;

  /// Per-step DataModel-subscription teardown callbacks, so `restart()` can
  /// detach cleanly before building a fresh session.
  final Map<ReportWizardStep, List<void Function()>> _unsubscribeByStep = {};

  @override
  ReportWizardState build() {
    ref.onDispose(() {
      _session?.dispose();
      _session = null;
    });
    return const ReportWizardState();
  }

  WizardSession get _wizardSession =>
      _session ??= ref.read(reportWizardSessionFactoryProvider)();

  /// The `SurfaceContext` the screen binds a `Surface` widget to for [step].
  ///
  /// Only meaningful once `state.stepGenerated` contains [step] (i.e. after
  /// `_generateStep` has succeeded for it at least once) — the screen checks
  /// that before rendering a `Surface`, showing a skeleton loader instead.
  SurfaceContext? surfaceContextFor(ReportWizardStep step) =>
      _session?.host.contextFor(step.surfaceId);

  /// Generates Step 1's surface if this is a fresh wizard run. Idempotent —
  /// safe to call from the screen's `build()`.
  Future<void> initialize() async {
    if (state.stepGenerated.contains(ReportWizardStep.where) ||
        state.isGeneratingStep) {
      return;
    }
    await _generateStep(ReportWizardStep.where);
  }

  /// Advances to the next step, requiring the current step's binding to
  /// have an answer first (skip via [skip] instead to bypass that check).
  Future<void> next() async {
    if (!_hasAnswer(state.step)) {
      state = state.copyWith(
        validationMessage: 'Please choose an option to continue.',
      );
      return;
    }
    await _advance();
  }

  /// Advances without requiring an answer for the current step.
  Future<void> skip() => _advance();

  Future<void> _advance() async {
    final ReportWizardStep? nextStep = state.step.next;
    if (nextStep == null) return; // addDetail: Create, not another step.
    _log.i('Wizard advancing ${state.step.code} -> ${nextStep.code}');
    if (!state.stepGenerated.contains(nextStep)) {
      await _generateStep(nextStep);
    }
    state = state.copyWith(step: nextStep, clearValidationMessage: true);
  }

  /// Pure local state change — no Gemini call, since every step keeps its
  /// own fixed `surfaceId` and `SurfaceController` already has it cached.
  void back() {
    final ReportWizardStep? previous = state.step.previous;
    if (previous == null) return;
    _log.i('Wizard back ${state.step.code} -> ${previous.code} (no Gemini call)');
    state = state.copyWith(step: previous, clearValidationMessage: true);
  }

  /// Disposes the current session and starts a brand-new wizard run —
  /// triggered by the Result screen's "X" (close/restart) button.
  Future<void> restart() async {
    _log.i('Wizard restart: disposing session, resetting to ${ReportWizardStep.where.code}');
    _session?.dispose();
    _session = null;
    for (final unsubscribers in _unsubscribeByStep.values) {
      for (final unsubscribe in unsubscribers) {
        unsubscribe();
      }
    }
    _unsubscribeByStep.clear();
    _coords = null;
    _placeName = null;
    state = const ReportWizardState();
    await initialize();
  }

  /// User tapped "Choose my state" and then picked [stateName] from the
  /// native bottom sheet the screen opened in reaction to
  /// `state.showStatePicker`.
  void resolveStateLocation(String stateName) {
    final coords = reportWizardStateCentroids[stateName];
    if (coords == null) {
      _log.w('resolveStateLocation called with unknown state "$stateName"');
      return;
    }
    _log.i(
      'Step 1: state picker resolved to $stateName '
      '(${coords.$1}, ${coords.$2})',
    );
    _applyLocation(
      lat: coords.$1,
      lng: coords.$2,
      placeName: '$stateName State',
    );
    state = state.copyWith(showStatePicker: false);
  }

  /// The screen's state-picker sheet was dismissed without a selection.
  void dismissStatePicker() {
    state = state.copyWith(showStatePicker: false);
  }

  /// Step 4's native "Speak" flow (via `MicrophoneButton`) hands raw audio
  /// bytes here once recording completes; transcribes it and writes the
  /// transcript into `/report/detailText`, same local-write path a catalog
  /// widget would use.
  Future<void> submitSpokenDetail(Uint8List audioBytes) async {
    _log.i('Transcribing Step 4 voice detail (${audioBytes.length} bytes)');
    try {
      final transcript = await GeminiRemoteDataSource.production()
          .transcribeAudio(audioBytes);
      _log.i('Transcription succeeded (${transcript.length} chars)');
      _wizardSession.host
          .contextFor(ReportWizardStep.addDetail.surfaceId)
          .dataModel
          .update(
            DataPath(ReportWizardStep.addDetail.bindings.single.path),
            transcript,
          );
    } catch (e, st) {
      _log.e('Voice detail transcription failed', error: e, stackTrace: st);
      state = state.copyWith(error: 'Could not transcribe audio: $e');
    }
  }

  /// Reads the accumulated structured answers back out and hands off to the
  /// existing (frozen, unmodified) report-generation flow. Does NOT dispose
  /// the wizard session — `restart()` (the Result screen's "X") does that,
  /// so a user could in principle navigate back into wizard-step state
  /// without losing data, though the primary path is X -> restart.
  Future<void> createReport() async {
    final wizardAnswers = <String, String>{};
    for (final key in const ['whatsHappening', 'whoInvolved', 'detailText']) {
      final value = state.answers[key];
      if (value != null && value.isNotEmpty) {
        wizardAnswers[key] = value;
      }
    }
    final coords = _coords;
    _log.i(
      'Wizard createReport: answers=$wizardAnswers '
      'location=$_placeName (${coords?.$1}, ${coords?.$2})',
    );
    await ref
        .read(reportSubmissionControllerProvider.notifier)
        .submitStructured(
          wizardAnswers: wizardAnswers,
          lat: coords?.$1,
          lng: coords?.$2,
          placeName: _placeName,
        );
    _log.i('Wizard createReport: handed off to ReportSubmissionController');
    state = state.copyWith(showingResult: true);
  }

  bool _hasAnswer(ReportWizardStep step) {
    final value = state.answers[step.bindings.first.key];
    return value != null && value.isNotEmpty;
  }

  Future<void> _generateStep(ReportWizardStep step) async {
    if (state.stepGenerated.contains(step)) return;
    _log.i('Generating wizard step "${step.surfaceId}"');
    state = state.copyWith(
      isGeneratingStep: true,
      clearValidationMessage: true,
      clearError: true,
    );
    try {
      final session = _wizardSession;
      final Future<void> surfaceReady = _waitForSurface(
        session,
        step.surfaceId,
      );
      await session.sendText(_promptFor(step));
      await surfaceReady;
      _attachSubscriptions(step, session);
      _log.i('Wizard step "${step.surfaceId}" ready');
      state = state.copyWith(
        stepGenerated: {...state.stepGenerated, step},
        isGeneratingStep: false,
      );
    } catch (e, st) {
      _log.e('Wizard step "${step.surfaceId}" failed to generate', error: e, stackTrace: st);
      state = state.copyWith(
        isGeneratingStep: false,
        error: 'Could not load this step: $e',
      );
    }
  }

  /// Waits for [targetSurfaceId]'s first `createSurface`/`updateComponents`
  /// event, rather than trusting `sendText`'s returned future alone to mean
  /// "the controller/DataModel is ready" (see `A2uiSurfaceView`'s
  /// `ValueListenableBuilder<ConversationState>` for the equivalent pattern
  /// the Result session relies on). Times out rather than hanging forever if
  /// something goes wrong upstream.
  Future<void> _waitForSurface(WizardSession session, String targetSurfaceId) {
    final completer = Completer<void>();
    late final StreamSubscription<ConversationEvent> subscription;
    subscription = session.events.listen((event) {
      final String? eventSurfaceId = switch (event) {
        ConversationSurfaceAdded(:final surfaceId) => surfaceId,
        ConversationComponentsUpdated(:final surfaceId) => surfaceId,
        _ => null,
      };
      if (eventSurfaceId == targetSurfaceId && !completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future
        .timeout(
          const Duration(seconds: 25),
          onTimeout: () => _log.w(
            'Timed out waiting for surface "$targetSurfaceId" '
            '(25s) — Gemini may not have followed the wizard contract',
          ),
        )
        .whenComplete(subscription.cancel);
  }

  /// One `DataModel` subscription per binding path for [step], mirroring
  /// every value change into `state.answers` — this *is* the chip trail's
  /// data source. Idempotent per step.
  void _attachSubscriptions(ReportWizardStep step, WizardSession session) {
    if (_unsubscribeByStep.containsKey(step)) return;
    final dataModel = session.host.contextFor(step.surfaceId).dataModel;
    final unsubscribers = <void Function()>[];
    for (final WizardBinding binding in step.bindings) {
      final notifier = dataModel.subscribe<Object?>(DataPath(binding.path));
      void listener() => _onBindingValueChanged(binding, notifier.value);
      notifier.addListener(listener);
      _onBindingValueChanged(binding, notifier.value);
      unsubscribers.add(() => notifier.removeListener(listener));
    }
    _unsubscribeByStep[step] = unsubscribers;
  }

  /// `ChoicePicker` always writes selections as a one-element list (verified
  /// against the real `genui-0.10.3` catalog widget source — both its
  /// `mutuallyExclusive` and default/checkbox branches write
  /// `List<String>`), so every raw DataModel value here is unwrapped before
  /// use, not compared as a bare string.
  void _onBindingValueChanged(WizardBinding binding, Object? rawValue) {
    final String? value = _extractSingleString(rawValue);
    if (value == null || value.isEmpty) return;
    _log.d('DataModel write at ${binding.path}: $rawValue -> "$value"');

    if (binding.path == ReportWizardStep.where.bindings.single.path) {
      if (value == _useCurrentLocationOption) {
        unawaited(_resolveCurrentLocation());
        return;
      }
      if (value == _chooseStateOption) {
        state = state.copyWith(showStatePicker: true);
        return;
      }
      // Gemini's `where.rules` only offers those two exact ChoicePicker
      // options — landing here means it emitted something else, which is
      // worth knowing about even though we still record it as an answer.
      _log.w('Unexpected /report/location value from Gemini: "$value"');
    }

    if (state.answers[binding.key] == value) return;
    state = state.copyWith(answers: {...state.answers, binding.key: value});
  }

  String? _extractSingleString(Object? raw) {
    if (raw == null) return null;
    if (raw is List) {
      if (raw.isEmpty) return null;
      return raw.first?.toString();
    }
    return raw.toString();
  }

  Future<void> _resolveCurrentLocation() async {
    _log.i('Step 1: "Use my current location" selected, requesting permission');
    final granted = await requestLocationPermission();
    if (!granted) {
      _log.w('Location permission denied — falling back to Middle Belt centroid');
      _applyLocation(
        lat: _middleBeltFallback.$1,
        lng: _middleBeltFallback.$2,
        placeName: 'Location unavailable',
      );
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _log.i('Resolved GPS: (${position.latitude}, ${position.longitude})');
      _applyLocation(
        lat: position.latitude,
        lng: position.longitude,
        placeName: 'My current location',
      );
    } catch (e, st) {
      _log.e('Geolocator.getCurrentPosition failed — falling back to Middle Belt centroid', error: e, stackTrace: st);
      _applyLocation(
        lat: _middleBeltFallback.$1,
        lng: _middleBeltFallback.$2,
        placeName: 'Location unavailable',
      );
    }
  }

  void _applyLocation({
    required double lat,
    required double lng,
    required String placeName,
  }) {
    _coords = (lat, lng);
    _placeName = placeName;
    _wizardSession.host
        .contextFor(ReportWizardStep.where.surfaceId)
        .dataModel
        .update(
          DataPath(ReportWizardStep.where.bindings.single.path),
          placeName,
        );
  }

  /// Combines the step's fixed rules with an explicit "use this surfaceId"
  /// instruction (mirrors `ConflictContextBuilder.build`'s
  /// `'Use this surfaceId: $surfaceId'` line) and a one-line recap of
  /// answers so far, so Gemini doesn't need conversational memory it
  /// doesn't have (each `firebase_ai` call is stateless).
  String _promptFor(ReportWizardStep step) {
    final buffer = StringBuffer()
      ..writeln(step.rules)
      ..writeln()
      ..writeln('Use this surfaceId: ${step.surfaceId}');
    if (state.answers.isNotEmpty) {
      final summary = state.answers.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      buffer.writeln(
        'Answers so far (for context only, do not re-ask): $summary',
      );
    }
    return buffer.toString();
  }
}
