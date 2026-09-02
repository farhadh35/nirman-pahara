import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/measure/logic/geometry.dart';
import 'package:nirman_pahara/features/measure/logic/land_units.dart';
import 'package:nirman_pahara/features/measure/logic/sutas.dart';

void main() {
  group('Land units', () {
    // The whole chain has to close, or a plot converted twice comes back a
    // different size than it went in.
    test('the Bangladeshi chain closes against the acre', () {
      expect(LandUnit.acre.squareFeet, 43560);
      expect(LandUnit.acre.per(LandUnit.katha), closeTo(60.5, 1e-9));
      expect(LandUnit.acre.per(LandUnit.bigha), closeTo(3.025, 1e-9));
      expect(LandUnit.acre.per(LandUnit.decimal), closeTo(100, 1e-9));
      expect(LandUnit.katha.per(LandUnit.chatak), closeTo(16, 1e-9));
      expect(LandUnit.bigha.per(LandUnit.katha), closeTo(20, 1e-9));
    });

    test('a round trip through any unit returns the same area', () {
      for (final unit in LandUnit.values) {
        final area = LandArea.of(7.5, unit);
        expect(area.asUnit(unit), closeTo(7.5, 1e-9), reason: unit.name);
      }
    });

    test('one katha is 720 square feet and one decimal is 435.6', () {
      expect(LandArea.of(1, LandUnit.katha).squareFeet, closeTo(720, 1e-9));
      expect(LandArea.of(1, LandUnit.decimal).squareFeet, closeTo(435.6, 1e-9));
    });

    test('a square metre is 10.7639 square feet, not 10', () {
      expect(LandArea.of(1, LandUnit.squareMetre).squareFeet,
          closeTo(10.7639, 1e-4));
      // One hectare is 10,000 m², so 107,639 sft. The book printed 1,000 m²
      // for a hectare, which is the error this constant guards against.
      expect(LandUnit.hectare.squareFeet / LandUnit.squareMetre.squareFeet,
          closeTo(10000, 1e-6));
    });

    test('an area reads back as bigha, katha and the remainder', () {
      // 1 bigha + 3 katha + 100 sft = 14400 + 2160 + 100.
      final a = LandArea.of(14400 + 2160 + 100, LandUnit.squareFoot);
      expect(a.breakdown.bigha, 1);
      expect(a.breakdown.katha, 3);
      expect(a.breakdown.squareFeet, closeTo(100, 1e-9));
    });

    test('a negative area is refused rather than quietly flipped', () {
      expect(() => LandArea.of(-1, LandUnit.katha), throwsArgumentError);
    });
  });

  group('Suta', () {
    // A suta is an eighth of an inch. Everything else follows from that.
    test('suta are eighths of an inch', () {
      expect(SutaSize.three.inches, closeTo(3 / 8, 1e-12));
      expect(SutaSize.four.inches, closeTo(0.5, 1e-12));
      expect(SutaSize.eight.inches, closeTo(1.0, 1e-12));
    });

    test('the trade sizes a 3 suta bar as 10 mm although 3/8 inch is 9.525', () {
      expect(SutaSize.three.nominalMm, 10);
      expect(SutaSize.three.exactMm, closeTo(9.525, 1e-3));
      // The gap is real and the app shows it rather than rounding it away.
      expect(SutaSize.three.roundingMm, closeTo(0.475, 1e-3));
    });

    test('a mason asking for 5 suta means the 16 mm bar', () {
      expect(SutaSize.five.nominalMm, 16);
      expect(SutaSize.forMm(16), SutaSize.five);
      expect(SutaSize.forSuta(5), SutaSize.five);
    });

    test('a size the table does not carry falls to the nearest', () {
      expect(SutaSize.forMm(18), isNull);
      expect(SutaSize.nearestToMm(18), SutaSize.five);
    });

    test('the inch label reads the way it is spoken', () {
      expect(SutaSize.three.inchLabel, '3/8"');
      expect(SutaSize.four.inchLabel, '1/2"');
      expect(SutaSize.two.inchLabel, '1/4"');
      expect(SutaSize.six.inchLabel, '3/4"');
      expect(SutaSize.eight.inchLabel, '1"');
    });
  });

  group('Geometry', () {
    const g = Geometry();

    test('a rectangle and a box', () {
      expect(g.compute(Shape.rectangle, [12, 10]).valueOf('area'),
          closeTo(120, 1e-9));
      expect(g.compute(Shape.box, [12, 10, 3]).valueOf('volume'),
          closeTo(360, 1e-9));
    });

    test('a triangle is half the base times the height', () {
      expect(g.compute(Shape.triangle, [10, 6]).valueOf('area'),
          closeTo(30, 1e-9));
    });

    test('a trapezium averages the parallel sides', () {
      // ½ × (8 + 12) × 5 = 50.
      expect(g.compute(Shape.trapezium, [8, 12, 5]).valueOf('area'),
          closeTo(50, 1e-9));
    });

    test('round shapes take the diameter, not the radius', () {
      // A 10 ft circle is π × 5² = 78.54, not π × 10² = 314.
      expect(g.compute(Shape.circle, [10]).valueOf('area'),
          closeTo(78.5398, 1e-3));
      expect(g.compute(Shape.cylinder, [10, 4]).valueOf('volume'),
          closeTo(314.159, 1e-2));
      // A cone is a third of the cylinder that contains it.
      expect(g.compute(Shape.cone, [10, 4]).valueOf('volume'),
          closeTo(104.7197, 1e-3));
      expect(g.compute(Shape.sphere, [10]).valueOf('volume'),
          closeTo(523.5987, 1e-3));
    });

    test('every shape says how it was worked out', () {
      for (final s in Shape.values) {
        final r = g.compute(s, List.filled(s.inputs.length, 4));
        expect(r.formula.bn, isNotEmpty, reason: s.name);
        expect(r.assumptions, isNotEmpty, reason: s.name);
      }
    });

    test('a wrong number of measurements is refused, not guessed', () {
      expect(() => g.compute(Shape.trapezium, [8, 12]),
          throwsA(isA<CalcException>()));
      expect(() => g.compute(Shape.rectangle, [10, 0]),
          throwsA(isA<CalcException>()));
    });
  });
}
