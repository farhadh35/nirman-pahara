import 'package:flutter/material.dart';

import '../core/content/content_repository.dart';
import '../features/home/ui/home_screen.dart';
import '../features/prices/logic/sor_rate_store.dart';
import '../features/inspection/logic/evidence_store.dart';
import '../features/inspection/logic/inspection_store.dart';
import 'app_scope.dart';
import 'app_state.dart';
import 'theme.dart';

class NirmanPaharaApp extends StatelessWidget {
  const NirmanPaharaApp({
    super.key,
    required this.state,
    required this.content,
    required this.store,
    required this.evidence,
    required this.rates,
  });

  final AppState state;
  final ContentRepository content;
  final InspectionStore store;
  final EvidenceStore evidence;
  final SorRateStore rates;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      content: content,
      store: store,
      evidence: evidence,
      rates: rates,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) => MaterialApp(
          title: 'Nirman Pahara',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: state.textScale.factor,
            maxScaleFactor: state.textScale.factor * 1.3,
            child: _ReadableWidth(child: child!),
          ),
          home: state.onboarded
              ? const HomeScreen()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}

/// Holds the page to a readable column on a wide screen.
///
/// Every screen in this app is a single column of prose, forms and cards, and
/// on a ten-inch tablet that column was running the full 1600 pixels: a line of
/// Bangla stretched right across the glass, and a card whose title sat at one
/// edge with its chevron at the other. Neither is unusable, but both are worse
/// than the phone the app was designed on, which is a strange thing to ship on
/// the larger device.
///
/// 720 logical pixels is about the width of a large phone, and it is the point
/// past which a line of text starts costing the reader effort to track back to
/// the next one. Below that this does nothing at all, so phones are untouched.
class _ReadableWidth extends StatelessWidget {
  const _ReadableWidth({required this.child});

  final Widget child;

  static const double maxWidth = 720;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width <= maxWidth) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
