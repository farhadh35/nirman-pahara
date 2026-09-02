import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/calculators/ui/calc_spec.dart';
import 'package:nirman_pahara/features/calculators/ui/calculator_screen.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _state() async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  return AppState.load();
}

Widget _app(AppState state, SharedPreferences prefs, Widget child) {
  return AppScope(
    state: state,
    content: ContentRepository(reader: (p) => File(p).readAsString()),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('loc'),
    ),
    rates: SorRateStore(prefs),
    child: AnimatedBuilder(
      animation: state,
      builder: (_, _) => MaterialApp(home: child),
    ),
  );
}

void main() {
  testWidgets('switching language rewrites the digits already in the boxes',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final state = await _state();
    state.locale = AppLocale.bn;
    final spec = CalcSpec.byId('plaster')!;

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
        _app(state, prefs, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();

    // Bangla first: the seeded area reads in Bangla digits.
    final field = find.byType(TextField).first;
    expect(tester.widget<TextField>(field).controller!.text, '১০০');

    // The reader switches to English from settings while this screen is still
    // on the stack behind it.
    state.locale = AppLocale.en;
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(field).controller!.text, '100',
        reason: 'the box still holds Bangla digits under an English interface');
  });

  testWidgets('a number the reader typed survives the switch, both ways',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final state = await _state();
    state.locale = AppLocale.bn;
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
        _app(state, prefs, CalculatorScreen(spec: CalcSpec.byId('plaster')!)));
    await tester.pumpAndSettle();

    // Their number, not the seeded one.
    final field = find.byType(TextField).first;
    await tester.enterText(field, '২৫০');
    await tester.pumpAndSettle();

    state.locale = AppLocale.en;
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, '250',
        reason: 'the value changed, not just the script');

    state.locale = AppLocale.bn;
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, '২৫০');
  });

  testWidgets('a taka field keeps its grouping across the switch',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final state = await _state();
    state.locale = AppLocale.bn;
    final prefs = await SharedPreferences.getInstance();
    final spec = CalcSpec.byId('unit_cost')!;
    await tester.pumpWidget(_app(state, prefs, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();

    // Contract values run to seven digits and are unreadable ungrouped, so the
    // switch has to re-group as well as re-script.
    final boxes = spec.fields.where((f) => !f.isChoice).toList();
    final money = boxes.indexWhere((f) => f.money);
    expect(money, greaterThan(-1));
    final field = find.byType(TextField).at(money);
    expect(tester.widget<TextField>(field).controller!.text, contains(','));

    state.locale = AppLocale.en;
    await tester.pumpAndSettle();
    final after = tester.widget<TextField>(field).controller!.text;
    expect(after, contains(','), reason: 'grouping was lost');
    expect(RegExp(r'^[0-9,]+$').hasMatch(after), isTrue,
        reason: 'English shows Bangla digits: $after');
  });
}
