import 'package:flutter/services.dart';

import '../i18n/app_locale.dart';
import 'bn.dart';

/// Groups a money field as the user types: ৪২,৫০,০০০ rather than ৪২৫০০০০.
///
/// A contract value off a signboard is seven or eight digits long. Ungrouped,
/// nobody can tell 42 lakh from 4 crore at a glance, and the whole point of the
/// screen is that the user can. Grouping is lakh/crore, matching how the amount
/// is written and spoken in Bangladesh.
///
/// Input in either digit set is accepted; the field is rewritten in the digit
/// set of [locale]. `Bn.parse` strips the separators again, so the calculators
/// never see them.
class GroupedNumberFormatter extends TextInputFormatter {
  const GroupedNumberFormatter(this.locale);

  final AppLocale locale;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = _digitsAndOneDot(Bn.toWestern(newValue.text));
    if (cleaned.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final parts = cleaned.split('.');
    final grouped = Bn.group(parts[0]);
    final joined = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
    final text = locale.isBangla ? Bn.digits(joined) : joined;

    // Keep the caret the same number of digits from the end, so that inserting
    // a separator does not shunt it.
    final tail = newValue.text.substring(
      newValue.selection.end.clamp(0, newValue.text.length),
    );
    final digitsAfterCaret = _countDigits(tail);
    final offset = _offsetLeavingDigitsOnRight(text, digitsAfterCaret);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  /// Strips everything but digits, keeping at most one decimal point.
  static String _digitsAndOneDot(String s) {
    final buf = StringBuffer();
    var seenDot = false;
    for (final ch in s.split('')) {
      if (ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39) {
        buf.write(ch);
      } else if (ch == '.' && !seenDot && buf.isNotEmpty) {
        seenDot = true;
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  static int _countDigits(String s) {
    var n = 0;
    for (final ch in s.split('')) {
      if (_isDigit(ch)) n++;
    }
    return n;
  }

  static bool _isDigit(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 0x30 && c <= 0x39) || (c >= 0x09E6 && c <= 0x09EF);
  }

  static int _offsetLeavingDigitsOnRight(String text, int digitsOnRight) {
    if (digitsOnRight <= 0) return text.length;
    var seen = 0;
    for (var i = text.length - 1; i >= 0; i--) {
      if (_isDigit(text[i])) {
        seen++;
        if (seen == digitsOnRight) return i;
      }
    }
    return 0;
  }
}
