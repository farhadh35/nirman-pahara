import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/calculators/logic/brick_stack.dart';
import 'package:nirman_pahara/features/calculators/logic/brickwork.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/calculators/logic/concrete.dart';
import 'package:nirman_pahara/features/calculators/logic/earthwork.dart';
import 'package:nirman_pahara/features/calculators/logic/hook_lap.dart';
import 'package:nirman_pahara/features/calculators/logic/paint.dart';
import 'package:nirman_pahara/features/calculators/logic/plaster.dart';
import 'package:nirman_pahara/features/calculators/logic/rebar.dart';
import 'package:nirman_pahara/features/calculators/logic/road_layer.dart';
import 'package:nirman_pahara/features/calculators/logic/rod_delivery.dart';
import 'package:nirman_pahara/features/calculators/logic/shuttering.dart';
import 'package:nirman_pahara/features/calculators/logic/soling.dart';
import 'package:nirman_pahara/features/calculators/logic/stair.dart';
import 'package:nirman_pahara/features/calculators/logic/tiles.dart';
import 'package:nirman_pahara/features/calculators/logic/unit_cost.dart';
import 'package:nirman_pahara/features/calculators/logic/water_store.dart';
import 'package:nirman_pahara/features/measure/logic/geometry.dart';
import 'package:nirman_pahara/features/measure/logic/land_units.dart';

const _sand = RoadLayerSpec(
  name: L10nText('বালি', 'Sand'),
  thickness: 150,
);

/// One numeric way into a calculator, with every other input left sane.
typedef Entry = CalcResult Function(double bad);

