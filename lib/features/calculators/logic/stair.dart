import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';
import 'units.dart';

/// Working a staircase out from the floor-to-floor height.
///
/// The riser is the vertical face of a step and the tread is the part you put
/// your foot on. They cannot be chosen freely: the number of risers has to
/// divide the floor height exactly, because the last step has to arrive at the
/// floor. Steps that are unequal — the usual result of not doing this
/// arithmetic — are what people fall down, and the offending step is nearly
/// always the first or the last.
///
/// A person can check a built stair with a tape in a minute: every riser the
/// same, every tread the same, and neither outside the range below.
class StairCalculator {
  const StairCalculator();

  /// A riser taller than this is hard work and, on a public stair, wrong.
  static const double maxRiserIn = 6.0;

  /// Less tread than this and a full adult foot does not land on the step.
  static const double minTreadIn = 10.0;

  /// Minimum clear width of a flight, in millimetres.
  static const double minFlightWidthMm = 1175.0;

  /// Handrail height above the nosing, in millimetres.
  static const double handrailHeightMm = 815.0;

  CalcResult compute({
    required double floorHeightFt,
    double? treadIn,
  }) {
    if (floorHeightFt <= 0) {
      throw CalcException(L10nText(
        'তলার উচ্চতা শূন্যের বড় হতে হবে।',
        'The floor-to-floor height has to be greater than zero.',
      ));
    }
    final tread = treadIn ?? minTreadIn;
    if (tread < minTreadIn) {
      throw CalcException(L10nText(
        'ট্রেড অন্তত ${minTreadIn.toStringAsFixed(0)} ইঞ্চি হতে হবে, নইলে পুরো পা '
            'ধাপে বসে না।',
        'A tread under ${minTreadIn.toStringAsFixed(0)} inches does not take a '
            'whole foot.',
      ));
    }

    final totalRiseIn = Units.footToInch(floorHeightFt);
    // Fewest risers that keeps every one of them within the limit. Rounding up
    // is what makes the steps equal: the height is fixed, so the count moves.
    final risers = (totalRiseIn / maxRiserIn).ceil();
    final riserIn = totalRiseIn / risers;
    final treads = risers - 1;
    final goingIn = treads * tread;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'risers',
          label: const L10nText('ধাপ (রাইজার) সংখ্যা', 'Number of risers'),
          value: risers.toDouble(),
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'riser_in',
          label: const L10nText('প্রতিটি রাইজারের উচ্চতা', 'Height of each riser'),
          value: riserIn,
          unit: const L10nText('ইঞ্চি', 'inch'),
          emphasis: true,
        ),
        CalcLine(
          key: 'treads',
          label: const L10nText('ট্রেড সংখ্যা', 'Number of treads'),
          value: treads.toDouble(),
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
        ),
        CalcLine(
          key: 'tread_in',
          label: const L10nText('প্রতিটি ট্রেডের গভীরতা', 'Depth of each tread'),
          value: tread,
          unit: const L10nText('ইঞ্চি', 'inch'),
        ),
        CalcLine(
          key: 'going_ft',
          label: const L10nText('সিঁড়ি যত জায়গা নেবে (দৈর্ঘ্যে)',
              'Floor length the flight takes'),
          value: Units.inchToFoot(goingIn),
          unit: const L10nText('ফুট', 'ft'),
        ),
      ],
      formula: L10nText(
        'রাইজার সংখ্যা = তলার উচ্চতা ÷ সর্বোচ্চ রাইজার, উপরে গোল করে = '
            '${_fmt(totalRiseIn)} ইঞ্চি ÷ ${_fmt(maxRiserIn)} = $risers। '
            'তারপর প্রতিটি রাইজার = ${_fmt(totalRiseIn)} ÷ $risers = '
            '${riserIn.toStringAsFixed(2)} ইঞ্চি। ট্রেড সবসময় রাইজারের চেয়ে একটি কম।',
        'Risers = floor height ÷ the riser limit, rounded up = '
            '${_fmt(totalRiseIn)} in ÷ ${_fmt(maxRiserIn)} = $risers. Then each '
            'riser = ${_fmt(totalRiseIn)} ÷ $risers = '
            '${riserIn.toStringAsFixed(2)} in. There is always one tread fewer '
            'than there are risers.',
      ),
      assumptions: [
        L10nText(
          'রাইজার সর্বোচ্চ ${_fmt(maxRiserIn)} ইঞ্চি, ট্রেড অন্তত '
              '${_fmt(minTreadIn)} ইঞ্চি ধরা হয়েছে।',
          'A riser is held to ${_fmt(maxRiserIn)} inches at most and a tread to '
              '${_fmt(minTreadIn)} inches at least.',
        ),
        const L10nText(
          'সব রাইজার সমান হতে হবে। উপরে গোল করা হয় ঠিক এই কারণেই — উচ্চতা তো '
              'বদলানো যায় না, সংখ্যাটাই বদলাতে হয়।',
          'Every riser has to be equal. Rounding the count up is what makes '
              'them so: the height cannot move, the number can.',
        ),
        L10nText(
          'সিঁড়ির চওড়া অন্তত ${_fmt(minFlightWidthMm)} মিমি এবং হ্যান্ডরেল '
              '${_fmt(handrailHeightMm)} মিমি উঁচু — এ দুটো আলাদা করে মেপে দেখবেন।',
          'The flight wants at least ${_fmt(minFlightWidthMm)} mm of clear '
              'width and a handrail ${_fmt(handrailHeightMm)} mm above the '
              'nosing. Both are separate things to measure.',
        ),
      ],
      note: const L10nText(
        'বানানো সিঁড়িতে সবচেয়ে আগে যেটা দেখবেন: প্রথম আর শেষ ধাপটা বাকিগুলোর সমান '
            'কি না। অসমান ধাপেই মানুষ পড়ে।',
        'The first thing to check on a built stair: whether the first and last '
            'steps match the rest. An odd step is what people fall on.',
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
