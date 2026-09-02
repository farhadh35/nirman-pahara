import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// A cement : sand : aggregate volumetric mix, the way it is called out on a
/// Bangladeshi site ("এক দুই চার" = 1:2:4).
///
/// Mortar mixes have no aggregate part; pass [aggregate] = 0.
class MixRatio {
  const MixRatio(this.cement, this.sand, this.aggregate);

  final double cement;
  final double sand;
  final double aggregate;

  double get sum => cement + sand + aggregate;

  bool get isMortar => aggregate == 0;

  String get label => isMortar
      ? '${fmt(cement)}:${fmt(sand)}'
      : '${fmt(cement)}:${fmt(sand)}:${fmt(aggregate)}';

  static String fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  static MixRatio parse(String s) {
    final parts = s.split(':').map((e) => double.tryParse(e.trim())).toList();
    if (parts.length < 2 || parts.length > 3 || parts.any((e) => e == null)) {
      throw CalcException(const L10nText(
        'অনুপাত লিখুন এভাবে: ১:২:৪ বা ১:৬',
        'Write the ratio like 1:2:4 or 1:6',
      ));
    }
    if (parts.any((e) => e! <= 0)) {
      throw CalcException(const L10nText(
        'অনুপাতের কোনো অংশ শূন্য হতে পারে না।',
        'No part of the ratio can be zero.',
      ));
    }
    return MixRatio(parts[0]!, parts[1]!, parts.length == 3 ? parts[2]! : 0);
  }

  // --- Common Bangladeshi mixes -------------------------------------------
  // Nominal (volumetric) mixes still in wide use for small works. BNBC 2020
  // Part 6 specifies concrete by characteristic cylinder strength, so a
  // nominal ratio indicates the intended grade — it is not a substitute for a
  // mix design or a cylinder test. The app says so wherever it is used.

  static const MixRatio c1_1p5_3 = MixRatio(1, 1.5, 3);
  static const MixRatio c1_2_4 = MixRatio(1, 2, 4);
  static const MixRatio c1_3_6 = MixRatio(1, 3, 6);
  static const MixRatio c1_4_8 = MixRatio(1, 4, 8);

  static const MixRatio m1_4 = MixRatio(1, 4, 0);
  static const MixRatio m1_5 = MixRatio(1, 5, 0);
  static const MixRatio m1_6 = MixRatio(1, 6, 0);

  static const List<MixRatio> commonConcrete = [
    c1_1p5_3,
    c1_2_4,
    c1_3_6,
    c1_4_8,
  ];

  static const List<MixRatio> commonMortar = [m1_4, m1_5, m1_6];

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      other is MixRatio &&
      other.cement == cement &&
      other.sand == sand &&
      other.aggregate == aggregate;

  @override
  int get hashCode => Object.hash(cement, sand, aggregate);
}
