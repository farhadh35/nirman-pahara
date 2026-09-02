import 'package:flutter/material.dart';

import 'diagram_base.dart';

/// Cover: the concrete between the steel and the outside air.
///
/// The one dimension in a reinforced member that a person with no training can
/// check, on the day, with a tape — and the one most often lost, because bars
/// laid straight on the shutter cost nothing and save a few blocks. Too little
/// cover is why a five year old building has rust stains and spalling on its
/// beam soffits: water reaches the steel, the steel swells as it rusts, and the
/// concrete is pushed off from inside.
///
/// Drawn as the two cases side by side, because the difference is only visible
/// as a comparison.
class CoverBlockPainter extends CustomPainter {
  CoverBlockPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final half = size.width / 2;
    _case(canvas, Rect.fromLTWH(0, 0, half, size.height), withCover: true);
    _case(canvas, Rect.fromLTWH(half, 0, half, size.height), withCover: false);
  }

  void _case(Canvas canvas, Rect cell, {required bool withCover}) {
    paintLabel(
      canvas,
      withCover
          ? (bn ? 'কভার ব্লক দেওয়া' : 'Cover blocks in place')
          : (bn ? 'কভার ব্লক ছাড়া' : 'No cover blocks'),
      Offset(cell.center.dx, cell.top + 4),
      colour: withCover ? palette.accent : palette.steel,
      size: 11,
      weight: FontWeight.w600,
      centreOnPoint: true,
      maxWidth: cell.width,
    );

    final beam = Rect.fromLTRB(
      cell.left + cell.width * 0.14,
      cell.top + cell.height * 0.24,
      cell.right - cell.width * 0.26,
      cell.bottom - cell.height * 0.30,
    );
    canvas.drawRect(beam, Paint()..color = palette.concrete);
    canvas.drawRect(
      beam,
      Paint()
        ..color = palette.muted.withValues(alpha: 0.6)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // The shutter face the cover is measured from.
    canvas.drawLine(
      Offset(beam.left, beam.bottom + 3),
      Offset(beam.right, beam.bottom + 3),
      Paint()
        ..color = palette.muted
        ..strokeWidth = 2.5,
    );

    final cover = withCover ? beam.height * 0.16 : beam.height * 0.02;
    final barY = beam.bottom - cover;
    final bar = Paint()..color = palette.steel;
    for (var i = 0; i < 3; i++) {
      final x = beam.left + beam.width * (0.25 + i * 0.25);
      canvas.drawCircle(Offset(x, barY), beam.height * 0.075, bar);
    }

    if (withCover) {
      // The block that holds the bar off the shutter.
      for (var i = 0; i < 2; i++) {
        final x = beam.left + beam.width * (0.35 + i * 0.32);
        canvas.drawRect(
          Rect.fromLTRB(x - 5, barY + 2, x + 5, beam.bottom - 1),
          Paint()..color = palette.accent.withValues(alpha: 0.55),
        );
      }
      paintDimension(
        canvas,
        Offset(beam.right + 10, beam.bottom),
        Offset(beam.right + 10, barY),
        bn ? 'কভার' : 'cover',
        palette.accent,
      );
      paintLabel(
        canvas,
        bn
            ? 'রড শাটার থেকে উঁচুতে থাকে, চারপাশে কংক্রিট ঢোকে'
            : 'The bar sits off the shutter and concrete gets all round it',
        Offset(cell.left + 8, beam.bottom + cell.height * 0.10),
        colour: palette.muted,
        size: 9.5,
        maxWidth: cell.width - 16,
      );
    } else {
      // Rust bleeding through, which is what this looks like in three years.
      for (var i = 0; i < 3; i++) {
        final x = beam.left + beam.width * (0.25 + i * 0.25);
        canvas.drawRect(
          Rect.fromLTRB(x - 7, beam.bottom - 2, x + 7, beam.bottom + 2),
          Paint()..color = palette.steel.withValues(alpha: 0.6),
        );
      }
      paintLeader(
        canvas,
        Offset(beam.right + 8, barY - 18),
        Offset(beam.right - beam.width * 0.12, barY),
        palette.steel,
      );
      paintLabel(
        canvas,
        bn
            ? 'রড শাটারে ঠেকে আছে — এখানেই মরিচা ধরে কংক্রিট খসে পড়ে'
            : 'The bar is touching the shutter: this is where it rusts and the '
                'concrete breaks away',
        Offset(cell.left + 8, beam.bottom + cell.height * 0.10),
        colour: palette.steel,
        size: 9.5,
        maxWidth: cell.width - 16,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CoverBlockPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// What sits under a wall, from the earth up to the finished floor.
///
/// Every layer here is buried within days of going in, and each one is a place
/// where a course can quietly go missing. The damp proof course is the one that
/// matters most and costs least: without it the ground feeds water into the
/// wall for the life of the building, and no amount of paint later fixes it.
///
/// The plinth height above the road is drawn because it is the one dimension in
/// this section that stays visible forever, so it can be checked long after
/// everything below it is covered.
class FootingSectionPainter extends CustomPainter {
  FootingSectionPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final w = size.width;
    final h = size.height;
    final cx = w * 0.44;
    final ground = h * 0.58;

    // Earth.
    canvas.drawRect(
      Rect.fromLTRB(0, ground, w, h),
      Paint()..color = palette.muted.withValues(alpha: 0.16),
    );
    canvas.drawLine(Offset(0, ground), Offset(w, ground),
        Paint()..color = palette.muted..strokeWidth = 1.4);

    final concrete = Paint()..color = palette.concrete;
    final outline = Paint()
      ..color = palette.muted.withValues(alpha: 0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Layers from the bottom of the trench upward.
    final layers = <(double, double, String, String, Paint)>[
      (h * 0.90, h * 0.84, 'বালি ভরাট', 'Sand filling',
          Paint()..color = palette.concrete.withValues(alpha: 0.45)),
      (h * 0.84, h * 0.78, 'ইটের সোলিং', 'Brick soling',
          Paint()..color = palette.steel.withValues(alpha: 0.22)),
      (h * 0.78, h * 0.70, 'মাস কনক্রিট', 'Mass concrete', concrete),
    ];
    for (final (bottom, top, labelBn, labelEn, paint) in layers) {
      final r = Rect.fromLTRB(cx - w * 0.26, top, cx + w * 0.26, bottom);
      canvas.drawRect(r, paint);
      canvas.drawRect(r, outline);
      paintLeader(canvas, Offset(cx + w * 0.30, (top + bottom) / 2),
          Offset(cx + w * 0.24, (top + bottom) / 2), palette.muted);
      paintLabel(canvas, bn ? labelBn : labelEn,
          Offset(cx + w * 0.32, (top + bottom) / 2 - 7),
          colour: palette.muted, size: 9.5, maxWidth: w * 0.32);
    }

    // Wall rising out of the trench, narrower than the footing.
    final wall = Rect.fromLTRB(cx - w * 0.09, h * 0.10, cx + w * 0.09, h * 0.70);
    canvas.drawRect(wall, Paint()..color = palette.concrete);
    canvas.drawRect(wall, outline);

    // The damp proof course, the thin line that decides the wall's future.
    final dpcY = h * 0.30;
    final dpc = Rect.fromLTRB(wall.left, dpcY - 3, wall.right, dpcY + 3);
    canvas.drawRect(dpc, Paint()..color = palette.accent);
    paintLeader(canvas, Offset(w * 0.30, dpcY - 14),
        Offset(wall.left + 2, dpcY), palette.accent);
    paintLabel(
      canvas,
      bn ? 'ডিপিসি — মাটির পানি এখানেই আটকায়' : 'DPC — where rising damp stops',
      Offset(w * 0.02, dpcY - 26),
      colour: palette.accent,
      size: 9.5,
      weight: FontWeight.w600,
      maxWidth: w * 0.29,
    );

    // Finished floor and the road it is measured against.
    final floorY = h * 0.22;
    canvas.drawLine(Offset(wall.right, floorY), Offset(w * 0.97, floorY),
        Paint()..color = palette.muted..strokeWidth = 1.2);
    paintLabel(canvas, bn ? 'মেঝের লেভেল' : 'Floor level',
        Offset(w * 0.74, floorY - 15),
        colour: palette.muted, size: 9.5, maxWidth: w * 0.24);

    // Measured immediately beside the wall, so the line and the thing it
    // measures are read together rather than across an empty page.
    paintDimension(
      canvas,
      Offset(wall.left - w * 0.05, ground),
      Offset(wall.left - w * 0.05, floorY),
      bn ? 'প্লিন্থ' : 'plinth',
      palette.ink,
    );
    paintLabel(
      canvas,
      bn
          ? 'রাস্তার লেভেল থেকে মেঝে কত উঁচু — বাড়ি হয়ে যাওয়ার পরও এটা মাপা যায়'
          : 'Floor height above the road: the one layer here still measurable '
              'years later',
      Offset(w * 0.02, h * 0.94),
      colour: palette.muted,
      size: 9.5,
      maxWidth: w * 0.96,
    );
  }

  @override
  bool shouldRepaint(covariant FootingSectionPainter old) =>
      old.palette != palette || old.bn != bn;
}
