import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/calculators/logic/hook_lap.dart';
import 'package:nirman_pahara/features/calculators/logic/soling.dart';
import 'package:nirman_pahara/features/calculators/logic/stair.dart';
import 'package:nirman_pahara/features/calculators/logic/water_store.dart';

void main() {
  group('Hook length', () {
    const c = HookLapCalculator();

    test('a hook is twelve diameters, worked by hand', () {
      // 10 mm bar: 12 × 10 = 120 mm.
      expect(c.hook(diameterMm: 10, count: 1).valueOf('hook_mm'),
          closeTo(120, 1e-9));
      // 25 mm bar: 12 × 25 = 300 mm.
      expect(c.hook(diameterMm: 25, count: 1).valueOf('hook_mm'),
          closeTo(300, 1e-9));
      // 16 mm bar: 12 × 16 = 192 mm — the printed table rounds this to 200.
      expect(c.hook(diameterMm: 16, count: 1).valueOf('hook_mm'),
          closeTo(192, 1e-9));
    });

    test('the rule is followed rather than the rounded printed table', () {
      // A 12 mm bar gives 144 mm. Tables print 150. The app computes the rule
      // and says in its assumptions that tables round up.
      final r = c.hook(diameterMm: 12, count: 1);
      expect(r.valueOf('hook_mm'), closeTo(144, 1e-9));
      expect(r.assumptions.map((a) => a.en).join(' '), contains('150'));
    });

    test('many hooks add up, and convert to feet', () {
      // 20 hooks on a 10 mm bar: 20 × 120 mm = 2400 mm = 94.488 in = 7.874 ft.
      final r = c.hook(diameterMm: 10, count: 20);
      expect(r.valueOf('total_mm'), closeTo(2400, 1e-9));
      expect(r.valueOf('total_ft'), closeTo(7.874, 1e-3));
    });

    test('a bar the shop sells by suta says so', () {
      final r = c.hook(diameterMm: 16, count: 1);
      expect(r.assumptions.map((a) => a.en).join(' '), contains('5 suta'));
    });

    test('nonsense input is refused', () {
      expect(() => c.hook(diameterMm: 0, count: 1),
          throwsA(isA<CalcException>()));
      expect(() => c.hook(diameterMm: 12, count: 0),
          throwsA(isA<CalcException>()));
    });

    test('the app refuses to give a lap length at all', () {
      // Deliberate: a lap depends on concrete grade, steel grade and position,
      // and a printed number would be used as permission.
      expect(HookLapCalculator.lapRefusal.en, contains('will not'));
      expect(HookLapCalculator.lapRefusal.bn, contains('নকশা'));
    });
  });

  group('Stair', () {
    const c = StairCalculator();

    test('a 10 ft floor height comes out as 20 equal risers of 6 inches', () {
      // 10 ft = 120 in. 120 / 6 = 20 exactly, so 20 risers of 6 in.
      final r = c.compute(floorHeightFt: 10);
      expect(r.valueOf('risers'), 20);
      expect(r.valueOf('riser_in'), closeTo(6, 1e-9));
      expect(r.valueOf('treads'), 19);
    });

    test('an awkward height moves the count, never the equality', () {
      // 9.5 ft = 114 in. 114 / 6 = 19 exactly.
      expect(c.compute(floorHeightFt: 9.5).valueOf('risers'), 19);
      // 10.5 ft = 126 in. 126 / 6 = 21 exactly.
      expect(c.compute(floorHeightFt: 10.5).valueOf('risers'), 21);
      // 10.25 ft = 123 in. 123 / 6 = 20.5, so 21 risers of 5.857 in.
      final r = c.compute(floorHeightFt: 10.25);
      expect(r.valueOf('risers'), 21);
      expect(r.valueOf('riser_in'), closeTo(123 / 21, 1e-9));
      expect(r.valueOf('riser_in')!, lessThanOrEqualTo(6.0));
    });

    test('the risers always multiply back to the height given', () {
      for (final h in [8.0, 9.0, 9.75, 10.0, 11.5, 12.0]) {
        final r = c.compute(floorHeightFt: h);
        final total = r.valueOf('risers')! * r.valueOf('riser_in')!;
        expect(total, closeTo(h * 12, 1e-6), reason: '$h ft');
      }
    });

    test('the flight length follows the treads, one fewer than the risers', () {
      // 20 risers, so 19 treads at 10 in = 190 in = 15.833 ft.
      expect(c.compute(floorHeightFt: 10).valueOf('going_ft'),
          closeTo(190 / 12, 1e-6));
    });

    test('too shallow a tread is refused', () {
      expect(() => c.compute(floorHeightFt: 10, treadIn: 8),
          throwsA(isA<CalcException>()));
      expect(() => c.compute(floorHeightFt: 0),
          throwsA(isA<CalcException>()));
    });
  });

  group('Water storage', () {
    const c = WaterStoreCalculator();

    test('six people at the ten gallon floor', () {
      // 6 × 10 = 60 gal/day. Reservoir 2 days = 120 gal = 19.2 cft.
      // Roof tank 1 day = 60 gal = 9.6 cft.
      final r = c.compute(people: 6);
      expect(r.valueOf('daily_gal'), closeTo(60, 1e-9));
      expect(r.valueOf('reservoir_gal'), closeTo(120, 1e-9));
      expect(r.valueOf('reservoir_cft'), closeTo(19.2, 1e-9));
      expect(r.valueOf('overhead_gal'), closeTo(60, 1e-9));
      expect(r.valueOf('overhead_cft'), closeTo(9.6, 1e-9));
    });

    test('the published 4 x 4 x 4 tank really does hold 400 gallons', () {
      // 64 cft × 6.25 gal/cft = 400. This is the identity that makes the
      // gallons-per-cubic-foot constant checkable rather than asserted.
      expect(64 * WaterStoreCalculator.gallonsPerCft, closeTo(400, 1e-9));
    });

    test('a heavier usage figure carries straight through', () {
      // 4 people at 30 gal = 120/day, reservoir 240 gal.
      final r = c.compute(people: 4, gallonsPerPersonPerDay: 30);
      expect(r.valueOf('daily_gal'), closeTo(120, 1e-9));
      expect(r.valueOf('reservoir_gal'), closeTo(240, 1e-9));
    });

    test('nobody and nothing are refused', () {
      expect(() => c.compute(people: 0), throwsA(isA<CalcException>()));
      expect(() => c.compute(people: 4, gallonsPerPersonPerDay: 0),
          throwsA(isA<CalcException>()));
    });

    test('septic sizes stay on the published table, never between rows', () {
      // 8 users takes the 10-user tank; 11 goes up to the 30-user one.
      expect(c.septicFor(8)!.users, 10);
      expect(c.septicFor(10)!.users, 10);
      expect(c.septicFor(11)!.users, 30);
      expect(c.septicFor(100)!.users, 100);
      // Past the end of the table the app declines rather than extrapolating.
      expect(c.septicFor(500), isNull);
    });

    test('the published septic volumes are what the dimensions give', () {
      // 6 × 2 × 3.5 = 42 cft for ten users.
      expect(c.septicFor(10)!.volumeCft, closeTo(42, 1e-9));
      // 9 × 2 × 4.5 = 81 cft for thirty.
      expect(c.septicFor(30)!.volumeCft, closeTo(81, 1e-9));
    });
  });

  group('Brick soling', () {
    const c = SolingCalculator();

    test('300 bricks in 100 square feet of flat soling', () {
      // 250 sft = 2.5 × 300 = 750 net, +5% = 787.5.
      final r = c.compute(areaSft: 250);
      expect(r.valueOf('bricks_net'), closeTo(750, 1e-9));
      expect(r.valueOf('bricks'), closeTo(787.5, 1e-9));
      // Sand: 2.5 × 5 = 12.5 cft.
      expect(r.valueOf('sand_cft'), closeTo(12.5, 1e-9));
    });

    test('herringbone takes far more, because it is laid on edge', () {
      final flat = c.compute(areaSft: 100, wastagePercent: 0);
      final herring = c.compute(areaSft: 100, wastagePercent: 0,
          herringbone: true);
      expect(flat.valueOf('bricks'), closeTo(300, 1e-9));
      expect(herring.valueOf('bricks'), closeTo(500, 1e-9));
    });

    test('wastage is shown separately from the net count', () {
      final r = c.compute(areaSft: 100, wastagePercent: 10);
      expect(r.valueOf('bricks_net'), closeTo(300, 1e-9));
      expect(r.valueOf('bricks'), closeTo(330, 1e-9));
    });

    test('it tells you to count before the concrete covers it', () {
      expect(c.compute(areaSft: 100).note!.en, contains('before the concrete'));
    });

    test('nonsense input is refused', () {
      expect(() => c.compute(areaSft: 0), throwsA(isA<CalcException>()));
      expect(() => c.compute(areaSft: 100, wastagePercent: -1),
          throwsA(isA<CalcException>()));
    });
  });

  group('Every new calculator keeps the app contract', () {
    test('a number never arrives without its formula and assumptions', () {
      final results = <CalcResult>[
        const HookLapCalculator().hook(diameterMm: 12, count: 4),
        const StairCalculator().compute(floorHeightFt: 10),
        const WaterStoreCalculator().compute(people: 5),
        const SolingCalculator().compute(areaSft: 100),
      ];
      for (final r in results) {
        expect(r.lines, isNotEmpty);
        expect(r.formula.bn, isNotEmpty);
        expect(r.formula.needsTranslation, isFalse);
        expect(r.assumptions, isNotEmpty);
        for (final a in r.assumptions) {
          expect(a.needsTranslation, isFalse, reason: a.bn);
        }
        for (final l in r.lines) {
          expect(l.label.needsTranslation, isFalse, reason: l.key);
          expect(l.unit.needsTranslation, isFalse, reason: l.key);
        }
      }
    });
  });
}
