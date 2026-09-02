import 'package:flutter/material.dart';

import '../../../core/i18n/app_locale.dart';
import 'diagram_base.dart';
import 'materials_diagrams.dart';
import 'rebar_diagrams.dart';
import 'services_diagrams.dart';
import 'site_diagrams.dart';
import 'structure_diagrams.dart';

/// Column reinforcement: main bars, stirrups with inward hooks, cover blocks,
/// and the fact that stirrups close up near the ends.
class RodBindingPainter extends CustomPainter {
  RodBindingPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final colX = w * 0.30;
    final colW = w * 0.20;
    final top = h * 0.10;
    final bottom = h * 0.90;

    // Concrete column.
    final column = Rect.fromLTRB(colX, top, colX + colW, bottom);
    canvas.drawRect(column, Paint()..color = palette.concrete);
    canvas.drawRect(
      column,
      Paint()
        ..color = palette.muted.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke,
    );

    final steel = Paint()
      ..color = palette.steel
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final inset = colW * 0.22;

    // Four main bars seen edge on.
    for (final x in [colX + inset, colX + colW - inset]) {
      canvas.drawLine(Offset(x, top + 6), Offset(x, bottom - 6), steel);
    }

    // Stirrups: close together at both ends, wider in the middle.
    final ends = <double>[];
    for (var y = top + 14; y < top + h * 0.26; y += h * 0.045) {
      ends.add(y);
    }
    for (var y = bottom - 14; y > bottom - h * 0.26; y -= h * 0.045) {
      ends.add(y);
    }
    final middle = <double>[];
    for (var y = top + h * 0.32; y < bottom - h * 0.30; y += h * 0.10) {
      middle.add(y);
    }
    final ring = Paint()
      ..color = palette.steel
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final y in [...ends, ...middle]) {
      canvas.drawRect(
        Rect.fromLTRB(colX + inset * 0.6, y, colX + colW - inset * 0.6, y + 3),
        ring,
      );
    }

    // Cover blocks holding the steel off the formwork.
    final block = Paint()..color = palette.accent;
    for (final y in [top + h * 0.20, bottom - h * 0.20]) {
      canvas.drawRect(
          Rect.fromLTWH(colX + 1.5, y, inset * 0.5, 5), block);
      canvas.drawRect(
          Rect.fromLTWH(colX + colW - 1.5 - inset * 0.5, y, inset * 0.5, 5),
          block);
    }

    // Labels.
    final labelX = colX + colW + 26;
    paintLeader(canvas, Offset(labelX - 6, top + h * 0.16),
        Offset(colX + colW - inset, top + h * 0.16), palette.ink);
    paintLabel(
      canvas,
      bn ? 'দুই প্রান্তে রিং ঘন' : 'Rings close together at the ends',
      Offset(labelX, top + h * 0.10),
      colour: palette.ink,
      maxWidth: w - labelX - 8,
    );

    paintLeader(canvas, Offset(labelX - 6, h * 0.52),
        Offset(colX + colW - inset * 0.6, h * 0.52), palette.ink);
    paintLabel(
      canvas,
      bn ? 'মাঝখানে ফাঁক বেশি চলে' : 'Wider spacing allowed in the middle',
      Offset(labelX, h * 0.46),
      colour: palette.ink,
      maxWidth: w - labelX - 8,
    );

    paintLeader(canvas, Offset(colX - 12, bottom - h * 0.20 + 2),
        Offset(colX + 3, bottom - h * 0.20 + 2), palette.accent);
    paintLabel(
      canvas,
      bn ? 'কভার ব্লক' : 'Cover block',
      Offset(6, bottom - h * 0.20 - 14),
      colour: palette.accent,
      maxWidth: colX - 18,
    );

    paintLeader(canvas, Offset(colX - 12, top + h * 0.42),
        Offset(colX + inset, top + h * 0.42), palette.steel);
    paintLabel(
      canvas,
      bn ? 'মূল রড' : 'Main bar',
      Offset(6, top + h * 0.36),
      colour: palette.steel,
      maxWidth: colX - 18,
    );

    paintDimension(
      canvas,
      Offset(colX + colW * 0.5, top + 14),
      Offset(colX + colW * 0.5, top + 14 + h * 0.045),
      bn ? 'ঘন' : 'close',
      palette.muted,
    );
  }

  @override
  bool shouldRepaint(covariant RodBindingPainter old) =>
      old.bn != bn || old.palette != palette;
}

