import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';
import 'mix_ratio.dart';
import 'units.dart';

/// Materials for a nominal-ratio concrete pour.
///
/// Method: wet volume × dry factor = total dry (loose) volume, then split by
/// the ratio parts. This is the standard site and rate-analysis method; it
/// estimates what should arrive on site. It is not a mix design.
class ConcreteCalculator {
  const ConcreteCalculator({
    this.dryFactor = defaultDryFactor,
    this.wastagePercent = 0,
  });

  /// Loose (dry) material volume needed per unit of finished concrete. 1.54 is
  /// the conventional figure in PWD-style rate analysis for stone or brick-chip
  /// concrete. Exposed as an input because agencies use 1.50–1.57.
  static const double defaultDryFactor = 1.54;

  final double dryFactor;
  final double wastagePercent;

  CalcResult compute({
    required double volume,
    VolumeUnit unit = VolumeUnit.cft,
    MixRatio ratio = MixRatio.c1_2_4,
    double waterCementRatio = 0.45,
  }) {
    if (!volume.isFinite || volume <= 0) {
      throw CalcException(const L10nText(
        'ঢালাইয়ের পরিমাণ শূন্যের বেশি হতে হবে।',
        'The concrete volume must be greater than zero.',
      ));
    }
    if (ratio.isMortar) {
      throw CalcException(const L10nText(
        'কংক্রিটের অনুপাতে তিনটি অংশ লাগে, যেমন ১:২:৪।',
        'A concrete ratio needs three parts, e.g. 1:2:4.',
      ));
    }

    final wetCft = unit.toCft(volume);
    final dryCft = wetCft * dryFactor * (1 + wastagePercent / 100);

    final cementCft = dryCft * ratio.cement / ratio.sum;
    final sandCft = dryCft * ratio.sand / ratio.sum;
    final aggCft = dryCft * ratio.aggregate / ratio.sum;

    final bags = cementCft / Units.cftPerCementBag;
    final waterLitre = bags * Units.kgPerCementBag * waterCementRatio;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'cement_bags',
          label: const L10nText('সিমেন্ট', 'Cement'),
          value: bags,
          unit: U.bag,
          decimals: 1,
          emphasis: true,
        ),
        CalcLine(
          key: 'sand_cft',
          label: const L10nText('বালি', 'Sand'),
          value: sandCft,
          unit: U.cft,
          emphasis: true,
        ),
        CalcLine(
          key: 'aggregate_cft',
          label: const L10nText('খোয়া / পাথর', 'Khoa / stone chips'),
          value: aggCft,
          unit: U.cft,
          emphasis: true,
        ),
        CalcLine(
          key: 'water_litre',
          label: const L10nText('পানি (সর্বোচ্চ)', 'Water (maximum)'),
          value: waterLitre,
          unit: U.litre,
          decimals: 0,
        ),
        CalcLine(
          key: 'wet_cft',
          label: const L10nText('ঢালাইয়ের আয়তন', 'Finished concrete volume'),
          value: wetCft,
          unit: U.cft,
        ),
        CalcLine(
          key: 'dry_cft',
          label: const L10nText('শুকনা মালামাল মোট', 'Total dry material'),
          value: dryCft,
          unit: U.cft,
        ),
      ],
      formula: L10nText(
        'শুকনা আয়তন = ঢালাইয়ের আয়তন × $dryFactor\n'
            'প্রতিটি অংশ = শুকনা আয়তন × (অংশ ÷ ${MixRatio.fmt(ratio.sum)})\n'
            'সিমেন্ট ব্যাগ = সিমেন্টের ঘনফুট ÷ ${Units.cftPerCementBag}',
        'Dry volume = wet volume × $dryFactor\n'
            'Each part = dry volume × (part ÷ ${MixRatio.fmt(ratio.sum)})\n'
            'Cement bags = cement cft ÷ ${Units.cftPerCementBag}',
      ),
      assumptions: [
        L10nText(
          'অনুপাত ${ratio.label} (আয়তনের হিসাবে, ওজনে নয়)',
          'Ratio ${ratio.label}, by volume — not by weight',
        ),
        L10nText('শুকনা গুণক $dryFactor', 'Dry factor $dryFactor'),
        L10nText(
          '১ ব্যাগ সিমেন্ট = ৫০ কেজি = ${Units.cftPerCementBag} ঘনফুট',
          '1 cement bag = 50 kg = ${Units.cftPerCementBag} cft',
        ),
        L10nText(
          'পানি-সিমেন্ট অনুপাত $waterCementRatio',
          'Water-cement ratio $waterCementRatio',
        ),
        if (wastagePercent > 0)
          L10nText(
            'অপচয় ধরা হয়েছে $wastagePercent%',
            'Wastage allowed: $wastagePercent%',
          ),
      ],
      note: const L10nText(
        'এই হিসাব সাইটে কত মাল আসা উচিত তার একটি অনুমান। কংক্রিটের শক্তি '
            'নিশ্চিত করে সিলিন্ডার টেস্ট — অনুপাত নয়। BNBC 2020 অনুযায়ী কাঠামোগত '
            'কাজে শক্তি (f′c) দিয়ে কংক্রিট নির্ধারিত হয়।',
        'This estimates what should arrive on site. Strength is confirmed by a '
            'cylinder test, not by the ratio. Under BNBC 2020, structural '
            'concrete is specified by characteristic strength (f′c).',
      ),
    );
  }
}
