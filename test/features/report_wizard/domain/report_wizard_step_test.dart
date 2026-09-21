import 'package:farmer_herder_conflict_tracker/features/report_wizard/domain/report_wizard_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportWizardStep.surfaceId', () {
    test('is "wizard_<code>" for every step', () {
      expect(ReportWizardStep.where.surfaceId, 'wizard_where');
      expect(
        ReportWizardStep.whatsHappening.surfaceId,
        'wizard_whats_happening',
      );
      expect(ReportWizardStep.whoInvolved.surfaceId, 'wizard_who_involved');
      expect(ReportWizardStep.addDetail.surfaceId, 'wizard_add_detail');
    });

    test('every surfaceId is unique', () {
      final ids = ReportWizardStep.values.map((s) => s.surfaceId).toSet();
      expect(ids.length, ReportWizardStep.values.length);
    });
  });

  group('ReportWizardStep.next', () {
    test(
      'walks where -> whatsHappening -> whoInvolved -> addDetail -> null',
      () {
        expect(ReportWizardStep.where.next, ReportWizardStep.whatsHappening);
        expect(
          ReportWizardStep.whatsHappening.next,
          ReportWizardStep.whoInvolved,
        );
        expect(ReportWizardStep.whoInvolved.next, ReportWizardStep.addDetail);
        expect(ReportWizardStep.addDetail.next, isNull);
      },
    );
  });

  group('ReportWizardStep.previous', () {
    test(
      'walks addDetail -> whoInvolved -> whatsHappening -> where -> null',
      () {
        expect(
          ReportWizardStep.addDetail.previous,
          ReportWizardStep.whoInvolved,
        );
        expect(
          ReportWizardStep.whoInvolved.previous,
          ReportWizardStep.whatsHappening,
        );
        expect(
          ReportWizardStep.whatsHappening.previous,
          ReportWizardStep.where,
        );
        expect(ReportWizardStep.where.previous, isNull);
      },
    );

    test('next/previous are inverses of each other across the whole chain', () {
      for (final step in ReportWizardStep.values) {
        final next = step.next;
        if (next != null) {
          expect(next.previous, step);
        }
      }
    });
  });

  group('ReportWizardStep.bindings', () {
    test('every step has exactly one binding pointing at /report/*', () {
      for (final step in ReportWizardStep.values) {
        expect(step.bindings, hasLength(1));
        expect(step.bindings.single.path, startsWith('/report/'));
      }
    });
  });
}