/// Curing: ponding on a slab, wet hessian on a column.
class CuringPainter extends CustomPainter {
  CuringPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Slab with a bund and standing water.
    final slabTop = h * 0.30;
    final slab = Rect.fromLTRB(w * 0.06, slabTop, w * 0.52, h * 0.46);
    canvas.drawRect(slab, Paint()..color = palette.concrete);
    final bundPaint = Paint()..color = palette.muted.withValues(alpha: 0.55);
    canvas.drawRect(
        Rect.fromLTRB(w * 0.06, slabTop - 9, w * 0.09, slabTop), bundPaint);
    canvas.drawRect(
        Rect.fromLTRB(w * 0.49, slabTop - 9, w * 0.52, slabTop), bundPaint);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.09, slabTop - 7, w * 0.49, slabTop),
      Paint()..color = palette.water,
    );

    paintLabel(canvas, bn ? 'ছাদে পানি জমিয়ে রাখা' : 'Ponding on a slab',
        Offset(w * 0.06, h * 0.10),
        colour: palette.ink, weight: FontWeight.w600, maxWidth: w * 0.42);
    paintLeader(canvas, Offset(w * 0.20, h * 0.19),
        Offset(w * 0.28, slabTop - 4), palette.accent);
    paintLabel(canvas, bn ? 'পানি সারাক্ষণ থাকতে হবে' : 'Water must stay',
        Offset(w * 0.06, h * 0.50),
        colour: palette.muted, maxWidth: w * 0.42);
    paintLeader(canvas, Offset(w * 0.10, h * 0.50),
        Offset(w * 0.075, slabTop - 5), palette.muted);

    // Column wrapped in wet hessian.
    final colX = w * 0.68;
    final colW = w * 0.12;
    final column = Rect.fromLTRB(colX, h * 0.22, colX + colW, h * 0.80);
    canvas.drawRect(column, Paint()..color = palette.concrete);
    final wrap = Paint()
      ..color = palette.water
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    for (var y = h * 0.28; y < h * 0.76; y += h * 0.09) {
      canvas.drawLine(Offset(colX - 3, y), Offset(colX + colW + 3, y), wrap);
    }

    paintLabel(canvas, bn ? 'কলামে ভেজা চটের বস্তা' : 'Wet hessian on a column',
        Offset(w * 0.56, h * 0.10),
        colour: palette.ink, weight: FontWeight.w600, maxWidth: w * 0.42);
    paintLeader(canvas, Offset(w * 0.62, h * 0.19),
        Offset(colX + colW / 2, h * 0.28), palette.accent);
    paintLabel(
        canvas,
        bn ? 'শুকিয়ে গেলে কিউরিং হচ্ছে না' : 'Dry sacking is not curing',
        Offset(w * 0.56, h * 0.84),
        colour: palette.muted,
        maxWidth: w * 0.42);
  }

  @override
  bool shouldRepaint(covariant CuringPainter old) =>
      old.bn != bn || old.palette != palette;
}

/// Plaster: a wall section showing the guide patches and the thickness.
class PlasterPainter extends CustomPainter {
  PlasterPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final wallLeft = w * 0.16;
    final wallRight = w * 0.56;

    // Brick wall, coursed.
    final wall = Rect.fromLTRB(wallLeft, h * 0.12, wallRight, h * 0.88);
    canvas.drawRect(wall, Paint()..color = palette.concrete);
    final joint = Paint()
      ..color = palette.muted.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var y = h * 0.20; y < h * 0.88; y += h * 0.11) {
      canvas.drawLine(Offset(wallLeft, y), Offset(wallRight, y), joint);
    }

    // Plaster coat on the right face.
    final coat = Rect.fromLTRB(wallRight, h * 0.12, wallRight + w * 0.05,
        h * 0.88);
    canvas.drawRect(coat, Paint()..color = palette.accent.withValues(alpha: 0.35));

    // Guide patches standing proud of the wall.
    for (final y in [h * 0.24, h * 0.52, h * 0.78]) {
      canvas.drawRect(
        Rect.fromLTWH(wallRight, y, w * 0.05, h * 0.05),
        Paint()..color = palette.accent,
      );
    }

    paintDimension(
      canvas,
      Offset(wallRight, h * 0.94),
      Offset(wallRight + w * 0.05, h * 0.94),
      bn ? 'পুরুত্ব' : 'thickness',
      palette.ink,
    );

    paintLeader(canvas, Offset(wallRight + w * 0.12, h * 0.24 + 6),
        Offset(wallRight + w * 0.05, h * 0.24 + 6), palette.accent);
    paintLabel(
      canvas,
      bn
          ? 'গাইড — এর সমান করে প্লাস্টার টানা হয়'
          : 'Guide patch — the plaster is screeded flush with it',
      Offset(wallRight + w * 0.14, h * 0.18),
      colour: palette.accent,
      maxWidth: w - wallRight - w * 0.16,
    );

    paintLabel(
      canvas,
      bn ? 'ইটের গাঁথুনি' : 'Brick wall',
      Offset(6, h * 0.46),
      colour: palette.muted,
      maxWidth: wallLeft - 10,
    );
    paintLeader(canvas, Offset(wallLeft - 8, h * 0.50),
        Offset(wallLeft + 6, h * 0.50), palette.muted);

    paintLabel(
      canvas,
      bn
          ? 'আগে দেয়াল ভিজিয়ে নিতে হয়'
          : 'The wall is wetted first',
      Offset(6, h * 0.72),
      colour: palette.muted,
      maxWidth: wallLeft + w * 0.02,
    );
  }

  @override
  bool shouldRepaint(covariant PlasterPainter old) =>
      old.bn != bn || old.palette != palette;
}

