import 'package:flutter/material.dart';

import 'diagram_base.dart';

/// A drain trap, and why a house smells when it dries out.
///
/// The commonest complaint in a finished building, and the commonest thing
/// nobody can explain: the bend under a drain holds a little water, and that
/// water is the only thing between the room and the gas in the pipe below. It
/// is not a filter or a valve — it is a plug made of water, and it evaporates.
///
/// Drawn as the working case beside the dried-out one, because the difference
/// is a few centimetres of water and is otherwise invisible.
class TrapPainter extends CustomPainter {
  TrapPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    if (diagramTooSmall(size)) return;
    final half = size.width / 2;
    _trap(canvas, Rect.fromLTWH(0, 0, half, size.height), sealed: true);
    _trap(canvas, Rect.fromLTWH(half, 0, half, size.height), sealed: false);
  }

  void _trap(Canvas canvas, Rect cell, {required bool sealed}) {
    paintLabel(
      canvas,
      sealed
          ? (bn ? 'পানি আছে — গন্ধ আটকে' : 'Water in it: the gas is stopped')
          : (bn ? 'পানি শুকিয়ে গেছে' : 'Dried out'),
      Offset(cell.center.dx, cell.top + 5),
      colour: sealed ? palette.accent : palette.steel,
      size: 10.5,
      weight: FontWeight.w600,
      centreOnPoint: true,
      maxWidth: cell.width,
    );

    final cx = cell.center.dx;
    final top = cell.top + cell.height * 0.22;
    final bendY = cell.bottom - cell.height * 0.30;
    final pipeW = cell.width * 0.13;

    final wall = Paint()
      ..color = palette.muted
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    // A U bend: down from the floor grating, round, and away to the drain.
    final path = Path()
      ..moveTo(cx - pipeW, top)
      ..lineTo(cx - pipeW, bendY)
      ..quadraticBezierTo(cx, bendY + cell.height * 0.16, cx + pipeW, bendY)
      ..lineTo(cx + pipeW, top + cell.height * 0.14)
      ..lineTo(cx + cell.width * 0.30, top + cell.height * 0.14);
    canvas.drawPath(path, wall);

    if (sealed) {
      // The plug of water sitting in the bend.
      final water = Path()
        ..moveTo(cx - pipeW, bendY - cell.height * 0.04)
        ..lineTo(cx - pipeW, bendY)
        ..quadraticBezierTo(cx, bendY + cell.height * 0.16, cx + pipeW, bendY)
        ..lineTo(cx + pipeW, bendY - cell.height * 0.04)
        ..quadraticBezierTo(cx, bendY + cell.height * 0.10, cx - pipeW,
            bendY - cell.height * 0.04)
        ..close();
      canvas.drawPath(water, Paint()..color = palette.water);
      paintLeader(canvas, Offset(cell.left + cell.width * 0.06, bendY - cell.height * 0.16),
          Offset(cx - pipeW * 0.3, bendY + cell.height * 0.06), palette.water);
      paintLabel(canvas, bn ? 'এই টুকু পানিই' : 'this much water',
          Offset(cell.left + 4, bendY - cell.height * 0.24),
          colour: palette.water, size: 9, weight: FontWeight.w600,
          maxWidth: cell.width * 0.44);
    } else {
      // Gas coming back up the empty bend.
      final arrow = Paint()
        ..color = palette.steel
        ..strokeWidth = 1.8;
      for (var i = 0; i < 3; i++) {
        final y = bendY - cell.height * (0.08 + i * 0.10);
        canvas.drawLine(Offset(cx, y + 6), Offset(cx, y - 4), arrow);
        canvas.drawLine(Offset(cx - 3.5, y), Offset(cx, y - 5), arrow);
        canvas.drawLine(Offset(cx + 3.5, y), Offset(cx, y - 5), arrow);
      }
      paintLabel(canvas, bn ? 'গন্ধ উঠে আসে' : 'the smell comes up',
          Offset(cell.left + 4, top - 2),
          colour: palette.steel, size: 9, weight: FontWeight.w600,
          maxWidth: cell.width * 0.44);
    }

    paintLabel(
      canvas,
      sealed
          ? (bn
              ? 'বাঁকা অংশে জমে থাকা পানিই নিচের গ্যাস আটকায়'
              : 'The water standing in the bend is what blocks the gas below')
          : (bn
              ? 'অনেকদিন ব্যবহার না হলে পানি শুকায় — এক মগ পানি ঢাললেই সারে'
              : 'Unused for long enough it evaporates. A mug of water fixes it'),
      Offset(cell.left + 6, cell.bottom - cell.height * 0.12),
      colour: sealed ? palette.muted : palette.steel,
      size: 9,
      maxWidth: cell.width - 12,
    );
  }

  @override
  bool shouldRepaint(covariant TrapPainter old) =>
      old.palette != palette || old.bn != bn;
}
