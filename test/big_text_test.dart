import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/calculators/ui/calc_spec.dart';
import 'package:nirman_pahara/features/calculators/ui/calculator_screen.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/lookups/ui/lookups_screen.dart';
import 'package:nirman_pahara/features/measure/ui/measure_screen.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/rules/ui/far_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reader this app is for is often on a cheap, small handset, and often
/// old enough to have turned the text size up. The settings screen offers
/// "আরও বড়" at 1.38, and the app clamps up to 1.3 times that — 1.79 in all.
/// A 320dp phone at 1.79 is not a corner case here, it is a Tuesday.
const _smallPhone = Size(320 * 3.0, 640 * 3.0);
const _bigText = 1.38 * 1.3;

Future<Widget> _wrap(Widget child, double scale,
    {ContentRepository? content}) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  return AppScope(
    state: await AppState.load(),
    content: content ?? ContentRepository(reader: (p) => File(p).readAsString()),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('bigtext'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: scale,
        maxScaleFactor: scale,
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('every calculator survives a small screen at the largest text',
      (tester) async {
    tester.view.physicalSize = _smallPhone;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final broken = <String>[];
    for (final spec in CalcSpec.all) {
      await tester.pumpWidget(
          await _wrap(CalculatorScreen(spec: spec), _bigText));
      await tester.pumpAndSettle();
      final e = tester.takeException();
      if (e != null) broken.add('${spec.id}: $e');
    }
    expect(broken, isEmpty,
        reason: 'these overflow at 320dp and 1.79x text:\n'
            '${broken.join('\n')}');
  });

  testWidgets('and at the smallest', (tester) async {
    tester.view.physicalSize = _smallPhone;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final broken = <String>[];
    for (final spec in CalcSpec.all) {
      await tester.pumpWidget(await _wrap(CalculatorScreen(spec: spec), 1.0));
      await tester.pumpAndSettle();
      final e = tester.takeException();
      if (e != null) broken.add('${spec.id}: $e');
    }
    expect(broken, isEmpty, reason: broken.join('\n'));
  });

  testWidgets('the newest screens hold up too', (tester) async {
    tester.view.physicalSize = _smallPhone;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final screens = <String, Widget>{
      'measure': const MeasureScreen(),
      'lookups': const LookupsScreen(),
      'plot rules': const FarScreen(),
    };
    final broken = <String>[];
    for (final entry in screens.entries) {
      // Content is read from disk, which has to happen outside the fake-async
      // zone or the future never completes under pumpAndSettle.
      // The packs are read off disk and cached before the screen is built:
      // ContentBuilder shows a spinner while a future is pending, and a
      // spinner animates forever, so pumpAndSettle would never return.
      late Widget app;
      await tester.runAsync(() async {
        final content = ContentRepository(reader: (p) => File(p).readAsString());
        await content.loadAll();
        await content.lookups();
        await content.far();
        app = await _wrap(entry.value, _bigText, content: content);
      });
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      final e = tester.takeException();
      if (e != null) broken.add('${entry.key}: $e');
    }
    expect(broken, isEmpty,
        reason: 'these break at 320dp and 1.79x text:\n${broken.join('\n')}');
  });

  testWidgets('the measuring tabs each hold up at the largest text',
      (tester) async {
    tester.view.physicalSize = _smallPhone;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late Widget app;
    await tester.runAsync(() async {
      app = await _wrap(const MeasureScreen(), _bigText);
    });
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Three tabs, and only the first is built until each is opened.
    for (final tab in const ['সুতা', 'জ্যামিতি']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'the $tab tab broke');
    }
  });
}
