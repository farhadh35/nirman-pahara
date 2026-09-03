import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/theme.dart';

/// WCAG relative luminance.
double _lum(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

/// Contrast ratio, 1:1 (invisible) to 21:1 (black on white).
double _ratio(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

Color _over(Color fg, Color bg, double alpha) => Color.fromARGB(
      255,
      ((fg.r * alpha + bg.r * (1 - alpha)) * 255).round(),
      ((fg.g * alpha + bg.g * (1 - alpha)) * 255).round(),
      ((fg.b * alpha + bg.b * (1 - alpha)) * 255).round(),
    );

void main() {
  // Body text needs 4.5:1 against what it sits on. These three colours are
  // fixed rather than drawn from the scheme, so nothing else checks them —
  // and the amber shipped at 2.44:1 on the light theme, fainter than the
  // page's own hairlines, on the badge that flagged an unverified figure.
  const needed = 4.5;

  for (final (brightness, theme) in [
    (Brightness.light, AppTheme.light()),
    (Brightness.dark, AppTheme.dark()),
  ]) {
    final page = theme.scaffoldBackgroundColor;
    final name = brightness == Brightness.light ? 'light' : 'dark';

    for (final colour in ['warning', 'danger', 'ok']) {
      test('$colour is readable on the $name page', () {
        final c = AppTheme.statusColour(colour, brightness);
        expect(_ratio(c, page), greaterThanOrEqualTo(needed),
            reason: '$colour on $name is '
                '${_ratio(c, page).toStringAsFixed(2)}:1');
      });
    }

    test('caution text is readable on its own tinted panel ($name)', () {
      // CautionBox paints the amber back at 10% and writes on top of it, so
      // the panel is what the text is actually read against, not the page.
      final amber = AppTheme.statusColour('warning', brightness);
      final panel = _over(amber, page, 0.10);
      expect(_ratio(amber, panel), greaterThanOrEqualTo(needed),
          reason: 'caution amber on its panel is '
              '${_ratio(amber, panel).toStringAsFixed(2)}:1');
    });

    test('the scheme error colour matches the $name danger colour', () {
      expect(theme.colorScheme.error,
          AppTheme.statusColour('danger', brightness));
    });
  }
}
