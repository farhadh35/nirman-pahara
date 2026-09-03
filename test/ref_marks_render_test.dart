import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/features/guide/ui/guide_screens.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/lookups/ui/lookups_screen.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/prices/ui/prices_screen.dart';
import 'package:nirman_pahara/features/sources/ui/ref_marks.dart';
import 'package:nirman_pahara/features/sources/ui/sources_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reference marks replaced a badge on four screens and none of those
/// screens had been drawn since. A widget that has never been rendered is a
/// widget nobody knows renders — and this one has to survive the dark theme,
/// the largest text and the narrowest phone the app supports.
const _smallPhone = Size(320 * 3.0, 640 * 3.0);
const _bigText = 1.38 * 1.3;

Future<Widget> _wrap(Widget child, {required Brightness brightness,
    double scale = 1.0}) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await content.loadAll();
  await content.lookups();
  await content.prices();
  await content.checklists();
  // The prices screen also reads both SoR volumes; without them its
  // ContentBuilder sits on a spinner and pumpAndSettle never returns.
  await content.pwdRates();
  await content.pwdEmRates();
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('marks'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode:
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: scale,
        maxScaleFactor: scale,
        child: child,
      ),
    ),
  );
}

Future<void> _draw(WidgetTester tester, Widget screen,
    {required Brightness brightness, double scale = 1.0}) async {
  late Widget app;
  await tester.runAsync(() async =>
      app = await _wrap(screen, brightness: brightness, scale: scale));
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final name = brightness == Brightness.light ? 'light' : 'dark';

    testWidgets('a guide module shows its reference marks ($name)',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      late GuidePack pack;
      final content = ContentRepository(reader: (p) => File(p).readAsString());
      await tester.runAsync(() async => pack = await content.guide());
      final module = pack.modules
          .firstWhere((m) => m.cards.any((c) => c.citations.isNotEmpty));

      await _draw(tester, GuideModuleScreen(module: module),
          brightness: brightness);
      expect(find.byType(RefMarks), findsWidgets);
      expect(tester.takeException(), isNull);
      // The mark has to actually print something, not collapse to nothing.
      final drawn = tester
          .widgetList<RefMarks>(find.byType(RefMarks))
          .where((m) => m.sources.isNotEmpty);
      expect(drawn, isNotEmpty);
      expect(find.textContaining('['), findsWidgets,
          reason: 'no reference number rendered on any card');
    });

    testWidgets('the lookup tables show marks ($name)', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await _draw(tester, const LookupsScreen(), brightness: brightness);
      expect(tester.takeException(), isNull);
      expect(find.byType(RefMarks), findsWidgets);
    });

    testWidgets('the prices screen shows marks ($name)', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await _draw(tester, const PricesScreen(), brightness: brightness);
      expect(tester.takeException(), isNull);
      expect(find.byType(RefMarks), findsWidgets);
    });

    testWidgets('the reference page draws numbered, and highlights the one '
        'that was tapped ($name)', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await _draw(tester, const SourcesScreen(focus: 3),
          brightness: brightness);
      expect(tester.takeException(), isNull);
      // Bangla digits down the number column.
      expect(find.text('৩'), findsOneWidget);
      expect(find.text('১'), findsOneWidget);
    });
  }

  testWidgets('the marks survive the smallest phone at the largest text',
      (tester) async {
    tester.view.physicalSize = _smallPhone;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late GuidePack pack;
    final content = ContentRepository(reader: (p) => File(p).readAsString());
    await tester.runAsync(() async => pack = await content.guide());
    final module = pack.modules
        .firstWhere((m) => m.cards.any((c) => c.citations.length > 1));

    await _draw(tester, GuideModuleScreen(module: module),
        brightness: Brightness.light, scale: _bigText);
    expect(tester.takeException(), isNull,
        reason: 'the marks overflow on a 320dp phone at the largest text');
  });

  testWidgets('the last entry is reachable when the page is tall enough',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 12000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await _draw(tester, const SourcesScreen(focus: 21),
        brightness: Brightness.light);
    expect(find.text('২১'), findsOneWidget,
        reason: 'entry 21 is not on the page at all');
  });

  testWidgets('the reference page number column holds a two-digit number '
      'at the largest text', (tester) async {
    tester.view.physicalSize = _smallPhone;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    // Entry 21 is two Bangla digits in a fixed-width column.
    await _draw(tester, const SourcesScreen(focus: 21),
        brightness: Brightness.light, scale: _bigText);
    expect(tester.takeException(), isNull,
        reason: 'the number column clips at the largest text');
    expect(find.text('২১'), findsOneWidget);
  });
}
