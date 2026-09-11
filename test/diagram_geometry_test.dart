import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Facts about what the diagrams draw, pinned so they cannot drift back.
///
/// Nineteen diagrams ship, ~2,400 lines of painter code, and until now the
/// only tests on them checked colour contrast and that painting did not throw.
/// Neither looks at the picture, which is how a 180 degree hook came to be
/// labelled with a 90 degree hook's extension and an English bond came to be
/// drawn with its vertical joints lined up.
String _src(String file) =>
    File('lib/features/guide/diagrams/$file').readAsStringSync();

void main() {
  test('the standard hook is a quarter turn, matching its 12d label', () {
    // 12d is the extension for a 90 degree hook. A 180 degree hook takes 4d
    // with a 65 mm floor. The painter drew the half-circle and kept the 12d
    // label, pairing one hook's geometry with the other hook's rule.
    final src = _src('rebar_diagrams.dart');
    final hook = src.substring(src.indexOf('class StandardHookPainter'));
    expect(hook, contains('-1.5708'),
        reason: 'the hook arc is no longer a quarter turn; if it is a 180 '
            'degree bend again, the 12 x diameter label is wrong');
    expect(hook, isNot(contains('drawArc(arc, 1.5708, -3.1416')),
        reason: 'the full half-circle bend is back under a 12d label');
    expect(hook, contains('4 diameters'),
        reason: 'the caption no longer names the 180 degree rule, so a reader '
            'bending one has nothing to go on');
  });

  test('English bond opens its header course with a closer', () {
    // Without the closer the header course starts flush with the stretcher
    // course, every fourth joint lines up with the one above, and the drawing
    // shows the continuous vertical joint it exists to warn against.
    final src = _src('materials_diagrams.dart');
    expect(src, contains('queen closer'),
        reason: 'the closer comment is gone; check the header course still '
            'starts offset');
    expect(src, contains('final closer = header / 2'),
        reason: 'the header course no longer starts with a half header, so '
            'its joints line up with the stretcher course below');
  });

  test('the rod binding diagram does not claim a hook it cannot draw', () {
    // A tie seen from the side is a straight line; its ends are hidden. The
    // painter claimed "stirrups with inward hooks" and drew a plain rectangle.
    final src = _src('guide_diagrams.dart');
    final start = src.indexOf('RodBindingPainter');
    final header = src.substring(0, start);
    expect(header, isNot(contains('stirrups with inward hooks')),
        reason: 'the painter is claiming to draw inward hooks again; either '
            'draw them or do not say so');
  });

  test('every diagram key still resolves to a painter', () {
    final src = _src('guide_diagrams.dart');
    final keys = RegExp(r"^\s*'([a-z_]+)',$", multiLine: true)
        .allMatches(src.substring(src.indexOf('kGuideDiagramKeys'),
            src.indexOf('Widget? guideDiagram')))
        .map((m) => m.group(1)!)
        .toList();
    expect(keys.length, 19,
        reason: 'the diagram list changed size; update this test and the '
            'listing counts together');
    for (final key in keys) {
      expect(src, contains("'$key' =>"),
          reason: '$key is listed but the switch does not build it');
    }
  });
}
