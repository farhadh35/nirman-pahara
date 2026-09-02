import 'package:flutter/material.dart';

import '../../../core/i18n/app_locale.dart';

/// Shared drawing helpers for the guide's labelled diagrams.
///
/// The diagrams are painted rather than shipped as images for three reasons:
/// Bangla labels shape correctly because the same text engine draws them, the
/// colours follow the light and dark themes, and — the one that matters most —
/// every dimension shown is one this code put there. A generated illustration
/// of, say, stirrup spacing could show something subtly wrong, and this app
/// would then be teaching it.
class DiagramPalette {
  const DiagramPalette({
    required this.ink,
    required this.muted,
    required this.concrete,
    required this.steel,
    required this.accent,
    required this.water,
  });

  final Color ink;
  final Color muted;
  final Color concrete;
  final Color steel;
  final Color accent;
  final Color water;

  factory DiagramPalette.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DiagramPalette(
      ink: scheme.onSurface,
      muted: scheme.onSurfaceVariant,
      concrete: dark ? const Color(0xFF3A3F3A) : const Color(0xFFDDE3DA),
      steel: const Color(0xFF9A3412),
      accent: scheme.primary,
      water: dark ? const Color(0xFF2A4A5A) : const Color(0xFFBFE0F0),
    );
  }
}

/// Draws a short text label, returning the space it occupied.
Size paintLabel(
  Canvas canvas,
  String text,
  Offset at, {
  required Color colour,
  double size = 11,
  FontWeight weight = FontWeight.w500,
  TextAlign align = TextAlign.left,
  double maxWidth = 160,
  bool centreOnPoint = false,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: colour,
        fontSize: size,
        fontWeight: weight,
        fontFamily: 'NotoSansBengali',
        height: 1.35,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
  )..layout(maxWidth: maxWidth);
  final origin =
      centreOnPoint ? at - Offset(painter.width / 2, painter.height / 2) : at;
  painter.paint(canvas, origin);
  return painter.size;
}

/// A thin leader line from a label to the thing it names.
void paintLeader(Canvas canvas, Offset from, Offset to, Color colour) {
  final paint = Paint()
    ..color = colour.withValues(alpha: 0.7)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  canvas.drawLine(from, to, paint);
  canvas.drawCircle(to, 2.2, Paint()..color = colour);
}

/// A dimension line with arrowheads and a caption in the middle.
void paintDimension(
  Canvas canvas,
  Offset from,
  Offset to,
  String caption,
  Color colour,
) {
  final paint = Paint()
    ..color = colour
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  canvas.drawLine(from, to, paint);
  const arm = 4.0;
  final vertical = (to.dx - from.dx).abs() < 1;
  for (final end in [from, to]) {
    if (vertical) {
      canvas.drawLine(end - const Offset(arm, 0), end + const Offset(arm, 0),
          paint);
    } else {
      canvas.drawLine(end - const Offset(0, arm), end + const Offset(0, arm),
          paint);
    }
  }
  final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
  paintLabel(
    canvas,
    caption,
    vertical ? mid + const Offset(8, -8) : mid + const Offset(0, -18),
    colour: colour,
    size: 10,
    centreOnPoint: !vertical,
  );
}

/// Wraps a painter with a caption, so every diagram is labelled as a diagram
/// and never mistaken for a photograph of a real site.
class DiagramFrame extends StatelessWidget {
  const DiagramFrame({
    super.key,
    required this.painter,
    required this.aspectRatio,
    required this.caption,
    required this.bn,
  });

  final CustomPainter painter;
  final double aspectRatio;
  final L10nText caption;
  final bool bn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: CustomPaint(painter: painter, size: Size.infinite),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          bn
              ? 'ছক — মাপ নকশা থেকে দেখে নিন'
              : 'Diagram — take the dimensions from the drawing',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
