import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_run.dart';
import 'package:nirman_pahara/features/inspection/logic/photo_ref.dart';

/// Bangla digits are right for a number a reader reads and wrong for one they
/// have to put back into a machine.
///
/// A tender ID goes into the e-GP portal's search box, or gets matched against
/// a file by the official receiving the complaint. A coordinate goes into a
/// map. Neither accepts "২০২৬" — and this app's own guide has a card telling
/// people to search by tender ID, so it was teaching a lookup it then made
/// impossible.
void main() {
  final bangla = RegExp(r'[০-৯]');
  late ChecklistPack pack;

  setUpAll(() async {
    pack = (await ContentRepository(reader: (p) => File(p).readAsString())
            .checklists())
        .first;
  });

  test('a tender ID survives the report in the form it was given', () {
    final run = InspectionRun(
      id: 'r1',
      pack: pack,
      projectName: 'ওয়ার্ড ৩ সড়ক',
      location: 'পালাশবাড়ি',
      tenderId: 'LGED-2026-0142',
      date: DateTime(2026, 7, 12),
    );
    final text = run.report(AppLocale.bn);
    expect(text, contains('LGED-2026-0142'),
        reason: 'the tender ID was rewritten and no longer matches the portal');
  });

  test('the date beside it is still Bangla, because it is only read', () {
    final run = InspectionRun(
      id: 'r1',
      pack: pack,
      projectName: 'ওয়ার্ড ৩ সড়ক',
      location: '',
      tenderId: '',
      date: DateTime(2026, 7, 12),
    );
    final text = run.report(AppLocale.bn);
    expect(bangla.hasMatch(text), isTrue,
        reason: 'the whole report went western; only identifiers should have');
  });

  test('a coordinate stays in the digits a map will accept', () {
    final photo = PhotoRef(
      name: 'a.jpg',
      takenAt: DateTime(2026, 7, 12, 9, 35),
      latitude: 24.89431,
      longitude: 89.37215,
      outcome: LocationOutcome.recorded,
    );
    final caption = photo.describe(AppLocale.bn);
    expect(caption, contains('24.89431'));
    expect(caption, contains('89.37215'));
    // The time in the same caption is read, not re-entered, so it stays Bangla.
    expect(bangla.hasMatch(caption.split('·').first), isTrue,
        reason: 'the timestamp should still be in the reader\'s digits');
  });

  test('a photo with no fix says why instead of showing a blank place', () {
    final photo = PhotoRef(
      name: 'b.jpg',
      takenAt: DateTime(2026, 7, 12, 9, 35),
      outcome: LocationOutcome.permissionDenied,
    );
    final caption = photo.describe(AppLocale.bn);
    expect(caption.trim(), isNot(endsWith('·')));
    expect(caption.length, greaterThan(10));
  });
}
