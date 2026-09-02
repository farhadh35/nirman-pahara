import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';
import 'mix_ratio.dart';
import 'units.dart';

/// Cement and sand for plaster.
class PlasterCalculator {
  const PlasterCalculator({
    this.dryFactor = defaultDryFactor,
    this.wastagePercent = 0,
  });

  /// Wet mortar to dry material volume.
  static const double defaultDryFactor = 1.30;

  final double dryFactor;
  final double wastagePercent;

  /// Thicknesses in common use, in inches.
  static const double innerWallIn = 0.5;
  static const double outerWallIn = 0.75;
  static const double ceilingIn = 0.375;

  CalcResult compute({
    required double area,
    AreaUnit areaUnit = AreaUnit.sft,
    double thicknessIn = innerWallIn,
    MixRatio mortar = MixRatio.m1_6,
  }) {
    if (!area.isFinite || area <= 0) {
      throw CalcException(const L10nText(
        'ক্ষেত্রফল শূন্যের বেশি হতে হবে।',
        'Area must be greater than zero.',
      ));
    }
    if (!thicknessIn.isFinite || thicknessIn <= 0) {
      throw CalcException(const L10nText(
        'পুরুত্ব শূন্যের বেশি হতে হবে।',
        'Thickness must be greater than zero.',
      ));
    }
    if (!mortar.isMortar) {
      throw CalcException(const L10nText(
        'প্লাস্টারের অনুপাতে দুটি অংশ লাগে, যেমন ১:৬।',
        'A plaster ratio needs two parts, e.g. 1:6.',
      ));
    }

    final sft = areaUnit.toSft(area);
    final wetCft = sft * Units.inchToFoot(thicknessIn);
    final dryCft = wetCft * dryFactor * (1 + wastagePercent / 100);
    final cementCft = dryCft * mortar.cement / mortar.sum;
    final sandCft = dryCft * mortar.sand / mortar.sum;
    final bags = cementCft / Units.cftPerCementBag;

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
          key: 'area_sft',
          label: const L10nText('প্লাস্টারের ক্ষেত্রফল', 'Plaster area'),
          value: sft,
          unit: U.sft,
        ),
        CalcLine(
          key: 'wet_cft',
          label: const L10nText('ভেজা মসলার আয়তন', 'Wet mortar volume'),
          value: wetCft,
          unit: U.cft,
        ),
      ],
      formula: L10nText(
        'ভেজা আয়তন = ক্ষেত্রফল × পুরুত্ব\n'
            'শুকনা আয়তন = ভেজা আয়তন × $dryFactor\n'
            'সিমেন্ট ও বালি = শুকনা আয়তন ভাগ করে অনুপাত অনুযায়ী',
        'Wet volume = area × thickness\n'
            'Dry volume = wet volume × $dryFactor\n'
            'Cement and sand = dry volume split by the ratio',
      ),
      assumptions: [
        L10nText('পুরুত্ব $thicknessIn″', 'Thickness $thicknessIn″'),
        L10nText('অনুপাত ${mortar.label}', 'Ratio ${mortar.label}'),
        L10nText('শুকনা গুণক $dryFactor', 'Dry factor $dryFactor'),
        L10nText(
          '১ ব্যাগ সিমেন্ট = ${Units.cftPerCementBag} ঘনফুট',
          '1 cement bag = ${Units.cftPerCementBag} cft',
        ),
      ],
      note: const L10nText(
        'প্লাস্টার করার পর অন্তত কয়েক দিন পানি দিতে হয়। পানি না দিলে উপরে ঠিক '
            'দেখালেও ফাটল ধরে।',
        'Plaster must be watered for several days after it is applied. Skip the '
            'curing and it will look fine at first, then crack.',
      ),
    );
  }
}
