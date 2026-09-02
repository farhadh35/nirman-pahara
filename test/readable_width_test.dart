import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/widgets/readable_width.dart';

/// Widths a real device hands the app, in logical pixels.
const _devices = <String, double>{
  'phone portrait': 411, // 1080px at 420dpi
  'phone landscape': 914,
  'tablet 7in': 600, // 1200px at 320dpi
  'tablet 10in': 800, // 1600px at 320dpi
};

/// Measures the page width the widget actually hands its child on a screen of
/// [screenWidth] logical pixels.
///
/// The view is resized rather than the MediaQuery overridden: the widget reads
/// MediaQuery to decide, and the render surface decides what it can lay out. An
/// earlier version of this test set only the MediaQuery, so the two disagreed —
/// it reported the full 800px test surface for every device and would have
/// passed whatever the cap was.
Future<double> _contentWidth(WidgetTester tester, double screenWidth) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(screenWidth, 1200);
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      home: ReadableWidth(child: SizedBox.expand(child: Container(key: key))),
    ),
  );
  return tester.getSize(find.byKey(key)).width;
}

void main() {
  // The first version of this capped at 720dp, which on the only tablet that
  // mattered — 800dp wide — trimmed the page to ninety per cent of itself. That
  // is a change no one can see, and it shipped because nothing measured it.
  // This measures it.
  testWidgets('a ten-inch tablet gets real margins, not a token trim',
      (tester) async {
    final w = await _contentWidth(tester, _devices['tablet 10in']!);
    expect(w, ReadableWidth.maxWidth);
    expect(w / _devices['tablet 10in']!, lessThan(0.85),
        reason: 'the cap trims so little of the screen that it does nothing '
            'a reader would notice');
  });

  testWidgets('a phone in landscape is held to a readable column',
      (tester) async {
    final w = await _contentWidth(tester, _devices['phone landscape']!);
    expect(w, ReadableWidth.maxWidth);
  });

  testWidgets('phones and seven-inch tablets are left alone', (tester) async {
    for (final name in ['phone portrait', 'tablet 7in']) {
      final screen = _devices[name]!;
      expect(await _contentWidth(tester, screen), screen,
          reason: '$name lost width it did not have to spare');
    }
  });

  testWidgets('the column never exceeds the screen on a narrow device',
      (tester) async {
    for (final screen in const [320.0, 360.0, 411.0, 600.0]) {
      expect(await _contentWidth(tester, screen), lessThanOrEqualTo(screen));
    }
  });

  test('the cap is a width a line of text can actually be read across', () {
    // 600dp is the top of Material's compact window class. Much wider and the
    // reader loses their place tracking back to the next line; much narrower
    // and a tablet looks like a stretched phone with wasted glass.
    expect(ReadableWidth.maxWidth, 600);
  });
}
