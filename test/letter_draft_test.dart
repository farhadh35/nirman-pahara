import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/rights_models.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/rights/ui/rights_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A Right to Information application is typed slowly, often off a paper the
/// reader is holding, and none of it is written down anywhere. One back
/// gesture used to take all of it, silently.
Future<Widget> _app(WidgetTester tester, Widget child) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  return AppScope(
    state: await AppState.load(),
    content: ContentRepository(reader: (p) => File(p).readAsString()),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('letter'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(home: child),
  );
}

void main() {
  late LetterTemplate letter;

  setUp(() async {
    final pack = await ContentRepository(reader: (p) => File(p).readAsString())
        .rights();
    letter = pack.letters.first;
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    late Widget app;
    await tester.runAsync(() async =>
        app = await _app(tester, LetterScreen(template: letter)));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('going back on a drafted letter asks first', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, 'রহিম উদ্দিন');
    await tester.pumpAndSettle();

    // The Android back button.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('চিঠিটি ফেলে দেবেন?'), findsOneWidget,
        reason: 'the letter would have gone with no warning');

    await tester.tap(find.text('লেখা চালিয়ে যান'));
    await tester.pumpAndSettle();

    expect(find.byType(LetterScreen), findsOneWidget);
    expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'রহিম উদ্দিন',
        reason: 'what was already typed did not survive the question');
  });

  testWidgets('an untouched letter just closes', (tester) async {
    // Asking to confirm a screen nobody has typed on is its own annoyance.
    await open(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('চিঠিটি ফেলে দেবেন?'), findsNothing);
  });
}
