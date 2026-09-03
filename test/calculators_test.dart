import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/calculators/logic/brickwork.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/calculators/logic/concrete.dart';
import 'package:nirman_pahara/features/calculators/logic/mix_ratio.dart';
import 'package:nirman_pahara/features/calculators/logic/plaster.dart';
import 'package:nirman_pahara/features/calculators/logic/rebar.dart';
import 'package:nirman_pahara/features/calculators/logic/road_layer.dart';
import 'package:nirman_pahara/features/calculators/logic/unit_cost.dart';
import 'package:nirman_pahara/features/calculators/logic/units.dart';

void main() {
  group('RebarCalculator', () {
    const c = RebarCalculator();

    test('16 mm bar weighs about 1.578 kg per metre', () {
      expect(c.kgPerMetre(16), closeTo(1.5783, 0.0005));
    });

    test('the site shortcut divisor is the familiar 162', () {
      expect(c.shortcutDivisor, closeTo(162.2, 0.1));
    });

    test('12 mm matches the d squared over 162 rule', () {
      expect(c.kgPerMetre(12), closeTo(144 / 162.2, 0.002));
    });

    test('20 pieces of 40 ft 16 mm bar weigh about 385 kg', () {
      final r = c.compute(diameterMm: 16, length: 40, pieces: 20);
      expect(r.valueOf('total_kg'), closeTo(384.9, 0.5));
      expect(r.valueOf('total_ton'), closeTo(0.3849, 0.001));
      expect(r.valueOf('total_length_ft'), closeTo(800, 0.01));
    });

    test('about 104 pieces of 20 ft 16 mm bar make a tonne', () {
      expect(c.piecesPerTon(16), closeTo(103.9, 0.5));
    });

    test('wastage increases the weight proportionally', () {
      final plain = c.compute(diameterMm: 12, length: 10, pieces: 1);
      final waste = c.compute(
          diameterMm: 12, length: 10, pieces: 1, wastagePercent: 10);
      expect(waste.valueOf('total_kg')! / plain.valueOf('total_kg')!,
          closeTo(1.10, 0.0001));
    });

    test('rejects nonsense input', () {
      expect(() => c.compute(diameterMm: 0, length: 10),
          throwsA(isA<CalcException>()));
      expect(() => c.compute(diameterMm: 12, length: -1),
          throwsA(isA<CalcException>()));
      expect(() => c.compute(diameterMm: 12, length: 10, pieces: 0),
          throwsA(isA<CalcException>()));
    });
  });

  group('ConcreteCalculator', () {
    const c = ConcreteCalculator();

    test('100 cft of 1:2:4 needs 17.6 bags, 44 cft sand, 88 cft khoa', () {
      final r = c.compute(volume: 100, ratio: MixRatio.c1_2_4);
      expect(r.valueOf('dry_cft'), closeTo(154, 0.001));
      expect(r.valueOf('cement_bags'), closeTo(17.6, 0.01));
      expect(r.valueOf('sand_cft'), closeTo(44, 0.01));
      expect(r.valueOf('aggregate_cft'), closeTo(88, 0.01));
      expect(r.valueOf('water_litre'), closeTo(396, 0.5));
    });

    test('the parts always add back up to the dry volume', () {
      final r = c.compute(volume: 63.5, ratio: MixRatio.c1_1p5_3);
      final sum = r.valueOf('cement_bags')! * Units.cftPerCementBag +
          r.valueOf('sand_cft')! +
          r.valueOf('aggregate_cft')!;
      expect(sum, closeTo(r.valueOf('dry_cft')!, 0.0001));
    });

    test('cubic metres convert before the mix is applied', () {
      final metric = c.compute(volume: 1, unit: VolumeUnit.m3);
      final imperial = c.compute(volume: Units.m3ToCft(1));
      expect(metric.valueOf('cement_bags'),
          closeTo(imperial.valueOf('cement_bags')!, 0.0001));
    });

    test('a mortar ratio is refused for concrete', () {
      expect(() => c.compute(volume: 10, ratio: MixRatio.m1_6),
          throwsA(isA<CalcException>()));
    });
  });

  group('BrickworkCalculator', () {
    const c = BrickworkCalculator();

    test('a standard brick with a 10 mm joint gives about 11.35 per cft', () {
      expect(c.bricksPerCft, closeTo(11.35, 0.02));
      expect(c.brickVolumeCft, closeTo(0.06803, 0.00005));
    });

    test('a 10 by 10 five inch wall needs about 497 bricks', () {
      final r =
          c.compute(lengthFt: 10, heightFt: 10, thicknessIn: 5);
      expect(r.valueOf('wall_cft'), closeTo(41.667, 0.01));
      expect(r.valueOf('bricks'), closeTo(497, 2));
      expect(r.valueOf('cement_bags'), closeTo(1.41, 0.05));
      expect(r.valueOf('sand_cft'), closeTo(10.58, 0.2));
    });

    test('openings are deducted from the wall area', () {
      final full = c.compute(lengthFt: 10, heightFt: 10, thicknessIn: 5);
      final withDoor = c.compute(
          lengthFt: 10, heightFt: 10, thicknessIn: 5, openingsSft: 20);
      expect(withDoor.valueOf('net_area_sft'), closeTo(80, 0.001));
      expect(withDoor.valueOf('bricks')! / full.valueOf('bricks')!,
          closeTo(0.8, 0.001));
    });

    test('a smaller brick means more bricks per cft', () {
      const small = BrickworkCalculator(
          brickLengthIn: 9.0, brickWidthIn: 4.25, brickHeightIn: 2.5);
      expect(small.bricksPerCft, greaterThan(c.bricksPerCft));
    });

    test('rejects a wall that is entirely openings', () {
      expect(
          () => c.compute(
              lengthFt: 10, heightFt: 10, thicknessIn: 5, openingsSft: 100),
          throwsA(isA<CalcException>()));
    });
  });

  group('PlasterCalculator', () {
    const c = PlasterCalculator();

    test('100 sft of half inch 1:6 plaster needs about 0.62 bags', () {
      final r = c.compute(area: 100);
      expect(r.valueOf('wet_cft'), closeTo(4.1667, 0.001));
      expect(r.valueOf('cement_bags'), closeTo(0.619, 0.005));
      expect(r.valueOf('sand_cft'), closeTo(4.643, 0.01));
    });

    test('double the thickness doubles the material', () {
      final thin = c.compute(area: 100, thicknessIn: 0.5);
      final thick = c.compute(area: 100, thicknessIn: 1.0);
      expect(thick.valueOf('sand_cft')! / thin.valueOf('sand_cft')!,
          closeTo(2.0, 0.0001));
    });
  });

  group('RoadLayerCalculator', () {
    const c = RoadLayerCalculator();

    test('a 1000 by 12 ft road with a 150 mm sub-base', () {
      final r = c.compute(length: 1000, width: 12, layers: const [
        RoadLayerSpec(name: L10nText('সাব-বেজ', 'Sub-base'), thickness: 150),
      ]);
      expect(r.valueOf('area_sft'), closeTo(12000, 0.01));
      expect(r.valueOf('layer_0_compacted_cft'), closeTo(5905.5, 1));
      expect(r.valueOf('layer_0_loose_cft'), closeTo(7381.9, 1));
    });

    test('layers add up', () {
      final r = c.compute(length: 100, width: 10, layers: const [
        RoadLayerSpec(name: L10nText('সাব-বেজ', 'Sub-base'), thickness: 150),
        RoadLayerSpec(name: L10nText('বেজ', 'Base'), thickness: 150),
      ]);
      expect(
        r.valueOf('total_compacted_cft'),
        closeTo(r.valueOf('layer_0_compacted_cft')! +
            r.valueOf('layer_1_compacted_cft')!,
            0.0001),
      );
    });

    test('rejects an empty layer list', () {
      expect(() => c.compute(length: 100, width: 10, layers: const []),
          throwsA(isA<CalcException>()));
    });
  });

  group('UnitCostCalculator', () {
    const c = UnitCostCalculator();

    test('a 42.5 lakh contract over 1200 m is about 3542 per metre', () {
      final r = c.compute(
        contractValue: 4250000,
        quantity: 1200,
        quantityUnit: const L10nText('মিটার', 'metre'),
        incomeTaxPercent: 7,
      );
      expect(r.valueOf('gross_rate'), closeTo(3541.67, 0.5));
      expect(r.valueOf('net_rate'), closeTo(2939.58, 0.5));
      expect(r.valueOf('net_value'), closeTo(3527500, 1));
    });

    test('deductions cannot swallow the whole contract', () {
      // Income tax is a free-typed percentage on a screen about a government
      // contract. Typing 100 where 10 was meant made the deduction bigger than
      // the contract, and the result printed a negative "contractor receives"
      // as an ordinary row with nothing marking it as nonsense.
      expect(
        () => c.compute(
          contractValue: 4250000,
          quantity: 1200,
          quantityUnit: const L10nText('মিটার', 'metre'),
          incomeTaxPercent: 100,
        ),
        throwsA(isA<CalcException>()),
      );
      // The ordinary case is untouched.
      expect(
        c
            .compute(
              contractValue: 4250000,
              quantity: 1200,
              quantityUnit: const L10nText('মিটার', 'metre'),
              incomeTaxPercent: 7,
            )
            .valueOf('net_value'),
        greaterThan(0),
      );
    });

    test('comparison against a reference rate reports the gap', () {
      final r = c.compute(
        contractValue: 1000000,
        quantity: 100,
        quantityUnit: const L10nText('মিটার', 'metre'),
        vatPercent: 0,
        comparisonRate: 8000,
      );
      expect(r.valueOf('diff_percent'), closeTo(25, 0.001));
    });

    test('never claims wrongdoing in the note', () {
      final r = c.compute(
        contractValue: 1000000,
        quantity: 10,
        quantityUnit: const L10nText('মিটার', 'metre'),
        comparisonRate: 10000,
      );
      expect(r.note, isNotNull);
      expect(r.note!.bn, isNot(contains('দুর্নীতি')));
      expect(r.note!.bn, isNot(contains('চুরি')));
      expect(r.note!.en, isNot(contains('corrupt')));
      expect(r.note!.en, isNot(contains('theft')));
    });

    test('rejects zero quantity', () {
      expect(
          () => c.compute(
              contractValue: 1000, quantity: 0, quantityUnit: const L10nText('মিটার', 'metre')),
          throwsA(isA<CalcException>()));
    });
  });

  group('MixRatio', () {
    test('parses a three part concrete ratio', () {
      expect(MixRatio.parse('1:2:4'), MixRatio.c1_2_4);
      expect(MixRatio.parse('1 : 1.5 : 3'), MixRatio.c1_1p5_3);
    });

    test('parses a two part mortar ratio', () {
      expect(MixRatio.parse('1:6'), MixRatio.m1_6);
      expect(MixRatio.parse('1:6').isMortar, isTrue);
    });

    test('rejects malformed ratios', () {
      expect(() => MixRatio.parse('1'), throwsA(isA<CalcException>()));
      expect(() => MixRatio.parse('1:2:4:8'), throwsA(isA<CalcException>()));
      expect(() => MixRatio.parse('1:0'), throwsA(isA<CalcException>()));
      expect(() => MixRatio.parse('a:b'), throwsA(isA<CalcException>()));
    });
  });

  group('Every result explains itself', () {
    test('formula and assumptions are never empty', () {
      final results = <CalcResult>[
        const RebarCalculator().compute(diameterMm: 16, length: 40, pieces: 4),
        const ConcreteCalculator().compute(volume: 100),
        const BrickworkCalculator()
            .compute(lengthFt: 10, heightFt: 10, thicknessIn: 5),
        const PlasterCalculator().compute(area: 100),
        const RoadLayerCalculator().compute(
            length: 100,
            width: 10,
            layers: const [RoadLayerSpec(name: L10nText('বেজ', 'Base'), thickness: 150)]),
        const UnitCostCalculator().compute(
            contractValue: 100000, quantity: 100, quantityUnit: const L10nText('মিটার', 'metre')),
      ];
      for (final r in results) {
        expect(r.formula.bn.trim(), isNotEmpty);
        expect(r.formula.en, isNotNull);
        expect(r.formula.en!.trim(), isNotEmpty);
        expect(r.assumptions, isNotEmpty);
        expect(r.lines, isNotEmpty);
        for (final a in r.assumptions) {
          expect(a.needsTranslation, isFalse,
              reason: 'assumption not translated: ${a.bn}');
        }
        for (final l in r.lines) {
          expect(l.label.needsTranslation, isFalse,
              reason: 'label not translated: ${l.label.bn}');
          expect(l.unit.needsTranslation, isFalse,
              reason: 'unit not translated: ${l.unit.bn}');
        }
        expect(r.note?.needsTranslation ?? false, isFalse);
      }
    });
  });
}
