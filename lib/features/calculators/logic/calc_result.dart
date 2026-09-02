import '../../../core/i18n/app_locale.dart';

/// Result of a calculation.
///
/// Every calculator returns the numbers *and* the formula *and* the assumptions
/// used, so a user — or the contractor they are arguing with — can check the
/// work. See docs/CONTENT_RULES.md rule 1: no bare numbers.
class CalcResult {
  const CalcResult({
    required this.lines,
    required this.formula,
    required this.assumptions,
    this.note,
  });

  /// The output rows, in display order.
  final List<CalcLine> lines;

  /// Plain-text formula, shown under "কীভাবে হিসাব হলো" / "How this was worked out".
  final L10nText formula;

  /// Every constant or convention the result depends on.
  final List<L10nText> assumptions;

  /// Optional caveat shown in the warning style.
  final L10nText? note;

  CalcLine? lineByKey(String key) {
    for (final l in lines) {
      if (l.key == key) return l;
    }
    return null;
  }

  double? valueOf(String key) => lineByKey(key)?.value;
}

class CalcLine {
  const CalcLine({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    this.decimals = 2,
    this.emphasis = false,
  });

  /// Stable machine key, never shown.
  final String key;

  final L10nText label;
  final double value;
  final L10nText unit;
  final int decimals;

  /// Headline number for this calculator.
  final bool emphasis;
}

/// Units that recur across calculators.
class U {
  U._();

  static const bag = L10nText('ব্যাগ (৫০ কেজি)', 'bag (50 kg)');
  static const cft = L10nText('ঘনফুট', 'cft');
  static const sft = L10nText('বর্গফুট', 'sft');
  static const ft = L10nText('ফুট', 'ft');
  static const kg = L10nText('কেজি', 'kg');
  static const ton = L10nText('টন', 'tonne');
  static const pieces = L10nText('টি', 'pcs');
  static const litre = L10nText('লিটার', 'litre');
  static const taka = L10nText('টাকা', 'Tk');
  static const percent = L10nText('শতাংশ', '%');
}

class CalcException implements Exception {
  CalcException(this.message);

  final L10nText message;

  String of(AppLocale locale) => message.of(locale);

  @override
  String toString() => message.bn;
}
