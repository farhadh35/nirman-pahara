import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;

  setUp(() => repo = ContentRepository(reader: _fromDisk));

  test('the published schedule loads with all its chapters', () async {
    final t = await repo.pwdRates();
    expect(t.items.length, greaterThan(1500));
    expect(t.chapters.length, greaterThan(25));
    expect(t.regions.length, 4);
    expect(t.effective, '2026-01-22');
    expect(t.sourceUrl, contains('pwd.gov.bd'));
  });

  test('a known item matches the published figures exactly', () async {
    // Chapter 07, floor/roof slab and beams up to ground floor. Checked by
    // hand against the printed schedule.
    final item = (await repo.pwdRates()).byCode('07.1.3')!;
    expect(item.unit.en, 'cum');
    expect(item.chapter, 7);
    expect(item.description, contains('Floor / roof slab'));
    expect(item.rates, [10725.0, 10692.0, 10456.0, 10450.0]);
  });

  test('rates differ by region, and the region is chosen not assumed',
      () async {
    final t = await repo.pwdRates();
    final item = t.byCode('07.1.3')!;
    // Dhaka is dearer than Rajshahi for this item; picking the wrong column
    // is a real way to reach a wrong answer.
    expect(item.rateFor(0), greaterThan(item.rateFor(3)));
    expect(t.regions.first.name.en, contains('Dhaka'));
    expect(t.regions.last.name.en, contains('Rangpur'));
  });

  test('every item carries a positive rate for every region', () async {
    for (final i in (await repo.pwdRates()).items) {
      expect(i.rates.length, 4, reason: i.code);
      for (final r in i.rates) {
        expect(r, greaterThan(0), reason: i.code);
      }
    }
  });

  test('search finds items by code and by words in the description',
      () async {
    final t = await repo.pwdRates();
    expect(t.search('07.1.3').first.code, '07.1.3');
    expect(t.search('roof slab'), isNotEmpty);
    expect(t.search('zzzznothing'), isEmpty);
  });

  test('the markups built into every rate are carried', () async {
    final t = await repo.pwdRates();
    expect(t.profitPercent, 10.0);
    expect(t.overheadPercent, 3.5);
  });

  test('units are labelled in both languages', () async {
    final t = await repo.pwdRates();
    final cum = t.byCode('07.1.3')!;
    expect(cum.unit.of(AppLocale.en), 'cum');
    expect(cum.unit.of(AppLocale.bn), 'ঘনমিটার');
  });
}
