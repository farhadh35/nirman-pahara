import 'package:flutter/material.dart';

import 'diagram_base.dart';

/// The bottle test for silt in sand, in the four steps it actually takes.
///
/// The most useful field test there is, because it needs a clear bottle and
/// three hours and nothing else, and because silty sand is one of the easiest
/// things to be sold. Silt is lighter than sand, so it settles last and sits on
/// top as its own band. Reading the two bands against each other is the test.
///
/// The 6% figure is what the app checks against; it is drawn to scale here so
/// the band a reader sees on the page is the size of the band that matters.
class SiltTestPainter extends CustomPainter {
  SiltTestPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  /// Silt above this share of the sand depth is worth a conversation.
  static const double limitPercent = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final w = size.width;
    final h = size.height;
    final panelW = w / 4;
    final steps = bn
        ? ['১. বালি', '২. পানি', '৩. ঝাঁকান', '৪. ৩ ঘণ্টা রাখুন']
        : ['1. Sand', '2. Water', '3. Shake', '4. Stand 3 hours'];
    final captions = bn
        ? [
            'বোতলের এক-তৃতীয়াংশ বালি',
            'উপরে পানি, তিন-চতুর্থাংশ পর্যন্ত',
            'জোরে ঝাঁকিয়ে রেখে দিন',
            'পলি উপরে আলাদা স্তর হয়ে বসবে',
          ]
        : [
            'Bottle one third full of sand',
            'Water on top, up to three quarters',
            'Shake hard, then set it down',
            'Silt settles on top as its own band',
          ];

