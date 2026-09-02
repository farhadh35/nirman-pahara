import 'package:flutter/material.dart';

/// Holds the page to a readable column on a wide screen.
///
/// Every screen in this app is a single column of prose, forms and cards, and
/// on a ten-inch tablet that column was running the full 1600 pixels: a line of
/// Bangla stretched right across the glass, and a card whose title sat at one
/// edge with its chevron at the other. Neither is unusable, but both are worse
/// than the phone the app was designed on, which is a strange thing to ship on
/// the larger device.
///
/// The number matters, and the first attempt got it wrong. 720dp trimmed a
/// ten-inch tablet — 800dp wide — to ninety per cent of itself, which is a
/// change nobody can see. 600dp is the top of Material's compact window class
/// and about as wide as a line of text can run before a reader starts losing
/// their place on the way back to the next one. On that tablet it leaves a
/// hundred density-independent pixels of margin each side, which reads as
/// deliberate rather than as a phone layout that got stretched.
///
/// A seven-inch tablet is exactly 600dp, and a phone is around 411dp, so
/// neither is touched. A phone turned landscape is wider than 600dp and is.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child});

  final Widget child;

  static const double maxWidth = 600;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width <= maxWidth) return child;
    // The colour matters as much as the constraint. This sits above the
    // Scaffold, so nothing paints what the column no longer covers, and the
    // first version left a black bar down each side of a tablet — worse
    // looking than the stretched layout it replaced.
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
