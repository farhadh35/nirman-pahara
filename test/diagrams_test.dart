import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/guide/diagrams/diagram_base.dart';
import 'package:nirman_pahara/features/guide/diagrams/guide_diagrams.dart';
import 'package:nirman_pahara/features/guide/diagrams/materials_diagrams.dart';
import 'package:nirman_pahara/features/guide/diagrams/structure_diagrams.dart';

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

  test('no painter throws, whatever size it is handed', () {
    // Diagrams are laid out fractionally, so a narrow phone, a tablet and the
    // degenerate cases all go through the same arithmetic. A divide by zero
    // here would crash the guide screen rather than degrade it.
    const palette = DiagramPalette(
      ink: Color(0xFF000000),
      muted: Color(0xFF666666),
      concrete: Color(0xFFDDE3DA),
      steel: Color(0xFF9A3412),
      accent: Color(0xFF006A4E),
      water: Color(0xFFBFE0F0),
    );
    final painters = <String, CustomPainter>{
      'silt_test': SiltTestPainter(palette: palette, bn: true),
      'brick_bond': BrickBondPainter(palette: palette, bn: false),
      'cover_block': CoverBlockPainter(palette: palette, bn: true),
      'footing_section': FootingSectionPainter(palette: palette, bn: false),
    };
    const sizes = [
      Size(320, 160),
      Size(360, 190),
      Size(1024, 512),
      Size(1, 1),
    ];
    for (final entry in painters.entries) {
      for (final size in sizes) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        expect(
          () => entry.value.paint(canvas, size),
          returnsNormally,
          reason: '${entry.key} at ${size.width}x${size.height}',
        );
        recorder.endRecording().dispose();
      }
    }
  });

  test('the silt limit the drawing is scaled to is the one the app checks', () {
    // The band drawn on the page is drawn against this number, so if the figure
    // ever moves the drawing has to move with it.
    expect(SiltTestPainter.limitPercent, 6.0);
  });
}
