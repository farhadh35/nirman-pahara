import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/prices/logic/country_benchmark_calculator.dart';
import 'package:nirman_pahara/features/prices/logic/market_price_calculator.dart';
import 'package:nirman_pahara/features/prices/logic/price_models.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;

  setUp(() => repo = ContentRepository(reader: _fromDisk));

  group('Price pack', () {
    test('parses with materials, benchmarks and a seed exchange rate',
        () async {
      final p = await repo.prices();
      expect(p.materials, isNotEmpty);
      expect(p.benchmarks, isNotEmpty);
      expect(p.seedUsdToBdt, greaterThan(0));
      expect(p.fxAsOf, isNotEmpty);
    });

    test('every band is the right way round and dated', () async {
      for (final m in (await repo.prices()).materials) {
        expect(m.lowBdt, lessThanOrEqualTo(m.highBdt), reason: m.id);
        expect(m.lowBdt, greaterThan(0), reason: m.id);
        expect(m.asOf, isNotEmpty, reason: m.id);
      }
    });

    test('every price and benchmark carries a source', () async {
      final p = await repo.prices();
      for (final m in p.materials) {
        expect(m.sources, isNotEmpty, reason: 'no source for ${m.id}');
      }
      for (final b in p.benchmarks) {
        expect(b.sources, isNotEmpty, reason: 'no source for ${b.id}');
        expect(b.comparability.bn.trim(), isNotEmpty, reason: b.id);
        expect(b.comparability.needsTranslation, isFalse, reason: b.id);
      }
    });

    test('everything is fully translated', () async {
      final p = await repo.prices();
      for (final m in p.materials) {
        expect(m.name.needsTranslation, isFalse, reason: m.id);
        expect(m.unit.needsTranslation, isFalse, reason: m.id);
        expect(m.note?.needsTranslation ?? false, isFalse, reason: m.id);
      }
      for (final b in p.benchmarks) {
        expect(b.country.needsTranslation, isFalse, reason: b.id);
        expect(b.unit.needsTranslation, isFalse, reason: b.id);
      }
    });

    test('benchmarks group into comparable items, cheapest first', () async {
      final items = (await repo.prices()).items;
      expect(items, isNotEmpty);
      final highway = (await repo.prices()).itemById('highway_4lane_per_km');
      expect(highway, isNotNull);
      expect(highway!.benchmarks.length, greaterThanOrEqualTo(3));
      for (var i = 1; i < highway.benchmarks.length; i++) {
        expect(highway.benchmarks[i].midUsd,
            greaterThanOrEqualTo(highway.benchmarks[i - 1].midUsd));
      }
    });

    test('undated figures are flagged rather than assumed contemporaneous',
        () async {
      final highway =
          (await repo.prices()).itemById('highway_4lane_per_km')!;
      expect(highway.hasUndatedFigures, isTrue);
    });

    test('unsourced material lookup returns null', () async {
      expect((await repo.prices()).materialById('nope'), isNull);
    });
  });

  group('MarketPriceCalculator', () {
    const c = MarketPriceCalculator();

    final cement = MaterialPrice(
      id: 'cement',
      name: const L10nText('সিমেন্ট', 'Cement'),
      unit: const L10nText('ব্যাগ', 'bag'),
      lowBdt: 480,
      highBdt: 530,
      asOf: '2026-09-02',
      status: ReviewStatus.review,
    );

    test('a quote inside the band reports as inside', () {
      final r = c.compare(market: cement, quotedBdt: 500);
      expect(r.valueOf('quoted'), 500);
      expect(r.valueOf('vs_mid_percent'), closeTo(-0.99, 0.05));
      expect(r.note!.bn, contains('ভেতরেই'));
    });

    test('a quote above the band reports the gap in taka', () {
      final r = c.compare(market: cement, quotedBdt: 600, quantity: 100);
      expect(r.valueOf('total_quoted'), 60000);
      expect(r.valueOf('total_at_high'), 53000);
      expect(r.valueOf('gap_vs_high'), 7000);
      expect(r.valueOf('vs_mid_percent'), closeTo(18.81, 0.05));
    });

    test('a quote below the band warns about grade, not about a bargain', () {
      final r = c.compare(market: cement, quotedBdt: 400);
      expect(r.note!.en, contains('Cheap is not the same'));
    });

    test('the band date is always in the assumptions', () {
      final r = c.compare(market: cement, quotedBdt: 500);
      expect(r.assumptions.any((a) => a.bn.contains('2026-09-02')), isTrue);
    });

    test('rejects nonsense input', () {
      expect(() => c.compare(market: cement, quotedBdt: 0),
          throwsA(isA<CalcException>()));
      expect(() => c.compare(market: cement, quotedBdt: 500, quantity: -1),
          throwsA(isA<CalcException>()));
    });
  });

  group('CountryBenchmarkCalculator', () {
    const c = CountryBenchmarkCalculator();

    test('converts to dollars and reports a multiple range', () async {
      final p = await repo.prices();
      final item = p.itemById('highway_4lane_per_km')!;
      // Tk 400 crore for 5 km = Tk 80 crore per km.
      final r = c.compare(
        item: item,
        projectCostBdt: 4000000000,
        quantity: 5,
        usdToBdt: 122.7,
        fxAsOf: p.fxAsOf,
      );
      expect(r.perUnitBdt, 800000000);
      expect(r.perUnitUsd, closeTo(6519967, 1000));
      expect(r.comparisons.length, item.benchmarks.length);
      expect(r.lowestMultiple, lessThan(r.highestMultiple));
    });

    test('a multiple against China is larger than against Bangladesh',
        () async {
      final p = await repo.prices();
      final item = p.itemById('highway_4lane_per_km')!;
      final r = c.compare(
        item: item,
        projectCostBdt: 4000000000,
        quantity: 5,
        usdToBdt: 122.7,
        fxAsOf: p.fxAsOf,
      );
      final china =
          r.comparisons.firstWhere((x) => x.benchmark.id == 'china_4lane');
      final mawa =
          r.comparisons.firstWhere((x) => x.benchmark.id == 'bd_dhaka_mawa');
      expect(china.multipleMid, greaterThan(mawa.multipleMid));
    });

    test('caveats are always returned and cover FX, scope and verdicts',
        () async {
      final p = await repo.prices();
      final r = c.compare(
        item: p.itemById('highway_4lane_per_km')!,
        projectCostBdt: 100000000,
        quantity: 1,
        usdToBdt: 122.7,
        fxAsOf: p.fxAsOf,
      );
      expect(r.caveats.length, greaterThanOrEqualTo(4));
      expect(r.caveats.any((c) => c.bn.contains('বিনিময় হার')), isTrue);
      expect(r.caveats.any((c) => c.bn.contains('জমি')), isTrue);
      expect(
          r.caveats.any((c) => c.bn.contains('দুর্নীতি নয়')), isTrue,
          reason: 'must state that a higher cost is not proof of corruption');
      for (final cav in r.caveats) {
        expect(cav.needsTranslation, isFalse, reason: cav.bn);
      }
    });

    test('rejects a missing or absurd exchange rate', () async {
      final item = (await repo.prices()).itemById('highway_4lane_per_km')!;
      expect(
        () => c.compare(
            item: item,
            projectCostBdt: 1000,
            quantity: 1,
            usdToBdt: 0,
            fxAsOf: 'x'),
        throwsA(isA<CalcException>()),
      );
      expect(
        () => c.compare(
            item: item,
            projectCostBdt: 1000,
            quantity: 0,
            usdToBdt: 122,
            fxAsOf: 'x'),
        throwsA(isA<CalcException>()),
      );
    });
  });
}
