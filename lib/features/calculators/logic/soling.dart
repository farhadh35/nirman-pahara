import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// Brick soling — the single layer of bricks laid flat under a floor slab or a
/// foundation to give the concrete a firm, level bed.
///
/// It is the cheapest layer in the building and the easiest to leave half done,
/// because within a day it is under concrete and nobody can count it again.
/// Counting bricks while they are still visible is the whole point of this
/// calculator.
class SolingCalculator {
  const SolingCalculator();

  /// Bricks in 100 square feet of flat soling.
  static const double bricksPer100Sft = 300.0;

  /// Bricks in 100 square feet of herringbone (হেরিং বোন) soling, which is laid
  /// on edge and so takes far more.
  static const double herringbonePer100Sft = 500.0;

  /// Sand filling the joints, in cubic feet per 100 square feet.
  static const double sandCftPer100Sft = 5.0;

  CalcResult compute({
    required double areaSft,
    bool herringbone = false,
    double wastagePercent = 5.0,
  }) {
    if (areaSft <= 0) {
      throw CalcException(L10nText(
        'ক্ষেত্রফল শূন্যের বড় হতে হবে।',
        'The area has to be greater than zero.',
      ));
    }
    if (wastagePercent < 0) {
      throw CalcException(L10nText(
        'অপচয় ঋণাত্মক হতে পারে না।',
        'Wastage cannot be negative.',
      ));
    }

    final rate = herringbone ? herringbonePer100Sft : bricksPer100Sft;
    final net = areaSft / 100.0 * rate;
    final gross = net * (1 + wastagePercent / 100.0);
    final sand = areaSft / 100.0 * sandCftPer100Sft;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'bricks',
          label: const L10nText('ইট লাগবে', 'Bricks needed'),
          value: gross,
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'bricks_net',
          label: const L10nText('অপচয় বাদে', 'Before wastage'),
          value: net,
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
        ),
        CalcLine(
          key: 'sand_cft',
          label: const L10nText('ফাঁক ভরাটের বালি', 'Sand to fill the joints'),
          value: sand,
          unit: const L10nText('ঘনফুট', 'cft'),
        ),
      ],
      formula: L10nText(
        'ইট = (ক্ষেত্রফল ÷ ১০০) × ${_fmt(rate)} = '
            '(${_fmt(areaSft)} ÷ ১০০) × ${_fmt(rate)} = ${_fmt(net)} টি, '
            'তার সঙ্গে ${_fmt(wastagePercent)}% অপচয়।',
        'Bricks = (area ÷ 100) × ${_fmt(rate)} = (${_fmt(areaSft)} ÷ 100) × '
            '${_fmt(rate)} = ${_fmt(net)}, plus ${_fmt(wastagePercent)}% for '
            'wastage.',
      ),
      assumptions: [
        L10nText(
          herringbone
              ? '১০০ বর্গফুট হেরিং বোন সলিংয়ে ${_fmt(rate)} টি ইট ধরা হয়েছে।'
              : '১০০ বর্গফুট ফ্ল্যাট সলিংয়ে ${_fmt(rate)} টি ইট ধরা হয়েছে।',
          herringbone
              ? '${_fmt(rate)} bricks per 100 square feet of herringbone soling.'
              : '${_fmt(rate)} bricks per 100 square feet of flat soling.',
        ),
        L10nText(
          'ফাঁক ভরাটে ১০০ বর্গফুটে ${_fmt(sandCftPer100Sft)} ঘনফুট বালি।',
          '${_fmt(sandCftPer100Sft)} cubic feet of sand per 100 square feet, to '
              'fill the joints.',
        ),
        const L10nText(
          'ইটের মাপ আর ফাঁকের চওড়ার উপর সংখ্যাটা কিছুটা এদিক-ওদিক হয়।',
          'Brick size and joint width move this figure a little either way.',
        ),
      ],
      note: const L10nText(
        'ঢালাই পড়ার আগেই গুনে নিন। একবার ঢেকে গেলে আর গোনা যায় না।',
        'Count it before the concrete goes on. Once it is covered it cannot be '
            'counted again.',
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
