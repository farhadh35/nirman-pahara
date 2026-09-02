import 'package:flutter/material.dart';

import 'diagram_base.dart';

/// The information board a public work is supposed to display, with the fields
/// that make it useful marked.
///
/// Drawn as a schematic and never as a realistic board: a picture convincing
/// enough to be mistaken for a real notice is a picture that can be screenshotted
/// and passed off as one. What matters here is which fields to look for and what
/// each is good for, not how the paint looks.
class SignboardPainter extends CustomPainter {
  SignboardPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final w = size.width;
    final h = size.height;
    final board = Rect.fromLTRB(w * 0.06, h * 0.10, w * 0.56, h * 0.80);

    // Posts, so it reads as a board at a site.
    final post = Paint()..color = palette.muted.withValues(alpha: 0.45);
    for (final x in [board.left + board.width * 0.18, board.right - board.width * 0.18]) {
      canvas.drawRect(
          Rect.fromLTRB(x - 2.5, board.bottom, x + 2.5, h * 0.94), post);
    }

    canvas.drawRect(board, Paint()..color = palette.concrete);
    canvas.drawRect(
      board,
      Paint()
        ..color = palette.muted
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );

    final rows = bn
        ? [
            ('প্যাকেজ / চুক্তি নম্বর', 'এই নম্বরে টেন্ডার খুঁজে পাবেন'),
            ('চুক্তিমূল্য', 'দৈর্ঘ্য দিয়ে ভাগ করলে প্রতি মিটারের দর'),
            ('দৈর্ঘ্য / পরিমাণ', 'ফিতে দিয়ে মিলিয়ে দেখা যায়'),
            ('শুরু ও শেষের তারিখ', 'দেরি হলে চুক্তিতে কী আছে'),
            ('বাস্তবায়নকারী সংস্থা', 'অভিযোগ এখান থেকেই শুরু'),
          ]
        : [
            ('Package / contract no.', 'finds the tender on the portal'),
            ('Contract value', 'divided by the length gives a rate per metre'),
            ('Length / quantity', 'can be checked with a tape'),
            ('Start and end dates', 'what the contract says about delay'),
            ('Implementing agency', 'where a complaint starts'),
          ];

    final rowH = board.height / (rows.length + 1);
    paintLabel(
      canvas,
      bn ? 'কাজের তথ্যবোর্ড' : 'Work information board',
      Offset(board.center.dx, board.top + rowH * 0.30),
      colour: palette.ink,
      size: 10,
      weight: FontWeight.w700,
      centreOnPoint: true,
      maxWidth: board.width,
    );

    for (var i = 0; i < rows.length; i++) {
      final y = board.top + rowH * (i + 1.1);
      canvas.drawLine(Offset(board.left + 6, y + rowH * 0.62),
          Offset(board.right - 6, y + rowH * 0.62),
          Paint()
            ..color = palette.muted.withValues(alpha: 0.35)
            ..strokeWidth = 0.8);
      paintLabel(canvas, rows[i].$1, Offset(board.left + 8, y),
          colour: palette.ink, size: 9, maxWidth: board.width - 16);

      // What the field is good for, out to the right of the board.
      paintLeader(canvas, Offset(board.right + w * 0.05, y + 4),
          Offset(board.right - 4, y + 4), palette.accent);
      paintLabel(canvas, rows[i].$2, Offset(board.right + w * 0.06, y - 2),
          colour: palette.accent, size: 9, maxWidth: w * 0.36);
    }

