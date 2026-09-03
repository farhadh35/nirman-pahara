import '../i18n/app_locale.dart';

/// Number formatting for Bangladesh, in both languages.
///
/// Bangla shows Bangla digits (১২,৩৪,৫৬৭); English shows western digits. Both
/// use the South Asian lakh/crore grouping, because that is how amounts are
/// written and spoken in Bangladesh regardless of the language of the sentence
/// around them. Machine-facing code always keeps western digits; conversion
/// happens only at the point of display.
class Bn {
  Bn._();

  static const List<String> _digits = [
    '০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯',
  ];

  /// Converts every western digit in [s] to its Bangla form.
  static String digits(String s) {
    final buf = StringBuffer();
    for (final rune in s.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buf.write(_digits[rune - 0x30]);
      } else {
        buf.writeCharCode(rune);
      }
    }
    return buf.toString();
  }

  /// Converts Bangla digits back to western digits, for parsing user input.
  static String toWestern(String s) {
    final buf = StringBuffer();
    for (final rune in s.runes) {
      final idx = _digits.indexOf(String.fromCharCode(rune));
      buf.write(idx >= 0 ? '$idx' : String.fromCharCode(rune));
    }
    return buf.toString();
  }

  /// Applies Bangla digits only when the locale is Bangla.
  ///
  /// Ask one question before calling this: **does a person read this number, or
  /// do they put it back into a machine?**
  ///
  /// Read — a date, a quantity, a rate, a measurement, a chapter number someone
  /// turns pages to find. Bangla digits, always: that is the whole point of a
  /// Bangla-first app.
  ///
  /// Re-entered — a tender ID typed into the e-GP portal's search box, a
  /// coordinate pasted into a map, a serial an official matches against a
  /// printed row, a schedule item code. Leave these exactly as they were given.
  /// "LGED-২০২৬-০১৪২" matches nothing, and no map has ever accepted
  /// "২৪.৮৯৪৩১". The app once converted all three and, worse, carries a card
  /// teaching people to search by tender ID — it explained a lookup and then
  /// made it impossible, in the document handed to an authority.
  static String localiseDigits(String s, AppLocale locale) =>
      locale.isBangla ? digits(s) : toWestern(s);

  /// Parses user input that may contain Bangla digits, commas or spaces.
  static double? parse(String s) {
    final cleaned =
        toWestern(s).replaceAll(',', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  /// Formats [value] with [decimals] places, using lakh/crore grouping and the
  /// digit set of [locale].
  static String number(
    double value, {
    int decimals = 2,
    AppLocale locale = AppLocale.bn,
  }) {
    if (value.isNaN || value.isInfinite) return '—';
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final grouped = group(parts[0]);
    final joined = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
    final signed = negative ? '-$joined' : joined;
    return locale.isBangla ? digits(signed) : signed;
  }

  /// Formats a taka amount, e.g. ৳ ৪২,৫০,০০০ / Tk 42,50,000.
  static String taka(
    double value, {
    int decimals = 0,
    AppLocale locale = AppLocale.bn,
  }) {
    final n = number(value, decimals: decimals, locale: locale);
    return locale.isBangla ? '৳ $n' : 'Tk $n';
  }

  /// Renders large amounts the way people say them: ৪২.৫০ লাখ / 42.50 lakh.
  static String takaWords(double value, {AppLocale locale = AppLocale.bn}) {
    final abs = value.abs();
    String unit(String bn, String en) => locale.isBangla ? bn : en;
    String amount(double v) => number(v, decimals: 2, locale: locale);
    final prefix = locale.isBangla ? '৳' : 'Tk';

    if (abs >= 10000000) {
      return '$prefix ${amount(value / 10000000)} ${unit('কোটি', 'crore')}';
    }
    if (abs >= 100000) {
      return '$prefix ${amount(value / 100000)} ${unit('লাখ', 'lakh')}';
    }
    if (abs >= 1000) {
      return '$prefix ${number(value / 1000, decimals: 1, locale: locale)} '
          '${unit('হাজার', 'thousand')}';
    }
    return taka(value, locale: locale);
  }

  /// Groups an integer string as 1,23,45,678 (last three, then pairs).
  static String group(String intPart) {
    if (intPart.length <= 3) return intPart;
    final last3 = intPart.substring(intPart.length - 3);
    var rest = intPart.substring(0, intPart.length - 3);
    final chunks = <String>[];
    while (rest.length > 2) {
      chunks.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) chunks.insert(0, rest);
    return '${chunks.join(',')},$last3';
  }
}
