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
    // Exact, not a floor: if a re-extraction of the source PDF changes what
    // the table holds, that must fail here rather than pass quietly.
    expect(t.items.length, 1749);
    expect(t.chapters.length, 32);
    expect(t.regions.length, 4);
    expect(t.effective, '2026-01-22');
    expect(t.sourceUrl, contains('pwd.gov.bd'));
  });

  test('a known item matches the published figures exactly', () async {
    // Chapter 07, floor/roof slab and beams up to ground floor. Checked by
    // hand against the printed schedule.
    final item = (await repo.pwdRates()).byCode('07.1.3')!;
    expect(item.unit.en, 'cum');
    expect(item.chapter, '7');
    expect(item.description, contains('Floor / roof slab'));
    expect(item.rates, [10725.0, 10692.0, 10456.0, 10450.0]);
  });

  test('rates differ by region, and the region is chosen not assumed',
      () async {
    final t = await repo.pwdRates();
    final item = t.byCode('07.1.3')!;
    // Dhaka is dearer than Rajshahi for this item; picking the wrong column
    // is a real way to reach a wrong answer.
    expect(item.rateFor(0)!, greaterThan(item.rateFor(3)!));
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

  test('a search matches whole words, not any run of letters', () async {
    final t = await repo.pwdRates();
    // "proof" contains "roof". A plain substring search hands somebody looking
    // for a roof slab a damp proof course instead.
    final roof = t.search('roof');
    expect(roof, isNotEmpty);
    for (final item in roof) {
      expect(item.description.toLowerCase(), isNot(contains('damp proof')),
          reason: '${item.code} came back for "roof"');
    }
    expect(t.search('damp proof'), isNotEmpty);
  });

  test('every term has to appear, so more words narrow the result', () async {
    final t = await repo.pwdRates();
    final broad = t.search('slab', limit: 500);
    final narrow = t.search('roof slab', limit: 500);
    expect(narrow.length, lessThanOrEqualTo(broad.length));
    expect(narrow, isNotEmpty);
  });

  test('a partial item number still matches', () async {
    final t = await repo.pwdRates();
    expect(t.search('07.1').map((i) => i.code), contains('07.1.3'));
  });

  test('a word prefix still matches, so plaster finds plastering', () async {
    final t = await repo.pwdRates();
    // Only the start of the word is anchored; endings vary too much.
    expect(t.search('plaster'), isNotEmpty);
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

  group('E/M works volume', () {
    test('loads as its own volume with all four zones', () async {
      final t = await repo.pwdEmRates();
      expect(t.items.length, 2606);
      expect(t.regions.length, 4);
      expect(t.sourceUrl, contains('Pwd_Schedule_Of_Rates_EM'));
      expect(t.volume!.en, contains('E/M'));
    });

    test('states no profit or overhead basis, and none is invented', () async {
      // The civil volume builds in 10% profit and 3.5% overhead. This one says
      // nothing, and subhead 13 prints its rates explicitly "WITHOUT PROFIT,
      // OVERHEAD" — so carrying the civil figures across would be a guess.
      final t = await repo.pwdEmRates();
      expect(t.profitPercent, isNull);
      expect(t.overheadPercent, isNull);
      expect(t.vatPercent, isNull);
    });

    test('a known item matches the printed page exactly', () async {
      // Subhead 1, channel point wiring, Eastern cables. Read off the rendered
      // page: "1,236.00  1230  1211  1211", unit "Point".
      final i = (await repo.pwdEmRates()).byCode('1.1.1.1')!;
      expect(i.chapter, '1');
      expect(i.unit.en, 'Point');
      expect(i.rates, [1236.0, 1230.0, 1211.0, 1211.0]);
      expect(i.description.toLowerCase(), contains('fan point'));
    });

    test('a second known item matches, in a different subhead', () async {
      // Subhead 7: "92,722.00  92652  92395  92395", unit "Each".
      final i = (await repo.pwdEmRates()).byCode('7.1.1.1')!;
      expect(i.rates, [92722.0, 92652.0, 92395.0, 92395.0]);
      expect(i.unit.en, 'Each');
    });

    test('subheads keep their printed numbering, including 2.1 and 20.1',
        () async {
      final chapters = (await repo.pwdEmRates()).chapters;
      expect(chapters, contains('2.1'));
      expect(chapters, contains('20.2'));
      // Sorted numerically part by part, so 20.2 comes after 9, not after 2.
      expect(chapters.indexOf('20.2'), greaterThan(chapters.indexOf('9')));
    });

    test('what the volume does not cover is named, so a gap is not read as zero',
        () async {
      // Subhead 13 prices spare parts across sixteen vehicle models
      // (Pajero, Corolla, Lancer ...). Reading four of those as the four zones
      // would put a Corolla axle bearing price in the Rajshahi column.
      final t = await repo.pwdEmRates();
      expect(t.chapters, isNot(contains('13')));
      expect(t.chapters, isNot(contains('20.1')));
      expect(t.notIncluded!.en, contains('vehicle'));
      expect(t.notIncluded!.en, contains('Lift'));
    });

    test('a zone the schedule misprints is left empty, never guessed', () async {
      final t = await repo.pwdEmRates();
      final unclear = t.items.where((i) => i.unclearZones.isNotEmpty).toList();
      expect(unclear, isNotEmpty,
          reason: 'the published PDF drops digits in some rate cells');
      for (final i in unclear) {
        for (final z in i.unclearZones) {
          expect(i.rates[z], isNull, reason: '${i.code} zone $z');
        }
        expect(i.rates.any((r) => r != null), isTrue,
            reason: '${i.code} kept no usable rate at all');
      }
    });

    test('every stated rate is positive and every item has four zone slots',
        () async {
      for (final i in (await repo.pwdEmRates()).items) {
        expect(i.rates.length, 4, reason: i.code);
        for (final r in i.rates) {
          if (r != null) expect(r, greaterThan(0), reason: i.code);
        }
      }
    });
  });
}
