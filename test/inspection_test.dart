import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_run.dart';
import 'package:nirman_pahara/features/inspection/logic/photo_ref.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;
  late ChecklistPack road;

  setUp(() async {
    repo = ContentRepository(reader: _fromDisk);
    road = (await repo.checklistById('road_rural'))!;
  });

  InspectionRun newRun() => InspectionRun(
        id: 'r1',
        pack: road,
        projectName: 'পালাশবাড়ি–গোবিন্দগঞ্জ সড়ক',
        location: 'পালাশবাড়ি ইউনিয়ন',
        tenderId: 'LGED-2026-0142',
        date: DateTime(2026, 7, 12),
      );

  test('a new run has one finding per checklist item, none answered', () {
    final run = newRun();
    expect(run.total, road.itemCount);
    expect(run.answered, isEmpty);
    expect(run.progress, 0);
  });

  test('progress tracks answered items', () {
    final run = newRun();
    run.findings.values.first.answer = ItemAnswer.ok;
    expect(run.progress, closeTo(1 / run.total, 0.0001));
  });

  test('the report carries the header a complaint needs', () {
    final run = newRun();
    run.findings.values.first.answer = ItemAnswer.ok;
    final r = run.report(AppLocale.bn);
    expect(r, contains('পালাশবাড়ি–গোবিন্দগঞ্জ সড়ক'));
    expect(r, contains('LGED-2026-0142'),
        reason: 'a tender ID is looked up, not read: it stays as it was given');
    expect(r, contains('২০২৬-০৭-১২'));
  });

  test('the report counts the photographs that will actually be sent', () {
    // The share path drops a photograph whose file has gone. The text kept
    // counting it, so a report could say three were attached while two went
    // out — the kind of number an office checks against the envelope.
    final run = newRun();
    final f = run.findings['r3']!
      ..answer = ItemAnswer.problem
      ..photos.add(PhotoRef(name: 'a.jpg', takenAt: DateTime(2026, 7, 12)))
      ..photos.add(PhotoRef(name: 'b.jpg', takenAt: DateTime(2026, 7, 12)));
    expect(f.photos.length, 2);

    final whole = run.report(AppLocale.bn);
    expect(whole, contains('২টি সংযুক্ত'));
    expect(whole, isNot(contains('পাওয়া যায়নি')));

    final partial = run.report(AppLocale.bn, missingPhotos: {'b.jpg'});
    expect(partial, contains('১টি সংযুক্ত'),
        reason: 'the report still counts a photograph that will not be sent');
    expect(partial, contains('১টির ফাইল পাওয়া যায়নি'));
    expect(partial, contains('ফাইল পাওয়া যায়নি]'),
        reason: 'the photograph list does not mark the one that is gone');
  });

  test('a problem is reported as rule versus observation, never as an accusation',
      () {
    final run = newRun();
    final layer = run.findings['r3']!;
    layer.answer = ItemAnswer.problem;
    layer.note = '১২ জুলাই সকাল ৯টা — সাব-বেজ মেপে ১০০ মিমি পাওয়া গেল।';

    final r = run.report(AppLocale.bn);
    expect(r, contains('নিয়মে যা থাকার কথা'));
    expect(r, contains('যা দেখা গেছে'));
    expect(r, contains('১২ জুলাই সকাল ৯টা'));
    for (final word in ['দুর্নীতি', 'চুরি', 'ঘুষ', 'অসৎ']) {
      expect(r, isNot(contains(word)), reason: 'report must not accuse: $word');
    }
  });

  test('the English report reads the same way', () {
    final run = newRun();
    run.findings['r3']!.answer = ItemAnswer.problem;
    final r = run.report(AppLocale.en);
    expect(r, contains('INSPECTION REPORT'));
    expect(r, contains('What the rule requires'));
    expect(r, contains('not an engineering test'));
    for (final word in ['corruption', 'theft', 'bribe', 'dishonest']) {
      expect(r.toLowerCase(), isNot(contains(word)),
          reason: 'report must not accuse: $word');
    }
  });

  test('items the user could not judge are listed separately', () {
    final run = newRun();
    run.findings['r4']!.answer = ItemAnswer.unsure;
    final r = run.report(AppLocale.bn);
    expect(r, contains('যা বোঝা যায়নি'));
    expect(run.problems, isEmpty);
    expect(run.unsure.length, 1);
  });

  test('a clean run produces a report with no problem section', () {
    final run = newRun();
    for (final f in run.findings.values) {
      f.answer = ItemAnswer.ok;
    }
    final r = run.report(AppLocale.bn);
    expect(r, isNot(contains('যেসব বিষয়ে সমস্যা দেখা গেছে')));
    expect(run.progress, 1.0);
  });
}