    paintLabel(
      canvas,
      bn
          ? 'এটি আঁকা নমুনা — কোনো প্রকৃত কাজের বোর্ড নয়। বোর্ড না থাকাটাও একটা তথ্য।'
          : 'A drawn example, not any real work\'s board. A board that is not '
              'there is itself worth recording.',
      Offset(w * 0.06, h * 0.88),
      colour: palette.muted,
      size: 9,
      maxWidth: w * 0.88,
    );
  }

  @override
  bool shouldRepaint(covariant SignboardPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// How to hold a tape, and the two mistakes that make a measurement useless.
///
/// A slack tape and a tape held at an angle both read long, and both look fine
/// while you are doing it. Someone reporting a dimension that turns out wrong
/// loses the argument and the credibility, so the technique matters as much as
/// the number.
class MeasuringPainter extends CustomPainter {
  MeasuringPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final third = size.width / 3;
    _panel(canvas, Rect.fromLTWH(0, 0, third, size.height), 0);
    _panel(canvas, Rect.fromLTWH(third, 0, third, size.height), 1);
    _panel(canvas, Rect.fromLTWH(third * 2, 0, third, size.height), 2);
  }

  void _panel(Canvas canvas, Rect cell, int kind) {
    final good = kind == 0;
    final titles = bn
        ? ['ঠিক', 'ঝুলে আছে', 'বাঁকা ধরা']
        : ['Right', 'Tape sagging', 'Held at an angle'];
    paintLabel(canvas, titles[kind], Offset(cell.center.dx, cell.top + 5),
        colour: good ? palette.accent : palette.steel,
        size: 10.5,
        weight: FontWeight.w600,
        centreOnPoint: true,
        maxWidth: cell.width);

    final a = Offset(cell.left + cell.width * 0.16, cell.top + cell.height * 0.44);
    final b = Offset(cell.right - cell.width * 0.16, cell.top + cell.height * 0.44);

    // The two faces being measured between.
    final face = Paint()..color = palette.concrete;
    canvas.drawRect(
        Rect.fromLTRB(a.dx - 10, a.dy - cell.height * 0.16, a.dx, a.dy + cell.height * 0.22),
        face);
    canvas.drawRect(
        Rect.fromLTRB(b.dx, b.dy - cell.height * 0.16, b.dx + 10, b.dy + cell.height * 0.22),
        face);

    final tape = Paint()
      ..color = good ? palette.accent : palette.steel
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    switch (kind) {
      case 0:
        canvas.drawLine(a, b, tape);
      case 1:
        final path = Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo((a.dx + b.dx) / 2, a.dy + cell.height * 0.20,
              b.dx, b.dy);
        canvas.drawPath(path, tape);
      case 2:
        canvas.drawLine(a, b + Offset(0, cell.height * 0.16), tape);
    }

    paintLabel(
      canvas,
      good
          ? (bn
              ? 'টান টান, আর দুই তলের সঙ্গে সমকোণে'
              : 'Pulled tight, and square to both faces')
          : kind == 1
              ? (bn
                  ? 'ঝুলে থাকলে মাপ বেশি আসে'
                  : 'A sagging tape reads long')
              : (bn
                  ? 'বাঁকা ধরলেও মাপ বেশি আসে'
                  : 'Held at an angle it also reads long'),
      Offset(cell.left + 6, cell.top + cell.height * 0.74),
      colour: good ? palette.muted : palette.steel,
      size: 9.5,
      maxWidth: cell.width - 12,
    );
  }

  @override
  bool shouldRepaint(covariant MeasuringPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// The parts of a drawing worth finding: the title block, the scale, a
/// dimension line and a section mark.
///
/// Most of a drawing is for the people building it. Four things on it are for
/// the person checking, and knowing where they sit turns an intimidating sheet
/// into something with four answers on it.
class DrawingPartsPainter extends CustomPainter {
  DrawingPartsPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final w = size.width;
    final h = size.height;
    final sheet = Rect.fromLTRB(w * 0.05, h * 0.10, w * 0.66, h * 0.90);
    canvas.drawRect(sheet, Paint()..color = palette.concrete.withValues(alpha: 0.35));
    canvas.drawRect(
      sheet,
      Paint()
        ..color = palette.muted
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // A simple plan on the sheet.
    final plan = Rect.fromLTRB(sheet.left + sheet.width * 0.12,
        sheet.top + sheet.height * 0.16, sheet.right - sheet.width * 0.16,
        sheet.top + sheet.height * 0.58);
    canvas.drawRect(
        plan,
        Paint()
          ..color = palette.ink.withValues(alpha: 0.75)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    // Title block, bottom right of the sheet as it always is.
    final title = Rect.fromLTRB(sheet.right - sheet.width * 0.42,
        sheet.bottom - sheet.height * 0.22, sheet.right - 4, sheet.bottom - 4);
    canvas.drawRect(title, Paint()..color = palette.concrete);
    canvas.drawRect(
        title,
        Paint()
          ..color = palette.muted
          ..style = PaintingStyle.stroke);

    // Dimension line under the plan.
    paintDimension(canvas, Offset(plan.left, plan.bottom + 14),
        Offset(plan.right, plan.bottom + 14), '', palette.accent);

    // Section mark on the plan.
    canvas.drawLine(Offset(plan.center.dx, plan.top - 6),
        Offset(plan.center.dx, plan.bottom + 6),
        Paint()
          ..color = palette.accent
          ..strokeWidth = 1.2);

    // Ordered so that a label and the thing it points at run down the page
    // together: leaders that cross each other turn four answers into a knot.
    final callouts = bn
        ? [
            ('সেকশন মার্ক', 'এখানে কাটলে ভেতরটা যে ছবিতে দেখাবে',
                Offset(plan.center.dx, plan.top - 4)),
            ('মাপের লাইন', 'এই সংখ্যাটাই ফিতে দিয়ে মেলাবেন',
                Offset(plan.right - plan.width * 0.2, plan.bottom + 14)),
            ('স্কেল', 'কাগজের ১ ইঞ্চি মানে বাস্তবে কত',
                Offset(title.right - title.width * 0.15, title.top + 6)),
            ('টাইটেল ব্লক', 'কাজের নাম, তারিখ, কে বানিয়েছে',
                Offset(title.right - title.width * 0.15, title.bottom - 8)),
          ]
        : [
            ('Section mark', 'where the drawing cuts through to show the inside',
                Offset(plan.center.dx, plan.top - 4)),
            ('Dimension line', 'the number you check with a tape',
                Offset(plan.right - plan.width * 0.2, plan.bottom + 14)),
            ('Scale', 'what one inch on paper means on the ground',
                Offset(title.right - title.width * 0.15, title.top + 6)),
            ('Title block', 'what the work is, dated, and by whom',
                Offset(title.right - title.width * 0.15, title.bottom - 8)),
          ];

    for (var i = 0; i < callouts.length; i++) {
      final y = h * (0.14 + i * 0.22);
      paintLeader(canvas, Offset(w * 0.70, y + 6), callouts[i].$3, palette.accent);
      paintLabel(canvas, callouts[i].$1, Offset(w * 0.71, y),
          colour: palette.accent, size: 9.5, weight: FontWeight.w600,
          maxWidth: w * 0.28);
      paintLabel(canvas, callouts[i].$2, Offset(w * 0.71, y + 12),
          colour: palette.muted, size: 8.5, maxWidth: w * 0.28);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPartsPainter old) =>
      old.palette != palette || old.bn != bn;
}

/// Why a deep trench with vertical sides is the most dangerous thing on an
/// ordinary site.
///
/// Soil does not give warning before it goes, and a cubic metre of it weighs
/// close to two tonnes. A person buried to the chest cannot be pulled out by
/// hand. Either the sides are cut back to a slope or they are held, and the
/// spoil is kept back from the edge so it is not loading the very face that has
/// to stand up.
class ExcavationPainter extends CustomPainter {
  ExcavationPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final half = size.width / 2;
    _trench(canvas, Rect.fromLTWH(0, 0, half, size.height), safe: true);
    _trench(canvas, Rect.fromLTWH(half, 0, half, size.height), safe: false);
  }

  void _trench(Canvas canvas, Rect cell, {required bool safe}) {
    paintLabel(
      canvas,
      safe
          ? (bn ? 'ঢালু করে কাটা' : 'Sides cut back')
          : (bn ? 'খাড়া কাটা' : 'Cut vertical'),
      Offset(cell.center.dx, cell.top + 5),
      colour: safe ? palette.accent : palette.steel,
      size: 10.5,
      weight: FontWeight.w600,
      centreOnPoint: true,
      maxWidth: cell.width,
    );

    final ground = cell.top + cell.height * 0.32;
    final base = cell.bottom - cell.height * 0.18;
    final earth = Paint()..color = palette.muted.withValues(alpha: 0.22);
    canvas.drawRect(
        Rect.fromLTRB(cell.left, ground, cell.right, cell.bottom), earth);

    final cx = cell.center.dx;
    final baseHalf = cell.width * 0.10;
    final topHalf = safe ? cell.width * 0.24 : cell.width * 0.10;

    final cut = Path()
      ..moveTo(cx - topHalf, ground)
      ..lineTo(cx - baseHalf, base)
      ..lineTo(cx + baseHalf, base)
      ..lineTo(cx + topHalf, ground)
      ..close();
    canvas.drawPath(cut, Paint()..color = palette.concrete.withValues(alpha: 0.5));
    canvas.drawPath(
        cut,
        Paint()
          ..color = safe ? palette.accent : palette.steel
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke);

    // Spoil heap: back from the edge when it is done right, on the edge when not.
    final spoilX = safe ? cx - topHalf - cell.width * 0.16 : cx - topHalf - 6;
    final spoil = Path()
      ..moveTo(spoilX - cell.width * 0.09, ground)
      ..lineTo(spoilX, ground - cell.height * 0.10)
      ..lineTo(spoilX + cell.width * 0.09, ground)
      ..close();
    canvas.drawPath(spoil, Paint()..color = palette.muted.withValues(alpha: 0.5));

    if (!safe) {
      paintLeader(canvas, Offset(cell.left + cell.width * 0.08, base - cell.height * 0.10),
          Offset(cx - baseHalf, (ground + base) / 2), palette.steel);
    }

    paintLabel(
      canvas,
      safe
          ? (bn
              ? 'পাশ ঢালু, আর মাটির স্তূপ গর্ত থেকে দূরে'
              : 'Sloped sides, and the spoil kept back from the edge')
          : (bn
              ? 'খাড়া পাশ, স্তূপ একদম কিনারায় — এভাবেই ধস নামে'
              : 'Vertical sides with the spoil loading the edge: this is how '
                  'they collapse'),
      Offset(cell.left + 6, cell.bottom - cell.height * 0.13),
      colour: safe ? palette.muted : palette.steel,
      size: 9.5,
      maxWidth: cell.width - 12,
    );
  }

  @override
  bool shouldRepaint(covariant ExcavationPainter old) =>
      old.palette != palette || old.bn != bn;
}
