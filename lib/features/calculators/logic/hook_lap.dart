import '../../../core/i18n/app_locale.dart';
import '../../measure/logic/sutas.dart';
import 'calc_result.dart';
import 'units.dart';

/// Hook length at the end of a reinforcing bar, and what the app will and will
/// not say about laps.
///
/// A hook is the bend at a bar's end that stops it pulling out of the concrete.
/// Its length follows the bar: twelve diameters is the figure used throughout
/// Bangladeshi practice, and it is arithmetic anyone can repeat with a tape.
///
/// A lap is different in kind, and the app deliberately refuses to give a
/// number for it. How long a splice must be depends on the concrete grade, the
/// steel grade, the bar's position in the pour and whether the bars are in
/// tension or compression, and there are places in a member where a lap is not
/// permitted at all. A single figure printed here would be used as permission.
/// The card already shipping in the guide says lap length is set by rule and
/// not by eye; this calculator says the same thing and stops.
class HookLapCalculator {
  const HookLapCalculator();

  /// Hook length as a multiple of the bar diameter.
  static const double hookMultiple = 12.0;

  /// Hook length for a bar of [diameterMm].
  CalcResult hook({required double diameterMm, required int count}) {
    if (diameterMm <= 0) {
      throw CalcException(L10nText(
        'রডের ব্যাস শূন্যের বড় হতে হবে।',
        'The bar diameter has to be greater than zero.',
      ));
    }
    if (count < 1) {
      throw CalcException(L10nText(
        'অন্তত একটি হুক ধরতে হবে।',
        'Count at least one hook.',
      ));
    }

    final oneMm = diameterMm * hookMultiple;
    final suta = SutaSize.forMm(diameterMm.round());

    return CalcResult(
      lines: [
        CalcLine(
          key: 'hook_mm',
          label: const L10nText('একটি হুকের দৈর্ঘ্য', 'Length of one hook'),
          value: oneMm,
          unit: const L10nText('মিমি', 'mm'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'hook_in',
          label: const L10nText('একটি হুক, ইঞ্চিতে', 'One hook, in inches'),
          value: Units.mmToInch(oneMm),
          unit: const L10nText('ইঞ্চি', 'inch'),
        ),
        CalcLine(
          key: 'total_mm',
          label: L10nText('$count টি হুকে মোট রড', 'Bar used by $count hooks'),
          value: oneMm * count,
          unit: const L10nText('মিমি', 'mm'),
          decimals: 0,
        ),
        CalcLine(
          key: 'total_ft',
          label: const L10nText('মোট, ফুটে', 'Total, in feet'),
          value: Units.inchToFoot(Units.mmToInch(oneMm * count)),
          unit: const L10nText('ফুট', 'ft'),
        ),
      ],
      formula: L10nText(
        'হুকের দৈর্ঘ্য = ১২ × রডের ব্যাস = ১২ × ${_fmt(diameterMm)} মিমি',
        'Hook length = 12 × bar diameter = 12 × ${_fmt(diameterMm)} mm',
      ),
      assumptions: [
        const L10nText(
          'হুকের দৈর্ঘ্য রডের ব্যাসের ১২ গুণ ধরা হয়েছে।',
          'The hook is taken as twelve bar diameters.',
        ),
        if (suta != null)
          L10nText(
            '${suta.suta} সুতা রড = ${suta.nominalMm} মিমি, দোকানে এই নামেই চাইবেন।',
            '${suta.suta} suta is the ${suta.nominalMm} mm bar, which is what '
                'the shop will call it.',
          ),
        const L10nText(
          'ছাপা তালিকায় সংখ্যাগুলো গোল করে লেখা থাকে — যেমন ১২ মিমি রডে ১৪৪-এর '
              'বদলে ১৫০ মিমি। গোল করা মানে বেশি, কম নয়।',
          'Printed tables round these up: a 12 mm bar is listed at 150 mm '
              'rather than the 144 mm the rule gives. Rounding goes up, never '
              'down.',
        ),
      ],
    );
  }

  /// Deliberately not a number.
  ///
  /// Returned instead of a lap length so the screen has something honest to
  /// show where a figure would otherwise sit.
  static const L10nText lapRefusal = L10nText(
    'ল্যাপের দৈর্ঘ্য এই অ্যাপ বলবে না। কত লম্বা ল্যাপ লাগবে সেটা কংক্রিটের গ্রেড, '
        'রডের গ্রেড আর রডটা কোথায় বসছে তার উপর নির্ভর করে, আর কিছু জায়গায় ল্যাপ '
        'দেওয়াই যায় না। নকশায় কত লেখা আছে দেখুন, আর সেটাই ফিতে দিয়ে মিলিয়ে নিন।',
    'This app will not give you a lap length. How long a splice must be '
        'depends on the concrete grade, the steel grade and where in the member '
        'the bar sits, and there are places a lap is not allowed at all. Find '
        'the figure on the drawing, then measure against that.',
  );

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