    for (var i = 0; i < 4; i++) {
      _bottle(canvas, Rect.fromLTWH(i * panelW, 0, panelW, h), i,
          steps[i], captions[i]);
    }
  }

  void _bottle(Canvas canvas, Rect cell, int step, String title, String caption) {
    final cx = cell.center.dx;
    final bw = cell.width * 0.42;
    final top = cell.top + cell.height * 0.20;
    final bottom = cell.top + cell.height * 0.72;
    final body = Rect.fromLTRB(cx - bw / 2, top, cx + bw / 2, bottom);

    paintLabel(canvas, title, Offset(cx, cell.top + cell.height * 0.06),
        colour: palette.ink, size: 11, weight: FontWeight.w600,
        centreOnPoint: true, maxWidth: cell.width);

    // Neck, so it reads as a bottle rather than a beaker.
    final neck = Rect.fromLTRB(cx - bw * 0.16, top - cell.height * 0.08,
        cx + bw * 0.16, top);
    final glass = Paint()
      ..color = palette.muted.withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(neck, glass);

    final sandPaint = Paint()..color = palette.concrete;
    final siltPaint = Paint()..color = palette.steel.withValues(alpha: 0.45);
    final waterPaint = Paint()..color = palette.water.withValues(alpha: 0.6);

    final full = body.height;
    switch (step) {
      case 0:
        _fill(canvas, body, 0, full / 3, sandPaint);
      case 1:
        _fill(canvas, body, 0, full / 3, sandPaint);
        _fill(canvas, body, full / 3, full * 0.75, waterPaint);
      case 2:
        // Everything in suspension: one cloudy body, no bands yet.
        _fill(canvas, body, 0, full * 0.75,
            Paint()..color = palette.concrete.withValues(alpha: 0.55));
        for (var i = 0; i < 7; i++) {
          final y = bottom - full * 0.72 * (i + 0.5) / 7;
          canvas.drawCircle(Offset(cx - bw * 0.18 + (i.isEven ? bw * 0.3 : 0), y),
              1.6, Paint()..color = palette.steel.withValues(alpha: 0.5));
        }
      case 3:
        final sandTop = full / 3;
        final siltTop = sandTop + full * 0.035;
        _fill(canvas, body, 0, sandTop, sandPaint);
        _fill(canvas, body, sandTop, siltTop, siltPaint);
        _fill(canvas, body, siltTop, full * 0.75, waterPaint);

        // The two bands that are read against each other.
        paintDimension(
          canvas,
          Offset(body.right + 7, bottom),
          Offset(body.right + 7, bottom - sandTop),
          bn ? 'বালি' : 'sand',
          palette.muted,
        );
        paintLeader(
          canvas,
          Offset(body.right + 14, bottom - siltTop - 8),
          Offset(body.right - 3, bottom - (sandTop + siltTop) / 2),
          palette.steel,
        );
        paintLabel(
          canvas,
          bn ? 'পলি' : 'silt',
          Offset(body.right + 15, bottom - siltTop - 15),
          colour: palette.steel,
          size: 10,
          weight: FontWeight.w600,
        );
    }

    canvas.drawRect(body, glass);

    paintLabel(canvas, caption, Offset(cell.left + 4, cell.top + cell.height * 0.78),
        colour: palette.muted, size: 9.5, maxWidth: cell.width - 8);
  }

  void _fill(Canvas canvas, Rect body, double fromBottom, double toBottom,
      Paint paint) {
    canvas.drawRect(
      Rect.fromLTRB(body.left, body.bottom - toBottom, body.right,
          body.bottom - fromBottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SiltTestPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// The common brick bonds, seen as a wall face.
///
/// Which bond a wall is laid in decides whether it acts as one wall or two
/// leaves standing beside each other. A stretcher bond has no header showing at
/// all, which is exactly what a half-brick wall looks like — so seeing only
/// long faces on what was billed as a ten inch wall is worth a question.
class BrickBondPainter extends CustomPainter {
  BrickBondPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final half = size.width / 2;
    _bond(canvas, Rect.fromLTWH(0, 0, half, size.height), english: true);
    _bond(canvas, Rect.fromLTWH(half, 0, half, size.height), english: false);
  }

  void _bond(Canvas canvas, Rect cell, {required bool english}) {
    final title = english
        ? (bn ? 'ইংলিশ বন্ড' : 'English bond')
        : (bn ? 'ফ্লেমিশ বন্ড' : 'Flemish bond');
    paintLabel(canvas, title, Offset(cell.center.dx, cell.top + 4),
        colour: palette.ink, size: 11, weight: FontWeight.w600,
        centreOnPoint: true, maxWidth: cell.width);

    final area = Rect.fromLTRB(cell.left + 10, cell.top + cell.height * 0.20,
        cell.right - 10, cell.bottom - cell.height * 0.16);
    const courses = 6;
    final ch = area.height / courses;
    final stretcher = area.width / 4;
    final header = stretcher / 2;

    final brick = Paint()..color = palette.concrete;
    final joint = Paint()
      ..color = palette.muted.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final headerFace = Paint()..color = palette.steel.withValues(alpha: 0.28);

    for (var c = 0; c < courses; c++) {
      final y = area.top + c * ch;
      var x = area.left;
      // English alternates whole courses; Flemish alternates within a course.
      final headerCourse = english && c.isOdd;
      var useHeader = !english && c.isEven;
      while (x < area.right - 0.5) {
        final isHeader = headerCourse || (!english && useHeader);
        final bw = isHeader ? header : stretcher;
        final r = Rect.fromLTWH(x, y + 1, bw.clamp(0, area.right - x) - 1, ch - 2);
        canvas.drawRect(r, isHeader ? headerFace : brick);
        canvas.drawRect(r, joint);
        x += bw;
        if (!english) useHeader = !useHeader;
      }
    }

    paintLabel(
      canvas,
      english
          ? (bn
              ? 'এক সারি লম্বা মুখ, পরের সারি আড়াআড়ি মুখ'
              : 'One course all stretchers, the next all headers')
          : (bn
              ? 'একই সারিতে লম্বা আর আড়াআড়ি মুখ পাশাপাশি'
              : 'Stretchers and headers alternate within the course'),
      Offset(cell.left + 8, area.bottom + 6),
      colour: palette.muted,
      size: 9.5,
      maxWidth: cell.width - 16,
    );
  }

  @override
  bool shouldRepaint(covariant BrickBondPainter old) =>
      old.palette != palette || old.bn != bn;
}