/// Everything that has to be right before a pour starts.
class RccPourPainter extends CustomPainter {
  RccPourPainter({required this.palette, required this.bn});

  final DiagramPalette palette;
  final bool bn;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final left = w * 0.20;
    final right = w * 0.66;
    final top = h * 0.30;
    final bottom = h * 0.72;

    // Formwork.
    final form = Paint()
      ..color = palette.muted
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(left, top - 8), Offset(left, bottom + 8), form);
    canvas.drawLine(Offset(right, top - 8), Offset(right, bottom + 8), form);
    canvas.drawLine(
        Offset(left, bottom), Offset(right, bottom), form);

    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      Paint()..color = palette.concrete,
    );

    // Steel mesh sitting on cover blocks.
    final steel = Paint()
      ..color = palette.steel
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final barY = bottom - (bottom - top) * 0.30;
    canvas.drawLine(Offset(left + 8, barY), Offset(right - 8, barY), steel);
    for (var x = left + 16; x < right - 8; x += (right - left) / 6) {
      canvas.drawLine(Offset(x, barY - 7), Offset(x, barY + 7), steel);
    }
    for (final x in [left + 20, (left + right) / 2, right - 22]) {
      canvas.drawRect(
        Rect.fromLTWH(x - 5, barY + 7, 10, bottom - barY - 7),
        Paint()..color = palette.accent,
      );
    }

    paintDimension(
      canvas,
      Offset(left + 20, barY + 7),
      Offset(left + 20, bottom),
      bn ? 'কভার' : 'cover',
      palette.ink,
    );

    paintLeader(canvas, Offset(right + 14, top + 4),
        Offset(right - 2, top + 6), palette.muted);
    paintLabel(
      canvas,
      bn ? 'ফর্মা — ফাঁক থাকলে সিমেন্টের পানি বেরিয়ে যায়'
          : 'Formwork — gaps let the cement paste run out',
      Offset(right + 16, top - 6),
      colour: palette.muted,
      maxWidth: w - right - 20,
    );

    paintLeader(canvas, Offset(right + 14, barY),
        Offset(right - 10, barY), palette.steel);
    paintLabel(
      canvas,
      bn ? 'রড — ঢালাইয়ের আগেই গুনে নিন' : 'Steel — count it before the pour',
      Offset(right + 16, barY - 8),
      colour: palette.steel,
      maxWidth: w - right - 20,
    );

    paintLabel(
      canvas,
      bn ? 'ঢালাই একটানা হওয়ার কথা' : 'A pour should be continuous',
      Offset(w * 0.06, h * 0.10),
      colour: palette.ink,
      weight: FontWeight.w600,
      maxWidth: w * 0.86,
    );
    paintLabel(
      canvas,
      bn
          ? 'মাঝপথে বেশিক্ষণ থামলে কোল্ড জয়েন্ট'
          : 'A long stop leaves a cold joint',
      Offset(w * 0.06, h * 0.82),
      colour: palette.muted,
      maxWidth: w * 0.86,
    );
  }

  @override
  bool shouldRepaint(covariant RccPourPainter old) =>
      old.bn != bn || old.palette != palette;
}

