import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/features/guide/diagrams/guide_diagrams.dart';

/// Not an assertion — a darkroom.
///
/// The guide's nineteen diagrams are painted in code, and the tests that exist
/// check contrast ratios and that nothing throws. Neither has ever looked at
/// the picture. A stirrup drawn at the wrong spacing, a hook bent the wrong
/// way, a label pointing at the wrong line: all of that passes today.
///
/// This writes each diagram out as a PNG so a human — or a vision model — can
/// look at it against the book. Run with:
///   flutter test test/render_diagrams_tool_test.dart
Future<void> _loadFonts() async {
  // Without this every Bangla glyph renders as a tofu box. flutter_test ships
  // a single test font and does not read the asset bundle's font manifest, so
  // a render captured here looks nothing like the app unless the real family
  // is loaded by hand. The first pass of this harness produced nineteen
  // diagrams of empty rectangles and very nearly had four vision agents
  // reporting the app's Bangla as broken.
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final loader = FontLoader('NotoSansBengali');
    final bytes = File('assets/fonts/NotoSansBengali-$weight.ttf')
        .readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

void main() {
  // Overridable so a reviewer can point it somewhere they will look:
  //   flutter test test/render_diagrams_tool_test.dart --dart-define=DIAGRAM_OUT=/tmp/d
  const outDir = String.fromEnvironment('DIAGRAM_OUT',
      defaultValue: 'build/diagram-renders');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
  });

  for (final key in kGuideDiagramKeys) {
    for (final (themeName, theme) in [
      ('light', AppTheme.light()),
      ('dark', AppTheme.dark()),
    ]) {
      testWidgets('render $key ($themeName)', (tester) async {
        tester.view.physicalSize = const Size(1400, 2000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        final boundaryKey = GlobalKey();
        await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKey,
                child: SizedBox(
                  width: 640,
                  child: Builder(
                    builder: (context) =>
                        guideDiagram(context, key, bn: true) ??
                        const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        ));
        // Two plain pumps, not pumpAndSettle: if any diagram ever animates,
        // settle would sit on its ten-minute timeout and the render of all
        // nineteen would take hours instead of seconds.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 32));

        final boundary = boundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

        // runAsync, or this hangs until the test times out. toImage and
        // toByteData hand work to the engine and wait on a real future; under
        // the test binding's fake clock that future is never completed, so the
        // await simply never returns.
        late ByteData? bytes;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2.0);
          bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        });

        Directory(outDir).createSync(recursive: true);
        File('$outDir/$key.$themeName.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        expect(bytes!.lengthInBytes, greaterThan(0));
      });
    }
  }
}
