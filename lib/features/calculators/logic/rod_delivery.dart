import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';
import 'rebar.dart';

/// Checks a steel delivery: you buy rod by weight, it arrives as bars.
///
/// Steel is ordered in tonnes and delivered in a bundle nobody weighs. The one
/// check available on the day is arithmetic: a tonne of a given diameter is a
/// fixed number of bars of a given length, and bars can be counted from the
/// ground by anyone. A short delivery of two or three per cent survives a
/// glance and does not survive a count.
class RodDeliveryCalculator {
  const RodDeliveryCalculator({this.rebar = const RebarCalculator()});

  final RebarCalculator rebar;

  /// Bars expected for a weight ordered.
  CalcResult expectedBars({
    required double orderedKg,
    required double diameterMm,
    double stockLengthFt = 40,
  }) {
    if (!orderedKg.isFinite || orderedKg <= 0) {
      throw CalcException(const L10nText(
        'ওজন শূন্যের বড় একটি সংখ্যা হতে হবে।',
        'The weight has to be a real number greater than zero.',
      ));
    }
    if (!stockLengthFt.isFinite || stockLengthFt <= 0) {
      throw CalcException(const L10nText(
        'রডের দৈর্ঘ্য শূন্যের বড় একটি সংখ্যা হতে হবে।',
        'The bar length has to be a real number greater than zero.',
      ));
    }
    final perFoot = rebar.kgPerFoot(diameterMm);
    final perBar = perFoot * stockLengthFt;
    final bars = orderedKg / perBar;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'bars',
          label: const L10nText('যত পিস রড আসার কথা', 'Bars that should arrive'),
          value: bars,
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'kg_per_bar',
          label: L10nText('প্রতি পিসের ওজন (${_fmt(stockLengthFt)} ফুট)',
              'Weight of one bar (${_fmt(stockLengthFt)} ft)'),
          value: perBar,
          unit: U.kg,
        ),
        CalcLine(
          key: 'kg_per_foot',
          label: const L10nText('প্রতি ফুটে ওজন', 'Weight per foot'),
          value: perFoot,
          unit: U.kg,
          decimals: 3,
        ),
      ],
      formula: L10nText(
        'পিস = মোট ওজন ÷ (প্রতি ফুট ওজন × দৈর্ঘ্য) = ${_fmt(orderedKg)} ÷ '
            '(${perFoot.toStringAsFixed(3)} × ${_fmt(stockLengthFt)}) = '
            '${_fmt(bars)} টি।',
        'Bars = total weight ÷ (weight per foot × length) = ${_fmt(orderedKg)} '
            '÷ (${perFoot.toStringAsFixed(3)} × ${_fmt(stockLengthFt)}) = '
            '${_fmt(bars)}.',
      ),
      assumptions: [
        L10nText(
          'ওজন বের করা হয়েছে ব্যাস থেকেই — ${_fmt(diameterMm)} মিমি রডের '
              'প্রস্থচ্ছেদ × ইস্পাতের ঘনত্ব ${_fmt(rebar.steelDensityKgM3)} '
              'কেজি/ঘনমিটার।',
          'Weight is derived from the diameter: the cross-section of a '
              '${_fmt(diameterMm)} mm bar × steel density '
              '${_fmt(rebar.steelDensityKgM3)} kg/m³.',
        ),
        L10nText(
          'রডের দৈর্ঘ্য ${_fmt(stockLengthFt)} ফুট ধরা হয়েছে। বাজারে ২০ আর ৪০ '
              'ফুট — দুটোই চলে, তাই ডেলিভারির গায়ে দেখে নিন।',
          'Bar length taken as ${_fmt(stockLengthFt)} ft. Both 20 ft and 40 ft '
              'are sold, so check which arrived.',
        ),
        const L10nText(
          'এটি নামমাত্র ওজন। মিলের ছাড় থাকায় আসল ওজন কিছুটা কম-বেশি হয়।',
          'This is the nominal weight. Mill tolerance moves the real weight a '
              'little either way.',
        ),
      ],
      note: const L10nText(
        'গাড়ি খালি হওয়ার আগেই গুনুন। নামিয়ে সাইটে ছড়িয়ে গেলে আর গোনা যায় না।',
        'Count them before the truck is empty. Once they are spread around the '
            'site they cannot be counted.',
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
