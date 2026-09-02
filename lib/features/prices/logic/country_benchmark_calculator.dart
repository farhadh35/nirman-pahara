import '../../../core/i18n/app_locale.dart';
import '../../calculators/logic/calc_result.dart';
import 'price_models.dart';

/// One country's figure lined up against the work in front of the user.
class BenchmarkComparison {
  const BenchmarkComparison({
    required this.benchmark,
    required this.multipleLow,
    required this.multipleHigh,
  });

  final CountryBenchmark benchmark;

  /// How many times the benchmark the user's figure is, measured against the
  /// benchmark's high and low ends. Two numbers, because the benchmark is a
  /// range and collapsing it to one would overstate the precision.
  final double multipleLow;
  final double multipleHigh;

  double get multipleMid => (multipleLow + multipleHigh) / 2;
}

/// Compares a Bangladeshi project's unit cost with published figures from other
/// countries.
///
/// This screen is the easiest one in the app to misuse, so it is built to
/// resist that. It never returns a bare multiple: every result carries the
/// exchange rate used, the year of each figure, and the comparability warning
/// attached to each benchmark. Costs move with terrain, land acquisition,
/// utility shifting, structures, specification and the year — a road across a
/// delta is not a road across a plain.
class CountryBenchmarkCalculator {
  const CountryBenchmarkCalculator();

  ComparisonResult compare({
    required BenchmarkItem item,
    required double projectCostBdt,
    required double quantity,
    required double usdToBdt,
    required String fxAsOf,
  }) {
    if (projectCostBdt <= 0) {
      throw CalcException(const L10nText(
        'প্রকল্পের খরচ শূন্যের বেশি হতে হবে।',
        'The project cost must be greater than zero.',
      ));
    }
    if (quantity <= 0) {
      throw CalcException(const L10nText(
        'পরিমাণ শূন্যের বেশি হতে হবে।',
        'The quantity must be greater than zero.',
      ));
    }
    if (usdToBdt <= 0) {
      throw CalcException(const L10nText(
        'ডলারের বিনিময় হার শূন্যের বেশি হতে হবে।',
        'The exchange rate must be greater than zero.',
      ));
    }
    if (item.benchmarks.isEmpty) {
      throw CalcException(const L10nText(
        'তুলনার জন্য কোনো তথ্য নেই।',
        'There is nothing to compare against.',
      ));
    }

    final perUnitBdt = projectCostBdt / quantity;
    final perUnitUsd = perUnitBdt / usdToBdt;

    final comparisons = [
      for (final b in item.benchmarks)
        BenchmarkComparison(
          benchmark: b,
          multipleLow: perUnitUsd / b.highUsd,
          multipleHigh: perUnitUsd / b.lowUsd,
        )
    ]..sort((a, b) => a.multipleMid.compareTo(b.multipleMid));

    return ComparisonResult(
      perUnitBdt: perUnitBdt,
      perUnitUsd: perUnitUsd,
      usdToBdt: usdToBdt,
      fxAsOf: fxAsOf,
      item: item,
      comparisons: comparisons,
      caveats: _caveats(item, fxAsOf),
    );
  }

  List<L10nText> _caveats(BenchmarkItem item, String fxAsOf) => [
        const L10nText(
          'দেশে দেশে খরচের তুলনা কখনোই সরাসরি হয় না। জমি অধিগ্রহণ, ইউটিলিটি সরানো, '
              'সেতু-কালভার্ট, মাটির ধরন আর স্পেসিফিকেশন — সবই খরচ বদলে দেয়।',
          'Cross-country cost comparisons are never like for like. Land '
              'acquisition, utility shifting, bridges and culverts, ground '
              'conditions and specification all move the figure.',
        ),
        const L10nText(
          'প্রকাশিত সংখ্যাগুলোতে জমির দাম ধরা আছে কি না, তা প্রায়ই স্পষ্ট নয়। '
              'বাংলাদেশে জমির দাম ও ঘনবসতি খরচের বড় অংশ।',
          'Whether a published figure includes the price of land is often '
              'unclear, and in Bangladesh land price and population density are a '
              'large part of the cost.',
        ),
        if (item.spansYears)
          L10nText(
            'এই তুলনার সংখ্যাগুলো আলাদা বছরের '
                '(${item.years.join(', ')}) — মূল্যস্ফীতির হিসাব এখানে করা হয়নি।',
            'These figures come from different years '
                '(${item.years.join(', ')}); no inflation adjustment has been '
                'applied.',
          ),
        if (item.hasUndatedFigures)
          const L10nText(
            'কিছু সংখ্যার সাল এখনো নিশ্চিত করা যায়নি। পুরোনো সংখ্যার সঙ্গে আজকের '
                'খরচ মেলালে ব্যবধান বড় দেখায়।',
            'The year behind some of these figures is not yet confirmed. Lining '
                'an older figure up against today\'s cost makes the gap look '
                'bigger than it is.',
          ),
        L10nText(
          'ডলারের হিসাব $fxAsOf তারিখের বিনিময় হারে — হার বদলালে গুণিতকও বদলাবে।',
          'Dollar figures use the exchange rate as of $fxAsOf; a different rate '
              'changes every multiple on this screen.',
        ),
        const L10nText(
          'বেশি খরচ মানেই দুর্নীতি নয়, আর কম খরচ মানেই সততা নয়। এই পর্দা প্রশ্ন '
              'তোলার জন্য, রায় দেওয়ার জন্য নয়।',
          'A higher cost is not proof of corruption, and a lower one is not proof '
              'of honesty. This screen is for asking a question, not for reaching '
              'a verdict.',
        ),
      ];
}

/// The full output of a cross-country comparison.
class ComparisonResult {
  const ComparisonResult({
    required this.perUnitBdt,
    required this.perUnitUsd,
    required this.usdToBdt,
    required this.fxAsOf,
    required this.item,
    required this.comparisons,
    required this.caveats,
  });

  final double perUnitBdt;
  final double perUnitUsd;
  final double usdToBdt;
  final String fxAsOf;
  final BenchmarkItem item;

  /// Cheapest benchmark first.
  final List<BenchmarkComparison> comparisons;

  /// Always non-empty. The UI must render these next to the numbers, not behind
  /// a tap.
  final List<L10nText> caveats;

  /// The widest and narrowest multiples across all benchmarks, which is the
  /// honest way to state the headline: "somewhere between x and y times".
  double get lowestMultiple =>
      comparisons.map((c) => c.multipleLow).reduce((a, b) => a < b ? a : b);

  double get highestMultiple =>
      comparisons.map((c) => c.multipleHigh).reduce((a, b) => a > b ? a : b);
}
