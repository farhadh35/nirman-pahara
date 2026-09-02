import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// Sizing the two water tanks a house needs, and the septic tank it needs after.
///
/// The underground reservoir holds what the mains delivers when it delivers;
/// the overhead tank is what runs the taps. Both are sized off the same thing —
/// how many people live there — and both are routinely built to whatever size
/// the mason has shuttering for, which is how a household ends up out of water
/// every afternoon.
class WaterStoreCalculator {
  const WaterStoreCalculator();

  /// Imperial gallons in a cubic foot.
  static const double gallonsPerCft = 6.25;

  /// The floor the app sizes against. People use more than this; a tank built
  /// for less than this runs dry.
  static const double minLitresPerPersonPerDay = 10 * 4.546;

  /// Minimum gallons per person per day.
  static const double minGallonsPerPersonPerDay = 10.0;

  /// Days of supply each tank is expected to carry.
  static const double reservoirDays = 2.0;
  static const double overheadDays = 1.0;

  /// Clear height the tank sits above the roof slab, in feet.
  static const double overheadClearFt = 1.5;

  CalcResult compute({
    required int people,
    double gallonsPerPersonPerDay = minGallonsPerPersonPerDay,
  }) {
    if (people < 1) {
      throw CalcException(L10nText(
        'অন্তত একজন ধরতে হবে।',
        'Count at least one person.',
      ));
    }
    if (gallonsPerPersonPerDay <= 0) {
      throw CalcException(L10nText(
        'দৈনিক পানির হিসাব শূন্যের বড় হতে হবে।',
        'Daily water per person has to be greater than zero.',
      ));
    }

    final perDayGal = people * gallonsPerPersonPerDay;
    final reservoirGal = perDayGal * reservoirDays;
    final overheadGal = perDayGal * overheadDays;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'daily_gal',
          label: const L10nText('দিনে মোট পানি লাগবে', 'Water needed per day'),
          value: perDayGal,
          unit: const L10nText('গ্যালন', 'gallons'),
          decimals: 0,
        ),
        CalcLine(
          key: 'reservoir_gal',
          label: const L10nText('মাটির নিচের রিজার্ভার', 'Underground reservoir'),
          value: reservoirGal,
          unit: const L10nText('গ্যালন', 'gallons'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'reservoir_cft',
          label: const L10nText('রিজার্ভারের আয়তন', 'Reservoir volume'),
          value: reservoirGal / gallonsPerCft,
          unit: const L10nText('ঘনফুট', 'cft'),
          emphasis: true,
        ),
        CalcLine(
          key: 'overhead_gal',
          label: const L10nText('ছাদের ট্যাংক', 'Overhead tank'),
          value: overheadGal,
          unit: const L10nText('গ্যালন', 'gallons'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'overhead_cft',
          label: const L10nText('ছাদের ট্যাংকের আয়তন', 'Overhead tank volume'),
          value: overheadGal / gallonsPerCft,
          unit: const L10nText('ঘনফুট', 'cft'),
        ),
      ],
      formula: L10nText(
        'দিনের পানি = $people জন × ${_fmt(gallonsPerPersonPerDay)} গ্যালন = '
            '${_fmt(perDayGal)} গ্যালন। রিজার্ভার ${_fmt(reservoirDays)} দিনের, '
            'ছাদের ট্যাংক ${_fmt(overheadDays)} দিনের। '
            '১ ঘনফুট = ${_fmt(gallonsPerCft)} গ্যালন।',
        'Daily water = $people people × ${_fmt(gallonsPerPersonPerDay)} gallons '
            '= ${_fmt(perDayGal)} gallons. The reservoir carries '
            '${_fmt(reservoirDays)} days and the roof tank '
            '${_fmt(overheadDays)}. One cubic foot holds '
            '${_fmt(gallonsPerCft)} gallons.',
      ),
      assumptions: [
        L10nText(
          'জনপ্রতি দিনে ${_fmt(gallonsPerPersonPerDay)} গ্যালন ধরা হয়েছে — এটা '
              'সবচেয়ে কম হিসাব, গড় খরচ নয়।',
          'Taken at ${_fmt(gallonsPerPersonPerDay)} gallons per person per day, '
              'which is a floor and not an average.',
        ),
        L10nText(
          'ছাদের ট্যাংক স্ল্যাব থেকে অন্তত ${_fmt(overheadClearFt)} ফুট উঁচুতে '
              'বসানোর কথা, নইলে নিচের তলায় চাপ পাওয়া যায় না।',
          'The roof tank wants at least ${_fmt(overheadClearFt)} ft of clear '
              'height over the slab, or the floors below get no pressure.',
        ),
        const L10nText(
          'রিজার্ভার আর ছাদের ট্যাংক আলাদা দুটো জিনিস। একটা দিয়ে অন্যটার কাজ চলে না।',
          'The reservoir and the roof tank are two different things; one does '
              'not do the other\'s job.',
        ),
      ],
    );
  }

  /// Septic tank sizes as published, by the number of users they serve.
  ///
  /// A discrete table, and it stays discrete: interpolating between the printed
  /// sizes would be inventing a tank nobody specified. For a user count between
  /// two rows the next size up is returned, and the result says so.
  static const List<SepticSize> septicSizes = [
    SepticSize(users: 10, lengthFt: 6, widthFt: 2, depthFt: 3.5),
    SepticSize(users: 30, lengthFt: 9, widthFt: 2, depthFt: 4.5),
    SepticSize(users: 100, lengthFt: 11, widthFt: 6, depthFt: 5.83),
    SepticSize(users: 200, lengthFt: 22, widthFt: 6, depthFt: 7.17),
  ];

  /// The published size that covers [users], or null when there are more users
  /// than the table goes up to — at which point it is an engineer's problem.
  SepticSize? septicFor(int users) {
    for (final s in septicSizes) {
      if (users <= s.users) return s;
    }
    return null;
  }
}

class SepticSize {
  const SepticSize({
    required this.users,
    required this.lengthFt,
    required this.widthFt,
    required this.depthFt,
  });

  /// The largest number of users this size is published for.
  final int users;
  final double lengthFt;
  final double widthFt;
  final double depthFt;

  double get volumeCft => lengthFt * widthFt * depthFt;

  L10nText get label => L10nText(
        '${_f(lengthFt)} × ${_f(widthFt)} × ${_f(depthFt)} ফুট',
        '${_f(lengthFt)} × ${_f(widthFt)} × ${_f(depthFt)} ft',
      );

  static String _f(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
