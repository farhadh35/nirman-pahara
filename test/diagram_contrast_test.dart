import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/features/guide/diagrams/diagram_base.dart';

/// Relative luminance, per WCAG. 0 is black, 1 is white.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

/// How far apart two colours are, 1:1 (identical) to 21:1 (black on white).
double _contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The floor WCAG sets for a graphic someone has to make out the shape of.
const _graphicMinimum = 3.0;

Future<DiagramPalette> _paletteFor(WidgetTester tester, Brightness b) async {
  late DiagramPalette palette;
  // A unique key each time: pumping a structurally identical tree twice in one
  // test reuses the element and never re-runs the builder, which quietly
  // returned the first theme's palette for the second theme.
  await tester.pumpWidget(MaterialApp(
    theme: b == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
    home: Builder(
      key: UniqueKey(),
      builder: (context) {
        palette = DiagramPalette.of(context);
        return const SizedBox();
      },
    ),
  ));
  return palette;
}

void main() {
  // The diagrams are the part of this app that teaches without words, and steel
  // is the thing they are usually about — a bar's cover, its hooks, how close
  // the stirrups sit. It was one fixed rust for both themes, which on dark left
  // the bars at 1.5:1 against the concrete they are drawn inside: present in
  // the render, invisible to a reader.
  for (final brightness in Brightness.values) {
    testWidgets('steel can be seen in ${brightness.name} mode', (tester) async {
      final p = await _paletteFor(tester, brightness);
      final background = brightness == Brightness.dark
          ? const Color(0xFF121412)
          : const Color(0xFFF7F7F4);

      expect(_contrast(p.steel, background), greaterThanOrEqualTo(_graphicMinimum),
          reason: 'a reinforcement bar cannot be picked out of the page');
      expect(_contrast(p.steel, p.concrete), greaterThanOrEqualTo(_graphicMinimum),
          reason: 'a bar cannot be picked out of the concrete around it, which '
              'is what every cover and stirrup drawing is showing');
    });

    testWidgets('ink and the accent carry in ${brightness.name} mode',
        (tester) async {
      final p = await _paletteFor(tester, brightness);
      final background = brightness == Brightness.dark
          ? const Color(0xFF121412)
          : const Color(0xFFF7F7F4);
      // Labels are text, so they answer to the stricter text floor.
      expect(_contrast(p.ink, background), greaterThanOrEqualTo(4.5),
          reason: 'diagram labels are hard to read');
      expect(_contrast(p.accent, background),
          greaterThanOrEqualTo(_graphicMinimum),
          reason: 'the colour that marks the thing to look at does not stand out');
    });
  }

  testWidgets('steel is not the same colour in both themes', (tester) async {
    // The regression that started this: one constant serving two backgrounds.
    final light = await _paletteFor(tester, Brightness.light);
    final lightSteel = light.steel;
    await tester.pumpWidget(const SizedBox());
    final dark = await _paletteFor(tester, Brightness.dark);
    expect(dark.steel, isNot(equals(lightSteel)),
        reason: 'one constant is serving two backgrounds again');
  });
}
