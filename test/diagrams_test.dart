import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/guide/diagrams/diagram_base.dart';
import 'package:nirman_pahara/features/guide/diagrams/guide_diagrams.dart';
import 'package:nirman_pahara/features/guide/diagrams/materials_diagrams.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;
  setUp(() => repo = ContentRepository(reader: _fromDisk));

  testWidgets('every diagram a card asks for actually resolves to a painter',
      (tester) async {
    // A card naming a diagram the app cannot draw renders a hole where the
    // explanation should be, and nothing in the content pipeline would catch it.
    late List<String> used;
    await tester.runAsync(() async {
      final pack = await repo.guide();
      used = [
        for (final m in pack.modules)
          for (final c in m.cards)
            if (c.diagram != null) c.diagram!,
      ];
    });
    expect(used, isNotEmpty);
    for (final key in used) {
      expect(kGuideDiagramKeys, contains(key), reason: 'no painter for "$key"');
    }
  });

  testWidgets('every painter is reached by at least one card', (tester) async {
    // The other direction: a painter nothing references is dead weight in the
    // bundle and, worse, was drawn for a card that never got written.
    late Set<String> used;
    await tester.runAsync(() async {
      final pack = await repo.guide();
      used = {
        for (final m in pack.modules)
          for (final c in m.cards)
            if (c.diagram != null) c.diagram!,
      };
    });
    for (final key in kGuideDiagramKeys) {
      expect(used, contains(key), reason: '"$key" is drawn but never shown');
    }
  });

  testWidgets('a known key builds and an unknown one is simply absent',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          expect(guideDiagram(context, 'silt_test', bn: true), isNotNull);
          expect(guideDiagram(context, 'nothing_like_this', bn: true), isNull);
          expect(guideDiagram(context, null, bn: true), isNull);
          return const SizedBox();
        },
      ),
    ));
  });

  testWidgets('every registered diagram survives any size it is given',
      (tester) async {
    // Diagrams lay out in fractions of the canvas, so a narrow phone, a tablet
    // and the degenerate cases all run the same arithmetic. Driven off the
    // registry rather than a list here, so a new painter cannot be added
    // without also being crash-checked.
    for (final key in kGuideDiagramKeys) {
      // Widths a real handset and a tablet give a guide card, with height left
      // free the way a scrolling list leaves it.
      for (final width in const [300.0, 360.0, 900.0]) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                SizedBox(
                  width: width,
                  child: Builder(
                    builder: (context) =>
                        guideDiagram(context, key, bn: true) ?? const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ));
        expect(tester.takeException(), isNull, reason: '$key at ${width}px');
      }
    }
  });

  test('a canvas too small to say anything on is declined, not drawn on', () {
    // The painters lay out fractionally, so a degenerate canvas would otherwise
    // produce inverted rectangles and negative text widths.
    expect(diagramTooSmall(const Size(60, 30)), isTrue);
    expect(diagramTooSmall(const Size(double.nan, 200)), isTrue);
    expect(diagramTooSmall(const Size(320, 170)), isFalse);
  });

  test('the silt limit the drawing is scaled to is the one the app checks', () {
    // The band drawn on the page is drawn against this number, so if the figure
    // ever moves the drawing has to move with it.
    expect(SiltTestPainter.limitPercent, 6.0);
  });
}