void main() {
  // A guard written as `x <= 0` looks complete and is not: every comparison
  // against NaN is false, so a value that failed to parse walks past it and
  // comes out the far end printed as "NaN". The hole was found in the geometry
  // tool and turned out to be in eleven more files, which is what this sweep
  // exists to stop happening again.
  //
  // Each entry pushes a bad number into one input. A calculator may refuse it
  // however it likes, but it may never answer with one.
  final entries = <String, Entry>{
    'brickwork.lengthFt': (b) => const BrickworkCalculator()
        .compute(lengthFt: b, heightFt: 10, thicknessIn: 5),
    'brickwork.heightFt': (b) => const BrickworkCalculator()
        .compute(lengthFt: 10, heightFt: b, thicknessIn: 5),
    'brickwork.thicknessIn': (b) => const BrickworkCalculator()
        .compute(lengthFt: 10, heightFt: 10, thicknessIn: b),
    'brickwork.openingsSft': (b) => const BrickworkCalculator()
        .compute(lengthFt: 10, heightFt: 10, thicknessIn: 5, openingsSft: b),
    'concrete.volume': (b) => const ConcreteCalculator().compute(volume: b),
    'plaster.area': (b) => const PlasterCalculator().compute(area: b),
    'plaster.thicknessIn': (b) =>
        const PlasterCalculator().compute(area: 100, thicknessIn: b),
    'rebar.diameterMm': (b) =>
        const RebarCalculator().compute(diameterMm: b, length: 40),
    'rebar.length': (b) =>
        const RebarCalculator().compute(diameterMm: 16, length: b),
    'rebar.wastagePercent': (b) => const RebarCalculator()
        .compute(diameterMm: 16, length: 40, wastagePercent: b),
    'road_layer.length': (b) => const RoadLayerCalculator().compute(
        length: b, width: 10, layers: const [_sand]),
    'road_layer.width': (b) => const RoadLayerCalculator().compute(
        length: 100, width: b, layers: const [_sand]),
    'road_layer.thickness': (b) => const RoadLayerCalculator().compute(
        length: 100,
        width: 10,
        layers: [RoadLayerSpec(name: const L10nText('বালি', 'Sand'), thickness: b)]),
    'soling.areaSft': (b) => const SolingCalculator().compute(areaSft: b),
    'soling.wastagePercent': (b) =>
        const SolingCalculator().compute(areaSft: 100, wastagePercent: b),
    'stair.floorHeightFt': (b) =>
        const StairCalculator().compute(floorHeightFt: b),
    'stair.treadIn': (b) =>
        const StairCalculator().compute(floorHeightFt: 10, treadIn: b),
    'unit_cost.contractValue': (b) => const UnitCostCalculator().compute(
        contractValue: b, quantity: 10, quantityUnit: U.cft),
    'unit_cost.quantity': (b) => const UnitCostCalculator().compute(
        contractValue: 1000, quantity: b, quantityUnit: U.cft),
    'water_store.gallons': (b) => const WaterStoreCalculator()
        .compute(people: 10, gallonsPerPersonPerDay: b),
    'hook_lap.diameterMm': (b) =>
        const HookLapCalculator().hook(diameterMm: b, count: 4),
    'geometry.rectangle': (b) => const Geometry().compute(Shape.rectangle, [b, 10]),
    'paint.surfaceSft': (b) =>
        const PaintCalculator().compute(surfaceSft: b, coverageSftPerLitre: 110),
    'paint.coverage': (b) =>
        const PaintCalculator().compute(surfaceSft: 900, coverageSftPerLitre: b),
    'paint.openingsSft': (b) => const PaintCalculator()
        .compute(surfaceSft: 900, coverageSftPerLitre: 110, openingsSft: b),
    'earthwork.lengthFt': (b) => const EarthworkCalculator()
        .compute(lengthFt: b, widthFt: 8, depthFt: 5, bulkingPercent: 25),
    'earthwork.bulkingPercent': (b) => const EarthworkCalculator()
        .compute(lengthFt: 10, widthFt: 8, depthFt: 5, bulkingPercent: b),
    'earthwork.truckCapacityCft': (b) => const EarthworkCalculator().compute(
        lengthFt: 10, widthFt: 8, depthFt: 5,
        bulkingPercent: 25, truckCapacityCft: b),
    'tiles.areaSft': (b) => const TileCalculator()
        .compute(areaSft: b, tileLengthIn: 24, tileWidthIn: 24),
    'tiles.tileLengthIn': (b) => const TileCalculator()
        .compute(areaSft: 120, tileLengthIn: b, tileWidthIn: 24),
    'tiles.wastagePercent': (b) => const TileCalculator().compute(
        areaSft: 120, tileLengthIn: 24, tileWidthIn: 24, wastagePercent: b),
    'shuttering.a': (b) => const ShutteringCalculator()
        .compute(element: ShutterElement.beam, a: b, b: 18, runFt: 20),
    'shuttering.runFt': (b) => const ShutteringCalculator()
        .compute(element: ShutterElement.beam, a: 10, b: 18, runFt: b),
    'brick_stack.lengthFt': (b) => const BrickStackCalculator()
        .fromStack(lengthFt: b, widthFt: 5, heightFt: 4),
    'brick_stack.gapPercent': (b) => const BrickStackCalculator()
        .fromStack(lengthFt: 10, widthFt: 5, heightFt: 4, gapPercent: b),
    'rod_delivery.orderedKg': (b) =>
        const RodDeliveryCalculator().expectedBars(orderedKg: b, diameterMm: 16),
    'rod_delivery.stockLengthFt': (b) => const RodDeliveryCalculator()
        .expectedBars(orderedKg: 1000, diameterMm: 16, stockLengthFt: b),
  };

  for (final bad in const [double.nan, double.infinity, double.negativeInfinity]) {
    test('no calculator answers with a number when given $bad', () {
      final answered = <String>[];
      entries.forEach((name, run) {
        try {
          final r = run(bad);
          for (final line in r.lines) {
            if (!line.value.isFinite) {
              answered.add('$name -> ${line.key} = ${line.value}');
            }
          }
        } on CalcException {
          // Refusing is the point.
        }
      });
      expect(answered, isEmpty,
          reason: 'these returned a number that is not a number:\n'
              '${answered.join('\n')}');
    });
  }

  test('land units refuse an area that is not a number', () {
    for (final bad in const [double.nan, double.infinity]) {
      expect(() => LandArea.of(bad, LandUnit.katha), throwsA(anything));
    }
  });
}
