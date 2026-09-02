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
            child: child!,
          ),
          home: state.onboarded
              ? const HomeScreen()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}
