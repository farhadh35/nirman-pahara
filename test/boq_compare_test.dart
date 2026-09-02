import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/prices/logic/boq_compare.dart';
import 'package:nirman_pahara/features/prices/logic/pwd_rate_table.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = ContentRepository(reader: _fromDisk);
  });

  group('BoqComparison against the published schedule', () {
    const c = BoqComparison();

    Future<PwdRateItem> slab() async =>
        (await repo.pwdRates()).byCode('07.1.3')!;

    Future<CalcResult> compare({
      required double boqRate,
      required double quantity,
      int region = 0,
    }) async {
      final item = await slab();
      final table = await repo.pwdRates();
      return c.compare(
        itemLabel: L10nText(item.code, item.code),
        scheduleLabel: table.schedule,
        unit: item.unit,
        scheduleRate: item.rateFor(region),
        boqRate: boqRate,
        quantity: quantity,
        locale: AppLocale.en,
      );
    }

    test('measures the gap against the real Dhaka rate', () async {
      // 07.1.3 in Dhaka/Mymensingh is Tk 10,725.00 per cum.
      final r = await compare(boqRate: 12000, quantity: 100);
      expect(r.valueOf('schedule_total'), closeTo(1072500, 1));
      expect(r.valueOf('boq_total'), 1200000);
      expect(r.valueOf('diff_percent'), closeTo(11.89, 0.01));
    });

    test('the region changes the answer', () async {
      final dhaka = await compare(boqRate: 12000, quantity: 100, region: 0);
      final rajshahi = await compare(boqRate: 12000, quantity: 100, region: 3);
      expect(rajshahi.valueOf('diff_percent'),
          greaterThan(dhaka.valueOf('diff_percent')!));
    });

    test('a large gap asks for the rate analysis rather than alleging', () async {
      final r = await compare(boqRate: 15000, quantity: 100);
      expect(r.note!.en, contains('not proof'));
      expect(r.note!.en, contains('rate analysis'));
      expect(r.note!.bn, isNot(contains('দুর্নীতি')));
    });

    test('a rate under the schedule warns about quality', () async {
      final r = await compare(boqRate: 7000, quantity: 100);
      expect(r.note!.en, contains('thinner materials'));
    });

    test('rejects missing figures', () async {
      final item = await slab();
      final table = await repo.pwdRates();
      expect(
        () => c.compare(
          itemLabel: L10nText(item.code, item.code),
          scheduleLabel: table.schedule,
          unit: item.unit,
          scheduleRate: item.rateFor(0),
          boqRate: 0,
          quantity: 1,
          locale: AppLocale.bn,
        ),
        throwsA(isA<CalcException>()),
      );
    });
  });

  group('SorRateStore', () {
    test('remembers a rate looked up elsewhere, and forgets on request',
        () async {
      final store = SorRateStore(await SharedPreferences.getInstance());
      expect(store.forItem('rhd_road'), isNull);
      await store.save('rhd_road',
          const SavedRate(rateBdt: 214.5, itemNo: '07-12', asOf: '2nd rev'));
      expect(store.forItem('rhd_road')!.rateBdt, 214.5);
      await store.clear('rhd_road');
      expect(store.forItem('rhd_road'), isNull);
    });

    test('survives a corrupt payload', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sor_rates', 'not json');
      expect(SorRateStore(prefs).all(), isEmpty);
    });
  });
}
