import '../../../core/i18n/app_locale.dart';
import 'brickwork.dart';
import 'calc_result.dart';

/// Counts a delivered stack of bricks without counting every brick.
///
/// Bricks arrive by the thousand and are stacked in a rough cuboid. Measuring
/// the stack and dividing by the size of one brick gets close enough to catch
/// a short load, and it takes a tape and a minute. The exact method — rows
/// across, rows along, layers high — is better still when the stack is neat,
/// so both are here and the neat one leads.
class BrickStackCalculator {
  const BrickStackCalculator();

  /// Volume of one brick in cubic feet, from the BDS size the app already uses
  /// for brickwork. No mortar: a stack is dry.
  static double get brickCft =>
      BrickworkCalculator.bdsBrickLengthIn *
      BrickworkCalculator.bdsBrickWidthIn *
      BrickworkCalculator.bdsBrickHeightIn /
      1728.0;

  /// Bricks in one cubic foot of tightly stacked brick.
  static double get bricksPerCft => 1.0 / brickCft;

  /// The exact count, when the stack is regular enough to read off.
  CalcResult fromLayers({
    required int along,
    required int across,
    required int layers,
  }) {
    if (along < 1 || across < 1 || layers < 1) {
      throw CalcException(const L10nText(
        'লম্বায়, চওড়ায় আর উঁচুতে প্রতিটি সংখ্যা অন্তত ১ হতে হবে।',
        'Along, across and layers each have to be at least 1.',
      ));
    }
    final total = (along * across * layers).toDouble();
    return CalcResult(
      lines: [
        CalcLine(
          key: 'bricks',
          label: const L10nText('মোট ইট', 'Bricks in the stack'),
          value: total,
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'per_layer',
          label: const L10nText('প্রতি স্তরে', 'Per layer'),
          value: (along * across).toDouble(),
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
        ),
      ],
      formula: L10nText(
        'ইট = লম্বায় × চওড়ায় × স্তর = $along × $across × $layers = '
            '${total.toStringAsFixed(0)} টি।',
        'Bricks = along × across × layers = $along × $across × $layers = '
            '${total.toStringAsFixed(0)}.',
      ),
      assumptions: [
        const L10nText(
          'প্রতিটি স্তরে সমান সংখ্যক ইট ধরা হয়েছে।',
          'Every layer is taken to hold the same number of bricks.',
        ),
      ],
      note: const L10nText(
        'একটা স্তর গুনে নিন, তারপর স্তর গুনুন। পুরো গাদা গোনার দরকার নেই।',
        'Count one layer, then count the layers. There is no need to count the '
            'whole stack.',
      ),
    );
  }

  /// The tape method, for a stack too rough to read off.
  CalcResult fromStack({
    required double lengthFt,
    required double widthFt,
    required double heightFt,
    double gapPercent = 5.0,
  }) {
    for (final d in [lengthFt, widthFt, heightFt]) {
      if (!d.isFinite || d <= 0) {
        throw CalcException(const L10nText(
          'প্রতিটি মাপ শূন্যের বড় একটি সংখ্যা হতে হবে।',
          'Every measurement has to be a real number greater than zero.',
        ));
      }
    }
    if (!gapPercent.isFinite || gapPercent < 0 || gapPercent >= 100) {
      throw CalcException(const L10nText(
        'ফাঁকের হার ০ থেকে ১০০-এর মধ্যে হতে হবে।',
        'The gap allowance has to be between 0 and 100.',
      ));
    }
    final stackCft = lengthFt * widthFt * heightFt;
    final solid = stackCft * (1 - gapPercent / 100.0);
    final bricks = solid / brickCft;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'bricks',
          label: const L10nText('আন্দাজ কত ইট', 'Bricks, near enough'),
          value: bricks,
          unit: const L10nText('টি', 'nos'),
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'stack_cft',
          label: const L10nText('গাদার আয়তন', 'Volume of the stack'),
          value: stackCft,
          unit: U.cft,
        ),
      ],
      formula: L10nText(
        'ইট = গাদার আয়তন × (১ − ফাঁক) ÷ এক ইটের আয়তন = ${_fmt(stackCft)} × '
            '(১ − ${_fmt(gapPercent)}%) ÷ ${brickCft.toStringAsFixed(4)} = '
            '${bricks.toStringAsFixed(0)} টি।',
        'Bricks = stack volume × (1 − gaps) ÷ volume of one brick = '
            '${_fmt(stackCft)} × (1 − ${_fmt(gapPercent)}%) ÷ '
            '${brickCft.toStringAsFixed(4)} = ${bricks.toStringAsFixed(0)}.',
      ),
      assumptions: [
        L10nText(
          'ইটের মাপ ${_fmt(BrickworkCalculator.bdsBrickLengthIn)}″ × '
              '${_fmt(BrickworkCalculator.bdsBrickWidthIn)}″ × '
              '${_fmt(BrickworkCalculator.bdsBrickHeightIn)}″, অর্থাৎ প্রতি '
              'ঘনফুটে ${bricksPerCft.toStringAsFixed(1)} টি।',
          'Brick taken as ${_fmt(BrickworkCalculator.bdsBrickLengthIn)}″ × '
              '${_fmt(BrickworkCalculator.bdsBrickWidthIn)}″ × '
              '${_fmt(BrickworkCalculator.bdsBrickHeightIn)}″, which is '
              '${bricksPerCft.toStringAsFixed(1)} per cubic foot.',
        ),
        L10nText(
          'গাদায় ${_fmt(gapPercent)}% ফাঁক ধরা হয়েছে। গাদা যত এলোমেলো, ফাঁক তত '
              'বেশি।',
          'A ${_fmt(gapPercent)}% allowance for gaps in the stack. The rougher '
              'the stack, the bigger the gaps.',
        ),
      ],
      note: const L10nText(
        'এটি আন্দাজ। মিল না হলে একটা স্তর গুনে স্তর দিয়ে গুণ করুন — ওটাই আসল '
            'সংখ্যা।',
        'This is an estimate. If it does not match, count one layer and '
            'multiply by the layers: that is the real number.',
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
