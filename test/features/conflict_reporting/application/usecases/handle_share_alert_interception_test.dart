import 'package:farmer_herder_conflict_tracker/features/conflict_reporting/application/usecases/handle_share_alert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late SurfaceController controller;

  setUp(() {
    controller = SurfaceController(catalogs: const <Catalog>[]);
  });

  tearDown(() {
    controller.dispose();
  });

  test('share_alert action calls the injected share function and does not '
      'forward to the controller', () async {
    ShareParams? captured;
    final event = UserActionEvent(
      surfaceId: 'report_1',
      name: shareAlertActionName,
      sourceComponentId: 'shareBtn',
      context: const {
        'summary': 'Herd crossing toward farms near Kaduna.',
        'riskLevel': 'high',
      },
    );

    final handled = await handleShareAlertInterception(
      event,
      controller,
      share: (params) async {
        captured = params;
        return ShareResult('', ShareResultStatus.success);
      },
    );

    expect(handled, isTrue);
    expect(captured, isNotNull);
    expect(
      captured!.text,
      'Conflict Alert: Herd crossing toward farms near Kaduna. Risk: '
      'High. Stay safe. -Shared via Conflict Tracker',
    );
  });

  test('non-share actions are forwarded, not intercepted', () async {
    var shareCalled = false;
    final event = UserActionEvent(
      surfaceId: 'report_1',
      name: 'call_mediation',
      sourceComponentId: 'callBtn',
      context: const {'riskLevel': 'high'},
    );

    final handled = await handleShareAlertInterception(
      event,
      controller,
      share: (params) async {
        shareCalled = true;
        return ShareResult('', ShareResultStatus.success);
      },
    );

    expect(handled, isFalse);
    expect(shareCalled, isFalse);
  });
}
