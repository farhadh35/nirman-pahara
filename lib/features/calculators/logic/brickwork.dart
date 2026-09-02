import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';
import 'mix_ratio.dart';
import 'units.dart';

/// Brick count and mortar for masonry.
///
/// Counts are derived from the actual brick size plus the mortar joint, not
/// from a remembered "bricks per cft" figure, because brick size and joint
/// thickness both vary in practice and both change the answer.
class BrickworkCalculator {
  const BrickworkCalculator({
    this.brickLengthIn = bdsBrickLengthIn,
    this.brickWidthIn = bdsBrickWidthIn,
    this.brickHeightIn = bdsBrickHeightIn,
    this.jointIn = defaultJointIn,
    this.mortarDryFactor = defaultMortarDryFactor,
    this.wastagePercent = 5,
  });

  /// Standard Bangladeshi burnt clay brick, 9.5" × 4.5" × 2.75".
  static const double bdsBrickLengthIn = 9.5;
  static const double bdsBrickWidthIn = 4.5;
  static const double bdsBrickHeightIn = 2.75;

  /// 10 mm joint ≈ 0.394 inch.
  static const double defaultJointIn = 0.394;

  /// Wet mortar to dry material volume.
  static const double defaultMortarDryFactor = 1.30;

  final double brickLengthIn;
  final double brickWidthIn;
  final double brickHeightIn;
  final double jointIn;
  final double mortarDryFactor;
  final double wastagePercent;

  /// Volume of one brick without mortar, in cft.
  double get brickVolumeCft =>
      (brickLengthIn * brickWidthIn * brickHeightIn) / 1728.0;

  /// Volume one brick occupies *including* its share of the joint, in cft.
  double get unitVolumeCft =>
      ((brickLengthIn + jointIn) *
          (brickWidthIn + jointIn) *
          (brickHeightIn + jointIn)) /
      1728.0;

  double get bricksPerCft => 1.0 / unitVolumeCft;

  CalcResult compute({
    required double lengthFt,
    required double heightFt,
    required double thicknessIn,
    MixRatio mortar = MixRatio.m1_6,
    double openingsSft = 0,
  }) {
    if (lengthFt <= 0 || heightFt <= 0) {
      throw CalcException(const L10nText(
        'দেয়ালের দৈর্ঘ্য ও উচ্চতা শূন্যের বেশি হতে হবে।',
        'Wall length and height must be greater than zero.',
      ));
    }
    if (thicknessIn <= 0) {
      throw CalcException(const L10nText(
        'দেয়ালের পুরুত্ব শূন্যের বেশি হতে হবে।',
        'Wall thickness must be greater than zero.',
      ));
    }
    if (!mortar.isMortar) {
      throw CalcException(const L10nText(
        'গাঁথুনির মসলার অনুপাতে দুটি অংশ লাগে, যেমন ১:৬।',
        'A mortar ratio needs two parts, e.g. 1:6.',
      ));
    }

    final netAreaSft = (lengthFt * heightFt) - openingsSft;
    if (netAreaSft <= 0) {
      throw CalcException(const L10nText(
        'দরজা-জানালা বাদ দিলে দেয়াল আর থাকে না — মাপ দেখুন।',
        'After deducting openings there is no wall left — check the figures.',
      ));
    }

    final wallCft = netAreaSft * Units.inchToFoot(thicknessIn);
    final netBricks = wallCft * bricksPerCft;
    final bricks = netBricks * (1 + wastagePercent / 100);

    final mortarWetCft = wallCft - (netBricks * brickVolumeCft);
    final mortarDryCft = mortarWetCft * mortarDryFactor;
    final cementCft = mortarDryCft * mortar.cement / mortar.sum;
    final sandCft = mortarDryCft * mortar.sand / mortar.sum;
    final bags = cementCft / Units.cftPerCementBag;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'bricks',
          label: const L10nText('ইট', 'Bricks'),
          value: bricks,
          unit: U.pieces,
          decimals: 0,
          emphasis: true,
        ),
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
          key: 'wall_cft',
          label: const L10nText('গাঁথুনির আয়তন', 'Masonry volume'),
          value: wallCft,
          unit: U.cft,
        ),
        CalcLine(
          key: 'net_area_sft',
          label: const L10nText('দেয়ালের ক্ষেত্রফল', 'Net wall area'),
          value: netAreaSft,
          unit: U.sft,
        ),
        CalcLine(
          key: 'bricks_per_cft',
          label: const L10nText('প্রতি ঘনফুটে ইট', 'Bricks per cft'),
          value: bricksPerCft,
          unit: U.pieces,
          decimals: 2,
        ),
      ],
      formula: L10nText(
        'গাঁথুনির আয়তন = ক্ষেত্রফল × পুরুত্ব\n'
            'ইট = আয়তন ÷ (এক ইট + জোড়ার আয়তন)\n'
            'মসলা = গাঁথুনির আয়তন − ইটের নিট আয়তন, তারপর × $mortarDryFactor',
        'Masonry volume = net area × thickness\n'
            'Bricks = volume ÷ (one brick + its joint)\n'
            'Mortar = masonry volume − net brick volume, then × $mortarDryFactor',
      ),
      assumptions: [
        L10nText(
          'ইটের মাপ $brickLengthIn″ × $brickWidthIn″ × $brickHeightIn″',
          'Brick size $brickLengthIn″ × $brickWidthIn″ × $brickHeightIn″',
        ),
        L10nText(
          'মসলার জোড়া ${jointIn.toStringAsFixed(2)}″ (≈১০ মিমি)',
          'Mortar joint ${jointIn.toStringAsFixed(2)}″ (≈10 mm)',
        ),
        L10nText('মসলার অনুপাত ${mortar.label}', 'Mortar ratio ${mortar.label}'),
        L10nText(
          'ইটের অপচয় $wastagePercent%',
          'Brick wastage $wastagePercent%',
        ),
        L10nText(
          '১ ব্যাগ সিমেন্ট = ${Units.cftPerCementBag} ঘনফুট',
          '1 cement bag = ${Units.cftPerCementBag} cft',
        ),
      ],
      note: const L10nText(
        'ইটের সংখ্যা ইটের মাপের ওপর নির্ভর করে। সাইটে তিনটি ইট মেপে দেখুন — '
            'মাপ ছোট হলে একই টাকায় কম গাঁথুনি হবে।',
        'The count depends on the brick size. Measure three bricks on site: '
            'undersized bricks mean less masonry for the same money.',
      ),
    );
  }
}
