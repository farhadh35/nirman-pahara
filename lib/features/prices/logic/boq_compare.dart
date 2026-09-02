import '../../../core/i18n/app_locale.dart';
import '../../calculators/logic/calc_result.dart';


/// Compares a rate written in a Bill of Quantities against the government
/// schedule rate for the same item.
///
/// This is the single most useful number a citizen can compute about a
/// contract, because the gap multiplies by the quantity: a small-looking
/// difference per cubic foot becomes lakhs across a slab. It is still a
/// question, not an accusation — schedules are revised, districts differ, and
/// non-scheduled items legitimately sit outside the book.
class BoqComparison {
  const BoqComparison();

  /// Difference beyond which the app suggests asking for the rate analysis.
  static const double questionThresholdPercent = 15;

  CalcResult compare({
    required L10nText itemLabel,
    required L10nText scheduleLabel,
    required L10nText unit,
    required double scheduleRate,
    required double boqRate,
    required double quantity,
    required AppLocale locale,
  }) {
    if (scheduleRate <= 0) {
      throw CalcException(const L10nText(
        'তফসিল রেট শূন্যের বেশি হতে হবে।',
        'The schedule rate must be greater than zero.',
      ));
    }
    if (boqRate <= 0) {
      throw CalcException(const L10nText(
        'BoQ-এর রেট শূন্যের বেশি হতে হবে।',
        'The BoQ rate must be greater than zero.',
      ));
    }
    if (quantity <= 0) {
      throw CalcException(const L10nText(
        'পরিমাণ শূন্যের বেশি হতে হবে।',
        'The quantity must be greater than zero.',
      ));
    }

    final diffPerUnit = boqRate - scheduleRate;
    final diffPercent = diffPerUnit / scheduleRate * 100;
    final unitLabel = unit.of(locale);

    return CalcResult(
      lines: [
        CalcLine(
          key: 'diff_percent',
          label: const L10nText(
            'তফসিল রেটের চেয়ে পার্থক্য',
            'Difference from the schedule rate',
          ),
          value: diffPercent,
          unit: U.percent,
          decimals: 1,
          emphasis: true,
        ),
        CalcLine(
          key: 'diff_total',
          label: L10nText(
            'পুরো পরিমাণে পার্থক্য',
            'Difference across the whole quantity',
          ),
          value: diffPerUnit * quantity,
          unit: U.taka,
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'boq_total',
          label: const L10nText('BoQ অনুযায়ী মোট', 'Total at the BoQ rate'),
          value: boqRate * quantity,
          unit: U.taka,
          decimals: 0,
        ),
        CalcLine(
          key: 'schedule_total',
          label: const L10nText(
            'তফসিল রেটে মোট',
            'Total at the schedule rate',
          ),
          value: scheduleRate * quantity,
          unit: U.taka,
          decimals: 0,
        ),
        CalcLine(
          key: 'diff_per_unit',
          label: L10nText(
            'প্রতি $unitLabel-এ পার্থক্য',
            'Difference per $unitLabel',
          ),
          value: diffPerUnit,
          unit: U.taka,
          decimals: 2,
        ),
      ],
      formula: const L10nText(
        'পার্থক্য % = (BoQ রেট − তফসিল রেট) ÷ তফসিল রেট × ১০০\n'
            'মোট পার্থক্য = (BoQ রেট − তফসিল রেট) × পরিমাণ',
        'Difference % = (BoQ rate − schedule rate) ÷ schedule rate × 100\n'
            'Total difference = (BoQ rate − schedule rate) × quantity',
      ),
      assumptions: [
        L10nText(
          'আইটেম: ${itemLabel.bn}',
          'Item: ${itemLabel.en ?? itemLabel.bn}',
        ),
        L10nText(
          'তফসিল: ${scheduleLabel.bn}',
          'Schedule: ${scheduleLabel.en ?? scheduleLabel.bn}',
        ),
        L10nText(
          'দুটো রেটই একই একক ($unitLabel) ও একই সংশোধনীর — এটা ধরে নেওয়া হয়েছে',
          'Both rates are assumed to be for the same unit ($unitLabel) and the '
              'same revision',
        ),
        const L10nText(
          'ভ্যাট ও আয়কর এখানে ধরা হয়নি',
          'VAT and income tax are not included here',
        ),
      ],
      note: _note(diffPercent, locale),
    );
  }

  L10nText _note(double diffPercent, AppLocale locale) {
    final abs = diffPercent.abs().toStringAsFixed(0);
    if (diffPercent > questionThresholdPercent) {
      return L10nText(
        'BoQ-এর রেট তফসিলের চেয়ে প্রায় $abs% বেশি। এটা অনিয়মের প্রমাণ নয় — '
            'দূরত্ব, নন-শিডিউল আইটেম বা নতুন সংশোধনীতেও রেট বাড়ে। কিন্তু এই '
            'পার্থক্যের ব্যাখ্যা চাওয়ার মতো: রেট অ্যানালাইসিসের কপি চান।',
        'The BoQ rate is about $abs% above the schedule. That is not proof of '
            'anything wrong — distance, a non-scheduled item or a newer revision '
            'all raise a rate legitimately. But it is worth an explanation: ask '
            'for the rate analysis.',
      );
    }
    if (diffPercent < -questionThresholdPercent) {
      return L10nText(
        'BoQ-এর রেট তফসিলের চেয়ে প্রায় $abs% কম। খুব কম দরে কাজ নিলে মালামালের মান '
            'কমানোর ঝুঁকি বাড়ে — কাজ চলার সময় মালামাল দেখা তখন বেশি জরুরি।',
        'The BoQ rate is about $abs% below the schedule. Work taken well under '
            'rate carries a real risk of thinner materials, so watching the '
            'deliveries matters more, not less.',
      );
    }
    return L10nText(
      'রেট দুটো কাছাকাছি (পার্থক্য $abs%)। এই মাত্রার পার্থক্য স্বাভাবিক।',
      'The two rates are close (a gap of $abs%). A difference this size is '
          'normal.',
    );
  }
}
