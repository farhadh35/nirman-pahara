import 'package:flutter/widgets.dart';

import '../../core/i18n/app_locale.dart';
import '../../core/util/bn.dart';

/// Rewrites what is already in a text box when the reader changes language.
///
/// Every form in this app seeds its starting value in the reader's own script,
/// once. A language change afterwards left the old digits sitting in the box
/// while the answer below them switched — the same number in two scripts on one
/// screen, in an app whose whole promise is that a number can be trusted.
///
/// Only the digits change. Whatever the reader typed is kept, because
/// converting the seed correctly while destroying their own number would be the
/// worse bug. A box holding a money amount is regrouped rather than left as a
/// bare run of digits, since a seven-figure contract value is unreadable
/// without the grouping.
///
/// This lives here rather than in each screen because it was written three
/// times before anyone noticed the fourth screen had never got it.
void followLocaleDigits(
  Iterable<TextEditingController> controllers,
  AppLocale locale, {
  bool grouped = false,
}) {
  for (final c in controllers) {
    if (c.text.trim().isEmpty) continue;
    final converted = grouped
        ? Bn.number(Bn.parse(c.text) ?? 0, decimals: 0, locale: locale)
        : Bn.localiseDigits(c.text, locale);
    if (converted == c.text) continue;
    c.value = TextEditingValue(
      text: converted,
      selection: TextSelection.collapsed(offset: converted.length),
    );
  }
}
