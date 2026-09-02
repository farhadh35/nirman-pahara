import 'dart:math' as math;

import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';
import 'units.dart';

/// Rod (reinforcement bar) weight and count.
///
/// Weight is derived from the nominal diameter and steel density rather than
/// read off a memorised table, so the app can show the derivation. The familiar
/// site shortcut "d² ÷ ১৬২" falls out of the same formula.
class RebarCalculator {
  const RebarCalculator({this.steelDensityKgM3 = 7850});

  /// Nominal density of reinforcing steel.
  final double steelDensityKgM3;

  /// Diameters commonly sold in Bangladesh, in mm.
  ///
  /// The one list. A second copy lived in the hook calculator and the two had
  /// already drifted — that one carried the 6 mm bar and this did not, so the
  /// same app disagreed with itself about what the trade sells.
  static const List<int> commonDiametersMm = [
    6, 8, 10, 12, 16, 20, 22, 25, 28, 32,
  ];

  /// Commercial rod lengths sold in Bangladesh, in feet.
  static const List<int> commonStockLengthsFt = [20, 40];

  double kgPerMetre(double diameterMm) {
    if (diameterMm <= 0) {
      throw CalcException(const L10nText(
        'রডের ব্যাস শূন্যের বেশি হতে হবে।',
        'Bar diameter must be greater than zero.',
      ));
    }
    final areaM2 = math.pi * math.pow(diameterMm / 1000.0, 2) / 4.0;
    return areaM2 * steelDensityKgM3;
  }

  double kgPerFoot(double diameterMm) =>
      kgPerMetre(diameterMm) * Units.mPerFoot;

  /// The divisor in the site shortcut `d² ÷ K` for kg per metre.
  double get shortcutDivisor => 1.0 / (math.pi / 4.0 * steelDensityKgM3 / 1e6);

  CalcResult compute({
    required double diameterMm,
    required double length,
    LengthUnit lengthUnit = LengthUnit.foot,
    int pieces = 1,
    double wastagePercent = 0,
  }) {
    if (pieces <= 0) {
      throw CalcException(const L10nText(
        'রডের সংখ্যা কমপক্ষে ১ হতে হবে।',
        'The number of bars must be at least 1.',
      ));
    }
    if (length <= 0) {
      throw CalcException(const L10nText(
        'রডের দৈর্ঘ্য শূন্যের বেশি হতে হবে।',
        'Bar length must be greater than zero.',
      ));
    }

    final metres = lengthUnit.toMetres(length);
    final perM = kgPerMetre(diameterMm);
    final totalKg = perM * metres * pieces * (1 + wastagePercent / 100);
    final totalFt = Units.mToFoot(metres) * pieces;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'total_kg',
          label: const L10nText('মোট ওজন', 'Total weight'),
          value: totalKg,
          unit: U.kg,
          emphasis: true,
        ),
        CalcLine(
          key: 'total_ton',
          label: const L10nText('মোট ওজন', 'Total weight'),
          value: totalKg / 1000.0,
          unit: U.ton,
          decimals: 3,
        ),
        CalcLine(
          key: 'kg_per_m',
          label: const L10nText('প্রতি মিটারে ওজন', 'Weight per metre'),
          value: perM,
          unit: U.kg,
          decimals: 3,
        ),
        CalcLine(
          key: 'kg_per_ft',
          label: const L10nText('প্রতি ফুটে ওজন', 'Weight per foot'),
          value: kgPerFoot(diameterMm),
          unit: U.kg,
          decimals: 3,
        ),
        CalcLine(
          key: 'total_length_ft',
          label: const L10nText('মোট দৈর্ঘ্য', 'Total length'),
          value: totalFt,
          unit: U.ft,
          decimals: 1,
        ),
      ],
      formula: L10nText(
        'প্রতি মিটারে ওজন = π ÷ ৪ × ব্যাস² × ইস্পাতের ঘনত্ব\n'
            'সহজ নিয়ম: ব্যাস (মিমি)² ÷ ${shortcutDivisor.toStringAsFixed(0)} '
            '= প্রতি মিটারে কেজি\n'
            'মোট ওজন = প্রতি মিটারে ওজন × দৈর্ঘ্য (মিটার) × সংখ্যা',
        'Weight per metre = π ÷ 4 × diameter² × steel density\n'
            'Shortcut: diameter (mm)² ÷ ${shortcutDivisor.toStringAsFixed(0)} '
            '= kg per metre\n'
            'Total = weight per metre × length (m) × number of bars',
      ),
      assumptions: [
        L10nText(
          'ইস্পাতের ঘনত্ব ${steelDensityKgM3.toStringAsFixed(0)} কেজি/ঘনমিটার',
          'Steel density ${steelDensityKgM3.toStringAsFixed(0)} kg/m³',
        ),
        const L10nText(
          'নামমাত্র (nominal) ব্যাস ধরা হয়েছে — মরিচা বা ক্ষয় বাদ',
          'Nominal diameter assumed — rust and rolling loss excluded',
        ),
        if (wastagePercent > 0)
          L10nText(
            'অপচয় ধরা হয়েছে $wastagePercent%',
            'Wastage allowed: $wastagePercent%',
          ),
      ],
      note: const L10nText(
        'ওজন ঠিক থাকলেই রড ঠিক নয়। রডের গায়ে গ্রেড লেখা আছে কি না, পাঁজর (rib) '
            'স্পষ্ট কি না, আর কাগজে যে গ্রেড লেখা সেটাই এসেছে কি না — তিনটিই '
            'মিলিয়ে দেখুন।',
        'Correct weight alone does not mean correct steel. Check three things: '
            'the grade rolled onto the bar, whether the ribs are sharp, and '
            'whether the grade delivered matches the grade on the paperwork.',
      ),
    );
  }

  /// How many pieces of a given stock length make one metric tonne.
  double piecesPerTon(double diameterMm, {int stockLengthFt = 20}) {
    final perPiece = kgPerFoot(diameterMm) * stockLengthFt;
    if (perPiece <= 0) {
      throw CalcException(
        const L10nText('হিসাব করা যায়নি।', 'Could not calculate.'),
      );
    }
    return 1000.0 / perPiece;
  }
}
