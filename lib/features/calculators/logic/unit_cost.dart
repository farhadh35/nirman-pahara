import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// What the signboard implies per unit of work.
///
/// Turns "চুক্তিমূল্য ৳৪২,৫০,০০০, দৈর্ঘ্য ১,২০০ মিটার" off a site signboard into
/// a per-metre figure someone can hold in their head and compare with other
/// works and with the published schedule of rates.
///
/// It is an indicative comparison, never a finding of wrongdoing: carrying
/// distance, soil, structures and the rate revision in force all legitimately
/// move the number.
class UnitCostCalculator {
  const UnitCostCalculator();

  /// VAT on works in the PWD Schedule of Rates 2022 (2nd revised) is 10%.
  static const double defaultVatPercent = 10.0;

  CalcResult compute({
    required double contractValue,
    required double quantity,
    required L10nText quantityUnit,
    double vatPercent = defaultVatPercent,
    double incomeTaxPercent = 0,
    double? comparisonRate,
  }) {
    if (contractValue <= 0) {
      throw CalcException(const L10nText(
        'চুক্তিমূল্য শূন্যের বেশি হতে হবে।',
        'Contract value must be greater than zero.',
      ));
    }
    if (quantity <= 0) {
      throw CalcException(const L10nText(
        'কাজের পরিমাণ শূন্যের বেশি হতে হবে।',
        'Work quantity must be greater than zero.',
      ));
    }

    final deductionPercent = vatPercent + incomeTaxPercent;
    final netToContractor = contractValue * (1 - deductionPercent / 100);
    final grossRate = contractValue / quantity;
    final netRate = netToContractor / quantity;
    final unitBn = quantityUnit.bn;
    final unitEn = quantityUnit.en ?? quantityUnit.bn;

    final lines = <CalcLine>[
      CalcLine(
        key: 'gross_rate',
        // Parenthesised rather than inflected: Bangla case endings differ per
        // noun, and the unit list is open-ended.
        label: L10nText(
          'চুক্তিমূল্য (প্রতি $unitBn)',
          'Contract value per $unitEn',
        ),
        value: grossRate,
        unit: U.taka,
        decimals: 0,
        emphasis: true,
      ),
      CalcLine(
        key: 'net_rate',
        label: L10nText(
          'ভ্যাট-আয়কর বাদে (প্রতি $unitBn)',
          'Per $unitEn after VAT and income tax',
        ),
        value: netRate,
        unit: U.taka,
        decimals: 0,
      ),
      CalcLine(
        key: 'deduction',
        label: const L10nText(
          'সরকারি কর্তন (ভ্যাট + আয়কর)',
          'Government deduction (VAT + income tax)',
        ),
        value: contractValue - netToContractor,
        unit: U.taka,
        decimals: 0,
      ),
      CalcLine(
        key: 'net_value',
        label: const L10nText(
          'ঠিকাদার হাতে পাবেন (আনুমানিক)',
          'Contractor receives (approximate)',
        ),
        value: netToContractor,
        unit: U.taka,
        decimals: 0,
      ),
    ];

    L10nText? note;
    if (comparisonRate != null && comparisonRate > 0) {
      final diffPercent = (grossRate - comparisonRate) / comparisonRate * 100;
      lines.add(CalcLine(
        key: 'diff_percent',
        label: const L10nText(
          'তুলনামূলক রেটের চেয়ে পার্থক্য',
          'Difference from the comparison rate',
        ),
        value: diffPercent,
        unit: U.percent,
        decimals: 1,
        emphasis: true,
      ));
      note = _bandNote(diffPercent);
    }

    return CalcResult(
      lines: lines,
      formula: const L10nText(
        'প্রতি একক রেট = চুক্তিমূল্য ÷ কাজের পরিমাণ\n'
            'কর্তন = চুক্তিমূল্য × (ভ্যাট% + আয়কর%)',
        'Unit rate = contract value ÷ work quantity\n'
            'Deduction = contract value × (VAT% + income tax%)',
      ),
      assumptions: [
        L10nText(
          'ভ্যাট $vatPercent% ধরা হয়েছে (PWD SoR 2022, ২য় সংশোধিত)',
          'VAT taken as $vatPercent% (PWD SoR 2022, 2nd revised)',
        ),
        if (incomeTaxPercent > 0)
          L10nText(
            'উৎসে আয়কর $incomeTaxPercent% ধরা হয়েছে',
            'Income tax at source taken as $incomeTaxPercent%',
          ),
        const L10nText(
          'সাইনবোর্ডে লেখা পরিমাণ ও মূল্য সঠিক ধরে নেওয়া হয়েছে',
          'The quantity and value on the signboard are assumed correct',
        ),
      ],
      note: note ??
          const L10nText(
            'এই সংখ্যা শুধু তুলনার জন্য। মাটির ধরন, মাল টানার দূরত্ব, কালভার্ট — '
                'সবই রেট বাড়ায়-কমায়। বেশি মনে হলে অভিযোগ নয়, আগে অনুমিত হিসাব '
                '(estimate) ও BoQ চেয়ে নিন।',
            'This number is for comparison only. Soil, carrying distance and '
                'structures all move the rate legitimately. If it looks high, do '
                'not complain first — ask for the estimate and the BoQ.',
          ),
    );
  }

  L10nText _bandNote(double diffPercent) {
    final abs = diffPercent.abs().toStringAsFixed(0);
    if (diffPercent > 25) {
      return L10nText(
        'তুলনার রেটের চেয়ে প্রায় $abs% বেশি। এটা অনিয়মের প্রমাণ নয় — কিন্তু '
            'অনুমিত হিসাব ও BoQ দেখে কারণ জানার মতো পার্থক্য।',
        'About $abs% above the comparison rate. That is not proof of anything '
            'wrong — but it is a gap worth asking the estimate and BoQ about.',
      );
    }
    if (diffPercent < -25) {
      return L10nText(
        'তুলনার রেটের চেয়ে প্রায় $abs% কম। খুব কম দরে কাজ নিলে মালের মান কমানোর '
            'ঝুঁকি থাকে — কাজ চলার সময় মাল দেখা বেশি জরুরি।',
        'About $abs% below the comparison rate. Work taken at a very low rate '
            'carries a risk of thinner materials — watch the deliveries closely.',
      );
    }
    return L10nText(
      'তুলনার রেটের কাছাকাছি (পার্থক্য $abs%)। এই মাত্রার পার্থক্য সাইটের '
          'অবস্থার কারণেই হতে পারে।',
      'Close to the comparison rate (a gap of $abs%). Site conditions alone can '
          'explain a difference this size.',
    );
  }
}
