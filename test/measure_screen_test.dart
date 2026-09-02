import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/measure/logic/geometry.dart';
import 'package:nirman_pahara/features/measure/ui/measure_screen.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _app(AppState state) async {
  final prefs = await SharedPreferences.getInstance();
  return AppScope(
    state: state,
    content: ContentRepository(reader: (p) => File(p).readAsString()),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('measure'),
    ),
    rates: SorRateStore(prefs),
    child: AnimatedBuilder(
      animation: state,
      builder: (_, _) => const MaterialApp(home: MeasureScreen()),
    ),
  );
}

Future<AppState> _state() async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  return AppState.load();
}

void _sized(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the land box waits instead of complaining when emptied',
      (tester) async {
    _sized(tester);
    await tester.pumpWidget(await _app(await _state()));
    await tester.pumpAndSettle();

    expect(find.textContaining('২,১৭৮'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.textContaining('একটি মাপ লিখলে'), findsOneWidget);
    expect(find.textContaining('শূন্য বা তার বেশি'), findsNothing,
        reason: 'an empty box was treated as a bad number');
  });

  testWidgets('changing shape keeps the measurements already typed',
      (tester) async {
    _sized(tester);
    await tester.pumpWidget(await _app(await _state()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('জ্যামিতি'));
    await tester.pumpAndSettle();

    // A rectangle: length and width.
    await tester.enterText(find.byType(TextField).at(0), '২৫');
    await tester.enterText(find.byType(TextField).at(1), '১২');
    await tester.pumpAndSettle();

    // Now the same room as a solid, which adds a height. Retyping the two
    // numbers just measured would be the app wasting the reader's time.
    await tester.tap(find.byType(DropdownButtonFormField<Shape>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('আয়তাকার ঘনবস্তু').last);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        '২৫');
    expect(tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        '১২');
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('every tab rewrites its digits when the language changes',
      (tester) async {
    _sized(tester);
    final state = await _state();
    state.locale = AppLocale.bn;
    await tester.pumpWidget(await _app(state));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '৫');

    state.locale = AppLocale.en;
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '5', reason: 'the land box kept Bangla digits under English');

    for (final tab in const ['Suta', 'সুতা']) {
      if (find.text(tab).evaluate().isEmpty) continue;
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      final t =
          tester.widget<TextField>(find.byType(TextField).first).controller!.text;
      expect(RegExp(r'^[0-9]+$').hasMatch(t), isTrue,
          reason: 'the suta box kept Bangla digits under English: $t');
      break;
    }
  });

  testWidgets('cycling every shape leaves no disposed controller behind',
      (tester) async {
    _sized(tester);
    await tester.pumpWidget(await _app(await _state()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('জ্যামিতি'));
    await tester.pumpAndSettle();

    for (final shape in Shape.values) {
      await tester.tap(find.byType(DropdownButtonFormField<Shape>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(shape.label.bn).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'broke on ${shape.name}');
      expect(find.byType(TextField), findsNWidgets(shape.inputs.length));
    }
  });
}