/// Looks a diagram up by the key a guide card carries.
/// Every diagram key the app can draw.
///
/// Content refers to a diagram by key, so this list and the switch below have to
/// agree; a test walks the list through [guideDiagram] to make sure they do.
/// Kept here rather than in the tests so there is one list and not three.
const kGuideDiagramKeys = <String>[
  'rod_binding',
  'curing',
  'plaster',
  'rcc_pour',
  'silt_test',
  'brick_bond',
  'cover_block',
  'footing_section',
  'stirrup_spacing',
  'slab_rebar',
  'standard_hook',
  'signboard',
  'measuring',
  'drawing_parts',
  'excavation',
  'bore_log',
  'plot_faces',
  'traps',
];

Widget? guideDiagram(BuildContext context, String? key, {required bool bn}) {
  if (key == null) return null;
  final palette = DiagramPalette.of(context);
  final (painter, ratio, caption) = switch (key) {
    'rod_binding' => (
        RodBindingPainter(palette: palette, bn: bn),
        1.5,
        const L10nText('রড বাঁধার ছক', 'Rod binding')
      ),
    'curing' => (
        CuringPainter(palette: palette, bn: bn),
        1.7,
        const L10nText('কিউরিং', 'Curing')
      ),
    'plaster' => (
        PlasterPainter(palette: palette, bn: bn),
        1.6,
        const L10nText('প্লাস্টার', 'Plaster')
      ),
    'rcc_pour' => (
        RccPourPainter(palette: palette, bn: bn),
        1.7,
        const L10nText('ঢালাই', 'The pour')
      ),
    'silt_test' => (
        SiltTestPainter(palette: palette, bn: bn),
        2.0,
        const L10nText('বালিতে পলি আছে কি না', 'Testing sand for silt')
      ),
    'brick_bond' => (
        BrickBondPainter(palette: palette, bn: bn),
        2.0,
        const L10nText('ইটের বন্ড', 'Brick bonds')
      ),
    'cover_block' => (
        CoverBlockPainter(palette: palette, bn: bn),
        1.9,
        const L10nText('কভার ব্লক', 'Cover blocks')
      ),
    'footing_section' => (
        FootingSectionPainter(palette: palette, bn: bn),
        1.4,
        const L10nText('ভিত থেকে মেঝে পর্যন্ত', 'From footing to floor')
      ),
    'stirrup_spacing' => (
        StirrupSpacingPainter(palette: palette, bn: bn),
        1.25,
        const L10nText('স্টিরাপের ফাঁক', 'Stirrup spacing')
      ),
    'slab_rebar' => (
        SlabRebarPainter(palette: palette, bn: bn),
        1.6,
        const L10nText('স্ল্যাবের রড', 'Slab reinforcement')
      ),
    'standard_hook' => (
        StandardHookPainter(palette: palette, bn: bn),
        2.1,
        const L10nText('রডের হুক', 'The hook at a bar end')
      ),
    'signboard' => (
        SignboardPainter(palette: palette, bn: bn),
        1.35,
        const L10nText('কাজের তথ্যবোর্ড', 'The work information board')
      ),
    'measuring' => (
        MeasuringPainter(palette: palette, bn: bn),
        2.2,
        const L10nText('ফিতে ধরার নিয়ম', 'Holding the tape')
      ),
    'drawing_parts' => (
        DrawingPartsPainter(palette: palette, bn: bn),
        1.5,
        const L10nText('নকশার যে অংশগুলো কাজে লাগে', 'The parts of a drawing that help')
      ),
    'excavation' => (
        ExcavationPainter(palette: palette, bn: bn),
        1.7,
        const L10nText('গর্ত কাটা', 'Cutting a trench')
      ),
    'bore_log' => (
        BoreLogPainter(palette: palette, bn: bn),
        1.15,
        const L10nText('বোর লগ', 'A bore log')
      ),
    'plot_faces' => (
        PlotFacesPainter(palette: palette, bn: bn),
        1.7,
        const L10nText('প্লটের সামনে, পাশ ও পিছন', 'Front, side and rear of a plot')
      ),
    'traps' => (
        TrapPainter(palette: palette, bn: bn),
        1.6,
        const L10nText('ট্র্যাপ — গন্ধ আটকানোর পানি', 'The trap, and the water that stops the smell')
      ),
    _ => (null, 1.0, const L10nText('', '')),
  };
  if (painter == null) return null;
  return DiagramFrame(
    painter: painter,
    aspectRatio: ratio,
    caption: caption,
    bn: bn,
  );
}
