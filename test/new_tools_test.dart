import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/calculators/logic/brick_stack.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/calculators/logic/earthwork.dart';
import 'package:nirman_pahara/features/calculators/logic/paint.dart';
import 'package:nirman_pahara/features/calculators/logic/rod_delivery.dart';
import 'package:nirman_pahara/features/calculators/logic/shuttering.dart';
import 'package:nirman_pahara/features/calculators/logic/tiles.dart';
import 'package:nirman_pahara/features/rules/logic/far_calculator.dart';
import 'package:nirman_pahara/features/rules/logic/far_rules.dart';

Future<FarPack> loadFar() async => FarPack.fromJson(
    jsonDecode(await File('assets/content/rules/far_2025.json').readAsString())
        as Map<String, dynamic>);

void main() {
  group('FAR from the 2025 gazette', () {
    late FarPack pack;
    setUp(() async => pack = await loadFar());

    test('the table carries every use the gazette prints', () {
      // 51 rows: housing three times over for its three zones, everything else
      // once. If a re-extraction drops a row this fails rather than quietly
      // answering for fewer uses.
      expect(pack.uses.length, 51);
      expect(pack.zones.length, 3);
      expect(pack.roadBands.length, 9);
      expect(pack.uses.where((u) => u.code.startsWith('A')).length, 18);
      expect(pack.useCodes.length, 39);
    });

    test('a road falls in the column the gazette would put it in', () {
      expect(pack.bandIndex(1.8), 0);
      expect(pack.bandIndex(2.49), 0);
      expect(pack.bandIndex(2.5), 1);
      expect(pack.bandIndex(3.659), 1);
      expect(pack.bandIndex(3.66), 2);
      expect(pack.bandIndex(6.0), 4);
      expect(pack.bandIndex(12.0), 6);
      expect(pack.bandIndex(24.0), 8);
      expect(pack.bandIndex(100.0), 8);
      // Below the table entirely.
      expect(pack.bandIndex(1.79), isNull);
      expect(pack.bandIndex(double.nan), isNull);
    });

    test('a single-family house in central Dhaka reads off the printed row', () {
      // Read from the rendered gazette page 13460, row 1 / A1:
      // 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 3.75, 4.25
      final a1 = pack.use('A1', zone: 'central')!;
      expect(a1.far, [1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 3.75, 4.25]);
    });

    test('the three zones really do differ', () {
      // Central Dhaka gets a higher FAR than the outer areas on the same road,
      // which is the whole reason the gazette splits housing three ways.
      final central = pack.use('A1', zone: 'central')!.far[0];
      final other = pack.use('A1', zone: 'other')!.far[0];
      expect(central, 1.25);
      expect(other, 1.0);
    });

    test('three katha on a 12 metre road gives the floor area budget', () {
      // 3 katha = 3 × 720 = 2160 sft. A 12 m road is column 7 (index 6), where
      // A1 central reads 3.5. 2160 × 3.5 = 7560 sft over every storey.
      final r = FarCalculator(pack: pack).compute(
        plotAreaSft: 2160,
        roadWidthM: 12.0,
        useCode: 'A1',
        zone: 'central',
        storeys: 6,
      );
      expect(r.valueOf('far'), 3.5);
      expect(r.valueOf('max_floor_area_sft'), closeTo(7560, 0.001));
      expect(r.valueOf('per_floor_sft'), closeTo(1260, 0.001));
    });

    test('a use the road cannot carry is refused, not answered with zero', () {
      // A5 (hotels) is dashed out on every road under 6 m. A dash is a refusal.
      expect(
        () => FarCalculator(pack: pack)
            .compute(plotAreaSft: 2160, roadWidthM: 3.0, useCode: 'A5', zone: 'central'),
        throwsA(isA<CalcException>()),
      );
    });

    test('a road narrower than the table is refused', () {
      expect(
        () => FarCalculator(pack: pack)
            .compute(plotAreaSft: 2160, roadWidthM: 1.5, useCode: 'A1', zone: 'central'),
        throwsA(isA<CalcException>()),
      );
    });

    test('nonsense input is refused', () {
      final c = FarCalculator(pack: pack);
      for (final bad in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          () => c.compute(plotAreaSft: bad, roadWidthM: 12, useCode: 'A1', zone: 'central'),
          throwsA(isA<CalcException>()),
        );
        expect(
          () => c.compute(plotAreaSft: 2160, roadWidthM: bad, useCode: 'A1', zone: 'central'),
          throwsA(isA<CalcException>()),
        );
      }
      expect(
        () => c.compute(
            plotAreaSft: 2160, roadWidthM: 12, useCode: 'A1', zone: 'central', storeys: 0),
        throwsA(isA<CalcException>()),
      );
      expect(
        () => c.compute(plotAreaSft: 2160, roadWidthM: 12, useCode: 'ZZ9'),
        throwsA(isA<CalcException>()),
      );
    });

    test('every row rises with the road and never restarts after a dash', () {
      // Structural facts of the printed table. They caught a bleed from the
      // neighbouring column during extraction and they still hold the file.
      for (final u in pack.uses) {
        final vals = u.far.whereType<double>().toList();
        expect(vals, isNotEmpty, reason: '${u.code} has no FAR at all');
        expect(vals, orderedEquals(vals.toList()..sort()),
            reason: '${u.code} falls as the road widens');
        final idx = [
          for (var i = 0; i < u.far.length; i++)
            if (u.far[i] != null) i,
        ];
        expect(idx, List.generate(u.far.length - idx.first, (i) => idx.first + i),
            reason: '${u.code} is permitted, then not, then permitted again');
      }
    });

    test('it says plainly that it is a ceiling, not a permission', () {
      final r = FarCalculator(pack: pack).compute(
          plotAreaSft: 2160, roadWidthM: 12, useCode: 'A1', zone: 'central');
      expect(r.note, isNotNull);
      expect(r.note!.bn, contains('অনুমোদন নয়'));
      expect((r.note!.en ?? "").toLowerCase(), contains('not an approval'));
      // The reading it had to make about the upper columns is disclosed.
      expect(r.assumptions.any((a) => (a.en ?? "").contains("interpretation")), isTrue);
    });
  });

  group('rod delivery', () {
    test('a tonne of 16 mm in 40 foot lengths is 52 bars', () {
      // 16 mm: area = pi x 0.016^2 / 4 = 2.01062e-4 m^2, x 7850 = 1.57834 kg/m,
      // x 0.3048 = 0.481077 kg/ft, x 40 = 19.2431 kg a bar. 1000 / 19.2431 =
      // 51.97, so 52 bars should come off the truck.
      final r = const RodDeliveryCalculator()
          .expectedBars(orderedKg: 1000, diameterMm: 16);
      expect(r.valueOf('kg_per_foot')!, closeTo(0.481077, 1e-5));
      expect(r.valueOf('kg_per_bar')!, closeTo(19.2431, 1e-3));
      expect(r.valueOf('bars')!, closeTo(51.966, 1e-2));
    });

    test('a 20 foot bar doubles the count for the same weight', () {
      final long = const RodDeliveryCalculator()
          .expectedBars(orderedKg: 1000, diameterMm: 16, stockLengthFt: 40);
      final short = const RodDeliveryCalculator()
          .expectedBars(orderedKg: 1000, diameterMm: 16, stockLengthFt: 20);
      expect(short.valueOf('bars')!, closeTo(long.valueOf('bars')! * 2, 1e-6));
    });

    test('nonsense input is refused', () {
      for (final bad in [0.0, -5.0, double.nan]) {
        expect(
          () => const RodDeliveryCalculator()
              .expectedBars(orderedKg: bad, diameterMm: 16),
          throwsA(isA<CalcException>()),
        );
        expect(
          () => const RodDeliveryCalculator()
              .expectedBars(orderedKg: 1000, diameterMm: 16, stockLengthFt: bad),
          throwsA(isA<CalcException>()),
        );
      }
    });
  });

  group('brick stack', () {
    test('counting layers is exact', () {
      final r = const BrickStackCalculator()
          .fromLayers(along: 20, across: 10, layers: 15);
      expect(r.valueOf('bricks'), 3000);
      expect(r.valueOf('per_layer'), 200);
    });

    test('the tape method uses the brick the app already knows', () {
      // One BDS brick is 9.5 x 4.5 x 2.75 in = 117.5625 cu in = 0.0680 cft, so
      // a cubic foot of tight stack holds 14.7. A 10 x 5 x 4 ft stack less 5%
      // for gaps is 190 cft, which is 2793 bricks.
      expect(BrickStackCalculator.brickCft, closeTo(0.0680339, 1e-6));
      expect(BrickStackCalculator.bricksPerCft, closeTo(14.6986, 1e-3));
      final r = const BrickStackCalculator()
          .fromStack(lengthFt: 10, widthFt: 5, heightFt: 4);
      expect(r.valueOf('stack_cft'), 200);
      expect(r.valueOf('bricks')!, closeTo(2792.66, 0.5));
    });

    test('nonsense input is refused', () {
      expect(() => const BrickStackCalculator().fromLayers(along: 0, across: 5, layers: 5),
          throwsA(isA<CalcException>()));
      expect(
          () => const BrickStackCalculator()
              .fromStack(lengthFt: double.nan, widthFt: 5, heightFt: 4),
          throwsA(isA<CalcException>()));
      expect(
          () => const BrickStackCalculator()
              .fromStack(lengthFt: 10, widthFt: 5, heightFt: 4, gapPercent: 100),
          throwsA(isA<CalcException>()));
    });
  });

  group('paint', () {
    test('area less openings, times coats, over the coverage on the tin', () {
      // (1000 - 100) x 2 / 110 = 16.36 litres, plus 5% = 17.18.
      final r = const PaintCalculator().compute(
          surfaceSft: 1000, coverageSftPerLitre: 110, openingsSft: 100);
      expect(r.valueOf('net_area_sft'), 900);
      expect(r.valueOf('litres_net')!, closeTo(16.3636, 1e-3));
      expect(r.valueOf('litres')!, closeTo(17.1818, 1e-3));
    });

    test('it never assumes a coverage of its own', () {
      // The parameter is required, and the assumption line says whose number
      // it is. No source in this repo states litres per square foot.
      final r = const PaintCalculator()
          .compute(surfaceSft: 500, coverageSftPerLitre: 120);
      expect(r.assumptions.first.bn, contains('আপনি যা'));
      expect(r.assumptions.first.en, contains('as you entered it'));
      expect(
        () => const PaintCalculator()
            .compute(surfaceSft: 500, coverageSftPerLitre: 0),
        throwsA(isA<CalcException>()),
      );
    });

    test('openings cannot swallow the wall', () {
      expect(
        () => const PaintCalculator().compute(
            surfaceSft: 500, coverageSftPerLitre: 120, openingsSft: 500),
        throwsA(isA<CalcException>()),
      );
      expect(
        () => const PaintCalculator()
            .compute(surfaceSft: 500, coverageSftPerLitre: 120, coats: 0),
        throwsA(isA<CalcException>()),
      );
    });
  });

  group('earthwork', () {
    test('the heap is bigger than the hole, and the trips follow the heap', () {
      // 10 x 8 x 5 = 400 cft in the ground; swelling 25% makes a 500 cft heap;
      // a 100 cft lorry therefore runs 5 times, not 4.
      final r = const EarthworkCalculator().compute(
        lengthFt: 10,
        widthFt: 8,
        depthFt: 5,
        bulkingPercent: 25,
        truckCapacityCft: 100,
      );
      expect(r.valueOf('in_ground_cft'), 400);
      expect(r.valueOf('loose_cft'), 500);
      expect(r.valueOf('trips'), 5);
    });

    test('a part load still costs a whole trip', () {
      final r = const EarthworkCalculator().compute(
        lengthFt: 10, widthFt: 8, depthFt: 5,
        bulkingPercent: 25, truckCapacityCft: 120,
      );
      // 500 / 120 = 4.17, and nobody sends four-sixths of a lorry.
      expect(r.valueOf('trips'), 5);
    });

    test('with no truck given it stops at the two volumes', () {
      final r = const EarthworkCalculator()
          .compute(lengthFt: 10, widthFt: 8, depthFt: 5, bulkingPercent: 0);
      expect(r.valueOf('trips'), isNull);
      expect(r.valueOf('loose_cft'), 400);
    });

    test('nonsense input is refused', () {
      expect(
        () => const EarthworkCalculator().compute(
            lengthFt: 0, widthFt: 8, depthFt: 5, bulkingPercent: 25),
        throwsA(isA<CalcException>()),
      );
      expect(
        () => const EarthworkCalculator().compute(
            lengthFt: 10, widthFt: 8, depthFt: 5, bulkingPercent: -1),
        throwsA(isA<CalcException>()),
      );
      expect(
        () => const EarthworkCalculator().compute(
            lengthFt: 10, widthFt: 8, depthFt: 5,
            bulkingPercent: 25, truckCapacityCft: 0),
        throwsA(isA<CalcException>()),
      );
    });
  });

  group('tiles', () {
    test('a 24 inch tile is four square feet, so 120 sft is 30 of them', () {
      final r = const TileCalculator()
          .compute(areaSft: 120, tileLengthIn: 24, tileWidthIn: 24);
      expect(r.valueOf('tile_sft'), 4.0);
      expect(r.valueOf('tiles_net'), 30);
      // 30 + 10% = 33.
      expect(r.valueOf('tiles'), 33);
    });

    test('boxes round up, because half a box is not sold', () {
      final r = const TileCalculator().compute(
          areaSft: 120, tileLengthIn: 24, tileWidthIn: 24, tilesPerBox: 4);
      expect(r.valueOf('boxes'), 9);
    });

    test('nonsense input is refused', () {
      expect(
        () => const TileCalculator()
            .compute(areaSft: 120, tileLengthIn: 0, tileWidthIn: 24),
        throwsA(isA<CalcException>()),
      );
      expect(
        () => const TileCalculator().compute(
            areaSft: 120, tileLengthIn: 24, tileWidthIn: 24, tilesPerBox: 0),
        throwsA(isA<CalcException>()),
      );
    });
  });

  group('shuttering', () {
    test('a beam is two sides and a bottom, never the top', () {
      // 10 in wide, 18 in deep, 20 ft span:
      // (2 x 1.5 + 0.8333) x 20 = 76.67 sft.
      final r = const ShutteringCalculator()
          .compute(element: ShutterElement.beam, a: 10, b: 18, runFt: 20);
      expect(r.valueOf('area_sft')!, closeTo(76.6667, 1e-3));
      expect(r.assumptions.any((x) => (x.en ?? "").contains("top of the beam")), isTrue);
    });

    test('a column is all four faces', () {
      // 12 x 15 in over 10 ft: 2 x (1 + 1.25) x 10 = 45 sft.
      final r = const ShutteringCalculator()
          .compute(element: ShutterElement.column, a: 12, b: 15, runFt: 10);
      expect(r.valueOf('area_sft')!, closeTo(45, 1e-6));
    });

    test('a slab is its underside plus the edge all round', () {
      // 20 x 15 ft, 5 in thick: 300 + 2 x 35 x 0.41667 = 329.17 sft.
      final r = const ShutteringCalculator()
          .compute(element: ShutterElement.slab, a: 20, b: 15, runFt: 5);
      expect(r.valueOf('area_sft')!, closeTo(329.1667, 1e-3));
    });

    test('a wall needs shuttering on both faces', () {
      final r = const ShutteringCalculator()
          .compute(element: ShutterElement.wall, a: 20, b: 1, runFt: 10);
      expect(r.valueOf('area_sft')!, closeTo(400, 1e-6));
    });

    test('a count multiplies and shows the single member too', () {
      final r = const ShutteringCalculator().compute(
          element: ShutterElement.column, a: 12, b: 15, runFt: 10, count: 8);
      expect(r.valueOf('area_sft')!, closeTo(360, 1e-6));
      expect(r.valueOf('per_one_sft')!, closeTo(45, 1e-6));
    });

    test('nonsense input is refused', () {
      expect(
        () => const ShutteringCalculator()
            .compute(element: ShutterElement.beam, a: 0, b: 18, runFt: 20),
        throwsA(isA<CalcException>()),
      );
      expect(
        () => const ShutteringCalculator().compute(
            element: ShutterElement.beam, a: 10, b: 18, runFt: 20, count: 0),
        throwsA(isA<CalcException>()),
      );
    });
  });

  test('every new tool still keeps the app contract', () async {
    // A number never arrives without the formula that made it and the
    // assumptions it rests on, and nothing ships half-translated.
    final pack = await loadFar();
    final results = <CalcResult>[
      FarCalculator(pack: pack).compute(
          plotAreaSft: 2160, roadWidthM: 12, useCode: 'A1', zone: 'central'),
      const RodDeliveryCalculator().expectedBars(orderedKg: 1000, diameterMm: 16),
      const BrickStackCalculator().fromLayers(along: 20, across: 10, layers: 15),
      const BrickStackCalculator().fromStack(lengthFt: 10, widthFt: 5, heightFt: 4),
      const PaintCalculator().compute(surfaceSft: 900, coverageSftPerLitre: 110),
      const EarthworkCalculator().compute(
          lengthFt: 10, widthFt: 8, depthFt: 5,
          bulkingPercent: 25, truckCapacityCft: 100),
      const TileCalculator()
          .compute(areaSft: 120, tileLengthIn: 24, tileWidthIn: 24),
      const ShutteringCalculator()
          .compute(element: ShutterElement.beam, a: 10, b: 18, runFt: 20),
    ];
    for (final r in results) {
      expect(r.lines, isNotEmpty);
      expect(r.lines.any((l) => l.emphasis), isTrue);
      expect(r.formula.bn.trim(), isNotEmpty);
      expect(r.formula.en?.trim() ?? '', isNotEmpty);
      expect(r.assumptions, isNotEmpty);
      for (final a in r.assumptions) {
        expect(a.bn.trim(), isNotEmpty);
        expect(a.en?.trim() ?? '', isNotEmpty);
        expect(a.bn, isNot(equals(a.en)));
      }
    }
  });
}
