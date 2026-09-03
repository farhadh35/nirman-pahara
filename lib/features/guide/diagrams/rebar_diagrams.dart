import 'package:flutter/material.dart';

import 'diagram_base.dart';

/// Stirrup spacing along a beam: close at the ends, wider in the middle.
///
/// Counter-intuitive to anyone who has not been told, which is why it is worth
/// a picture. A beam fails in shear near its supports, not at mid-span, so that
/// is where the rings are needed most. Evenly spaced rings all the way along —
/// which looks tidier and uses less steel — is a beam built to fail at the ends.
///
/// The check is a count, not a judgement: pace the first metre from the support
/// and the middle of the span, and see whether the spacing changes.
class StirrupSpacingPainter extends CustomPainter {
  StirrupSpacingPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final w = size.width;
    final h = size.height;
    _beam(canvas, Rect.fromLTWH(0, 0, w, h * 0.5), correct: true);
    _beam(canvas, Rect.fromLTWH(0, h * 0.5, w, h * 0.5), correct: false);
  }

  void _beam(Canvas canvas, Rect cell, {required bool correct}) {
    paintLabel(
      canvas,
      correct
          ? (bn ? 'যেভাবে হওয়ার কথা' : 'How it should be')
          : (bn ? 'যেভাবে প্রায়ই হয়' : 'How it often is'),
      Offset(cell.left + 6, cell.top + 4),
      colour: correct ? palette.accent : palette.steel,
      size: 10.5,
      weight: FontWeight.w600,
      maxWidth: cell.width * 0.5,
    );

    final beam = Rect.fromLTRB(
      cell.left + cell.width * 0.10,
      cell.top + cell.height * 0.34,
      cell.right - cell.width * 0.10,
      cell.top + cell.height * 0.74,
    );
    canvas.drawRect(beam, Paint()..color = palette.concrete);
    canvas.drawRect(
      beam,
      Paint()
        ..color = palette.muted.withValues(alpha: 0.6)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // Supports at each end, so "near the support" means something.
    final support = Paint()..color = palette.muted.withValues(alpha: 0.55);
    for (final x in [beam.left, beam.right]) {
      canvas.drawRect(
        Rect.fromLTRB(x - beam.width * 0.035, beam.bottom,
            x + beam.width * 0.035, beam.bottom + cell.height * 0.10),
        support,
      );
    }

    final ring = Paint()
      ..color = palette.steel
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final xs = <double>[];
    if (correct) {
      // Tight for the first quarter at each end, open through the middle.
      final endZone = beam.width * 0.25;
      for (var x = beam.left + 5; x < beam.left + endZone; x += beam.width * 0.035) {
        xs.add(x);
      }
      for (var x = beam.left + endZone;
          x < beam.right - endZone;
          x += beam.width * 0.085) {
        xs.add(x);
      }
      for (var x = beam.right - endZone; x < beam.right - 4; x += beam.width * 0.035) {
        xs.add(x);
      }
    } else {
      for (var x = beam.left + 5; x < beam.right - 4; x += beam.width * 0.075) {
        xs.add(x);
      }
    }
    for (final x in xs) {
      canvas.drawRect(
        Rect.fromLTRB(x, beam.top + 4, x + 1.4, beam.bottom - 4),
        ring,
      );
    }

    // The two main bars, so the rings read as rings round something.
    final bar = Paint()
      ..color = palette.steel
      ..strokeWidth = 2.2;
    canvas.drawLine(Offset(beam.left + 3, beam.top + 6),
        Offset(beam.right - 3, beam.top + 6), bar);
    canvas.drawLine(Offset(beam.left + 3, beam.bottom - 6),
        Offset(beam.right - 3, beam.bottom - 6), bar);

    if (correct) {
      paintDimension(
        canvas,
        Offset(beam.left, cell.top + cell.height * 0.24),
        Offset(beam.left + beam.width * 0.25, cell.top + cell.height * 0.24),
        bn ? 'ঘন' : 'close',
        palette.accent,
      );
      paintDimension(
        canvas,
        Offset(beam.left + beam.width * 0.25, cell.top + cell.height * 0.24),
        Offset(beam.right - beam.width * 0.25, cell.top + cell.height * 0.24),
        bn ? 'ফাঁক বেশি' : 'wider',
        palette.muted,
      );
    }

    paintLabel(
      canvas,
      correct
          ? (bn
              ? 'দুই প্রান্তের কাছে রিং ঘন — বিম ভাঙে ওখানেই, মাঝখানে নয়'
              : 'Rings close near the supports: a beam fails there, not at '
                  'mid-span')
          : (bn
              ? 'পুরো বিমে সমান ফাঁক — দেখতে পরিপাটি, প্রান্তের দিকে দুর্বল'
              : 'Evenly spaced all along: tidier, and weak exactly where it '
                  'matters'),
      Offset(cell.left + 6, beam.bottom + cell.height * 0.14),
      colour: correct ? palette.muted : palette.steel,
      size: 9.5,
      maxWidth: cell.width - 12,
    );
  }

  @override
  bool shouldRepaint(covariant StirrupSpacingPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// A slab's steel seen from above and in section: main bars one way,
/// distribution bars across, extra top bars over the supports.
///
/// Everything here is countable while the deck is open, and invisible an hour
/// after the pour starts. Spacing is the thing to measure — bars at 6 inches
/// where the drawing says 5 is a fifth of the steel missing, and it looks
/// identical from the ground.
class SlabRebarPainter extends CustomPainter {
  SlabRebarPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final w = size.width;
    final h = size.height;
    final plan = Rect.fromLTRB(w * 0.06, h * 0.22, w * 0.52, h * 0.78);
    final sect = Rect.fromLTRB(w * 0.60, h * 0.34, w * 0.96, h * 0.62);

    paintLabel(canvas, bn ? 'উপর থেকে' : 'Seen from above',
        Offset(plan.left, h * 0.06),
        colour: palette.ink, size: 10.5, weight: FontWeight.w600,
        maxWidth: plan.width);
    paintLabel(canvas, bn ? 'কাটা অংশ' : 'In section',
        Offset(sect.left, h * 0.06),
        colour: palette.ink, size: 10.5, weight: FontWeight.w600,
        maxWidth: sect.width);

    canvas.drawRect(plan, Paint()..color = palette.concrete);
    canvas.drawRect(
        plan,
        Paint()
          ..color = palette.muted.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke);

    // Main bars carry the load and are heavier; distribution bars tie them
    // together and are drawn lighter, because telling the two apart on site is
    // most of what this diagram is for.
    final main = Paint()
      ..color = palette.steel
      ..strokeWidth = 2.6;
    final dist = Paint()
      ..color = palette.steel.withValues(alpha: 0.38)
      ..strokeWidth = 1.2;

    final gap = plan.width * 0.135;
    for (var x = plan.left + gap * 0.7; x < plan.right - 4; x += gap) {
      canvas.drawLine(Offset(x, plan.top + 4), Offset(x, plan.bottom - 4), main);
    }
    for (var y = plan.top + plan.height * 0.16;
        y < plan.bottom - 4;
        y += plan.height * 0.22) {
      canvas.drawLine(Offset(plan.left + 4, y), Offset(plan.right - 4, y), dist);
    }

    // The spacing dimension sits on the bars it measures, not off the edge.
    paintDimension(
      canvas,
      Offset(plan.left + gap * 0.7, plan.top - 12),
      Offset(plan.left + gap * 1.7, plan.top - 12),
      bn ? 'এই ফাঁকটা মাপুন' : 'measure this gap',
      palette.accent,
    );
    paintLabel(canvas, bn ? 'মূল রড' : 'main bars',
        Offset(plan.left + 6, plan.bottom + 8),
        colour: palette.steel, size: 9, weight: FontWeight.w600,
        maxWidth: plan.width * 0.45);
    paintLabel(canvas, bn ? 'আড়াআড়ি রড' : 'distribution bars',
        Offset(plan.left + plan.width * 0.5, plan.bottom + 8),
        // Full strength: the alpha was there to rank this label below the one
        // above it, but it is nine-point text and 0.7 dropped it to 3.7:1,
        // under the 4.5:1 text floor. The words already say which bars these
        // are; the colour does not have to.
        colour: palette.steel, size: 9,
        maxWidth: plan.width * 0.5);

    // Section: the slab, bottom steel, and the extra top steel over a support.
    canvas.drawRect(sect, Paint()..color = palette.concrete);
    canvas.drawRect(
        sect,
        Paint()
          ..color = palette.muted.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke);
    final bottomY = sect.bottom - sect.height * 0.26;
    final topY = sect.top + sect.height * 0.26;
    for (var x = sect.left + 6; x < sect.right - 4; x += sect.width * 0.10) {
      canvas.drawCircle(Offset(x, bottomY), 2.1, Paint()..color = palette.steel);
    }
    // Top bars only over the support, which is where the slab bends the other way.
    canvas.drawLine(Offset(sect.left + 4, topY),
        Offset(sect.left + sect.width * 0.34, topY), main);
    paintLeader(canvas, Offset(sect.left + sect.width * 0.20, sect.top - 14),
        Offset(sect.left + sect.width * 0.16, topY), palette.accent);
    paintLabel(
      canvas,
      bn ? 'সাপোর্টের উপরে বাড়তি রড' : 'extra bars over the support',
      Offset(sect.left, sect.top - 26),
      colour: palette.accent,
      size: 9,
      maxWidth: sect.width,
    );

    paintLabel(
      canvas,
      bn
          ? 'ঢালাই শুরু হলে এর কিছুই আর দেখা যাবে না। ফাঁক মেপে নিন আগেই।'
          : 'None of this is visible once the pour starts. Measure the spacing '
              'first.',
      Offset(w * 0.06, h * 0.91),
      colour: palette.muted,
      size: 9.5,
      maxWidth: w * 0.88,
    );
  }

  @override
  bool shouldRepaint(covariant SlabRebarPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// The hook at a bar's end, and what its length is measured from.
///
/// Twelve diameters, which is a number a person can work out for the bar in
/// front of them rather than look up. Drawn with the bend and the straight tail
/// separated, because "12d" means the tail, and a hook bent short is the common
/// way of saving steel that nobody notices.
class StandardHookPainter extends CustomPainter {
  StandardHookPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final w = size.width;
    final h = size.height;
    final bar = Paint()
      ..color = palette.steel
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = h * 0.54;
    final startX = w * 0.10;
    final bendX = w * 0.62;
    final radius = h * 0.13;

    // The straight run, then a 180 degree bend, then the tail that is measured.
    canvas.drawLine(Offset(startX, y), Offset(bendX, y), bar);
    final arc = Rect.fromCircle(
        center: Offset(bendX, y - radius), radius: radius);
    canvas.drawArc(arc, 1.5708, -3.1416, false, bar);
    final tailY = y - radius * 2;
    final tailEnd = bendX - w * 0.22;
    canvas.drawLine(Offset(bendX, tailY), Offset(tailEnd, tailY), bar);

    paintDimension(
      canvas,
      Offset(tailEnd, tailY - h * 0.14),
      Offset(bendX, tailY - h * 0.14),
      bn ? '১২ × ব্যাস' : '12 × diameter',
      palette.accent,
    );

    paintLeader(canvas, Offset(w * 0.16, y + h * 0.20),
        Offset(startX + w * 0.16, y), palette.muted);
    paintLabel(canvas, bn ? 'রডের মূল অংশ' : 'the bar itself',
        Offset(w * 0.06, y + h * 0.22),
        colour: palette.muted, size: 9.5, maxWidth: w * 0.34);

    paintLabel(
      canvas,
      bn
          ? '১২ গুণ মানে রডের ব্যাসের ১২ গুণ — ১০ মিমি রডে ১২০ মিমি। '
              'বাঁকের পরের সোজা অংশটাই মাপা হয়।'
          : 'Twelve times the bar diameter: 120 mm on a 10 mm bar. What is '
              'measured is the straight tail after the bend.',
      Offset(w * 0.06, h * 0.84),
      colour: palette.muted,
      size: 9.5,
      maxWidth: w * 0.88,
    );
  }

  @override
  bool shouldRepaint(covariant StandardHookPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// The end of a column tie, bent 135 degrees into the core, against the 90
/// degree bend that opens out.
///
/// The single most checkable thing in seismic detailing, and one of the least
/// known outside the trade. A tie is what stops a column's main bars buckling
/// outward when the building sways. Bent at 90 degrees the hook sits in the
/// cover concrete, which spalls off first in an earthquake — and once the cover
/// is gone the tie unwinds and the column loses its ties exactly when it needs
/// them. Bent at 135 degrees the hook is anchored inside the core, where the
/// concrete is confined and stays put.
///
/// Drawn as a section through a column, because that is the view a person gets
/// looking down into the cage before the pour.
class SeismicTiePainter extends CustomPainter {
  SeismicTiePainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final half = size.width / 2;
    _tie(canvas, Rect.fromLTWH(0, 0, half, size.height), good: true);
    _tie(canvas, Rect.fromLTWH(half, 0, half, size.height), good: false);
  }

  void _tie(Canvas canvas, Rect cell, {required bool good}) {
    paintLabel(
      canvas,
      good
          ? (bn ? '১৩৫° — ভেতরের দিকে' : '135°, turned into the core')
          : (bn ? '৯০° — কভারের মধ্যে' : '90°, sitting in the cover'),
      Offset(cell.center.dx, cell.top + 5),
      colour: good ? palette.accent : palette.steel,
      size: 10.5,
      weight: FontWeight.w600,
      centreOnPoint: true,
      maxWidth: cell.width,
    );

    final s = cell.width * 0.44;
    final col = Rect.fromCenter(
        center: Offset(cell.center.dx, cell.center.dy + cell.height * 0.04),
        width: s, height: s);

    // Column section, with the cover shown as a band inside the face.
    canvas.drawRect(col, Paint()..color = palette.concrete);
    canvas.drawRect(
        col,
        Paint()
          ..color = palette.muted
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke);
    final cover = col.deflate(s * 0.13);
    canvas.drawRect(
        cover,
        Paint()
          ..color = palette.muted.withValues(alpha: 0.35)
          ..strokeWidth = 0.9
          ..style = PaintingStyle.stroke);

    // The tie itself, running just inside the cover line.
    final steel = Paint()
      ..color = good ? palette.accent : palette.steel
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(cover, steel);

    // Four main bars at the corners.
    for (final p in [
      cover.topLeft, cover.topRight, cover.bottomLeft, cover.bottomRight,
    ]) {
      canvas.drawCircle(p, s * 0.055, Paint()..color = palette.steel);
    }

    // The hook at the top right corner: inward for 135, outward for 90.
    final c = cover.topRight;
    final hook = Path()..moveTo(c.dx, c.dy);
    if (good) {
      hook.lineTo(c.dx - s * 0.20, c.dy + s * 0.20);
    } else {
      hook.lineTo(c.dx + s * 0.16, c.dy - s * 0.02);
    }
    canvas.drawPath(hook, steel);

    paintLeader(
      canvas,
      Offset(cell.center.dx + (good ? -s * 0.75 : s * 0.55), cell.top + cell.height * 0.26),
      good ? Offset(c.dx - s * 0.16, c.dy + s * 0.16) : Offset(c.dx + s * 0.12, c.dy),
      good ? palette.accent : palette.steel,
    );

    paintLabel(
      canvas,
      good
          ? (bn
              ? 'হুক কংক্রিটের ভেতরের শক্ত অংশে আটকে থাকে'
              : 'The hook is anchored in the confined core')
          : (bn
              ? 'কভার খসে পড়লেই হুক ছুটে যায়, রিং খুলে যায়'
              : 'When the cover spalls the hook is free and the tie unwinds'),
      Offset(cell.left + 6, cell.bottom - cell.height * 0.13),
      colour: good ? palette.muted : palette.steel,
      size: 9,
      maxWidth: cell.width - 12,
    );
  }

  @override
  bool shouldRepaint(covariant SeismicTiePainter old) =>
      old.palette != palette || old.bn != bn;
}
