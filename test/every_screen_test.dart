import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/core/util/bn.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/features/boq/ui/schedule_check_screen.dart';
import 'package:nirman_pahara/features/calculators/ui/calculators_screen.dart';
import 'package:nirman_pahara/features/guide/ui/guide_screens.dart';
import 'package:nirman_pahara/features/home/ui/home_screen.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_run.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/inspection/ui/inspection_screens.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/reference/ui/reference_screen.dart';
import 'package:nirman_pahara/features/rights/ui/rights_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ten screens in this app had never been drawn by a test — the home screen,
/// onboarding, and the whole inspection flow among them. That is the spine of
/// the product. A screen nobody has rendered is a screen nobody knows renders.
///
/// Each one is opened here in both themes, and then on the narrowest handset
/// the app supports at the largest text it offers, which is where layout gives
/// way first.
const _smallPhone = Size(320 * 3.0, 640 * 3.0);
const _bigText = 1.38 * 1.3;

Future<Widget> _wrap(
  Widget child, {
  required Brightness brightness,
  double scale = 1.0,
  bool onboarded = true,
  AppLocale locale = AppLocale.bn,
}) async {
  SharedPreferences.setMockInitialValues({
    'onboarded': onboarded,
    'locale': locale.name,
  });
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await content.loadAll();
  await content.lookups();
  await content.prices();
  await content.checklists();
  await content.rights();
  await content.pwdRates();
  await content.pwdEmRates();
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('screens'),
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

Future<void> _draw(
  WidgetTester tester,
  Widget screen, {
  required Brightness brightness,
  double scale = 1.0,
  Size size = const Size(1200, 4000),
  bool onboarded = true,
  AppLocale locale = AppLocale.bn,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  late Widget app;
  await tester.runAsync(() async => app = await _wrap(screen,
      brightness: brightness,
      scale: scale,
      onboarded: onboarded,
      locale: locale));
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  late List<ChecklistPack> packs;

  setUp(() async {
    packs = await ContentRepository(reader: (p) => File(p).readAsString())
        .checklists();
  });

  InspectionRun run() {
    final date = DateTime(2026, 7, 12, 9, 30);
    return InspectionRun(
      id: InspectionRun.idFor(date),
      pack: packs.first,
      // Latin on purpose: this is what a reader typed, and the English sweep
      // below treats any Bangla on screen as an untranslated app string.
      projectName: 'Ward 3 road',
      location: 'Palashbari',
      tenderId: 'LGED-2026-0142',
      date: date,
    );
  }

  List<(String, Widget)> screens() => [
        ('home', const HomeScreen()),
        ('onboarding', const OnboardingScreen()),
        ('guide', const GuideScreen()),
        ('calculators', const CalculatorsScreen()),
        ('rights', const RightsScreen()),
        ('reference', const ReferenceScreen()),
        ('schedule check', const ScheduleCheckScreen()),
        ('inspection list', const InspectionScreen()),
        ('inspection setup', InspectionSetupScreen(pack: packs.first)),
        ('inspection run', InspectionRunScreen(run: run())),
      ];

  for (final brightness in Brightness.values) {
    final theme = brightness.name;
    for (final (name, _) in [
      ('home', 0),
      ('onboarding', 0),
      ('guide', 0),
      ('calculators', 0),
      ('rights', 0),
      ('reference', 0),
      ('schedule check', 0),
      ('inspection list', 0),
      ('inspection setup', 0),
      ('inspection run', 0),
    ]) {
      testWidgets('$name draws in $theme', (tester) async {
        final screen = screens().firstWhere((s) => s.$1 == name).$2;
        await _draw(tester, screen,
            brightness: brightness, onboarded: name != 'onboarding');
        expect(tester.takeException(), isNull);
        // Something has to actually be on it. An empty screen that throws
        // nothing is still a dead end.
        expect(find.byType(Text), findsWidgets, reason: '$name drew nothing');
      });
    }
  }

  for (final (name, _) in [
    ('home', 0),
    ('onboarding', 0),
    ('guide', 0),
    ('calculators', 0),
    ('rights', 0),
    ('reference', 0),
    ('schedule check', 0),
    ('inspection list', 0),
    ('inspection setup', 0),
    ('inspection run', 0),
  ]) {
    testWidgets('$name holds together on a small phone at the largest text',
        (tester) async {
      final screen = screens().firstWhere((s) => s.$1 == name).$2;
      await _draw(tester, screen,
          brightness: Brightness.light,
          scale: _bigText,
          size: _smallPhone,
          onboarded: name != 'onboarding');
      expect(tester.takeException(), isNull,
          reason: '$name overflows at ${_bigText.toStringAsFixed(2)}x on 320dp');
    });
  }

  testWidgets('the next button does not move when the reader uses it',
      (tester) async {
    // Driving a module on a real handset: tapping "next" four times advanced
    // one card. The back button only existed from the second card onward, so
    // using "next" once halved its width and slid it sideways — out from under
    // the thumb that had just pressed it, with "back" now occupying the place
    // it had been. A second tap in the same spot returned to the card just
    // left, and tapping through bounced between the first two cards.
    final content = ContentRepository(reader: (p) => File(p).readAsString());
    late GuidePack pack;
    await tester.runAsync(() async => pack = await content.guide());
    final module =
        pack.modules.firstWhere((m) => m.cards.length > 2);

    await _draw(tester, GuideModuleScreen(module: module),
        brightness: Brightness.light);

    final next = find.widgetWithText(FilledButton, 'পরবর্তী');
    expect(next, findsOneWidget);
    final before = tester.getRect(next);

    await tester.tap(next);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'ফিরে যান'), findsOneWidget,
        reason: 'the back button should appear on the second card');
    expect(tester.getRect(find.widgetWithText(FilledButton, 'পরবর্তী')), before,
        reason: 'the next button moved once it was used');

    // And it keeps working: a second tap in the same place advances again
    // rather than going back.
    await tester.tap(find.widgetWithText(FilledButton, 'পরবর্তী'));
    await tester.pumpAndSettle();
    expect(find.text('৩ / ${Bn.number(module.cards.length.toDouble(), decimals: 0, locale: AppLocale.bn)}'),
        findsOneWidget,
        reason: 'two taps in the same place did not reach the third card');
  });

  // Bangla is the authoring language and English is the second locale, so the
  // English side is where a missing translation or a longer word shows up. It
  // had never been drawn at all.
  for (final (name, _) in [
    ('home', 0),
    ('guide', 0),
    ('calculators', 0),
    ('rights', 0),
    ('reference', 0),
    ('schedule check', 0),
    ('inspection list', 0),
    ('inspection setup', 0),
    ('inspection run', 0),
  ]) {
    testWidgets('$name draws in English', (tester) async {
      final screen = screens().firstWhere((s) => s.$1 == name).$2;
      await _draw(tester, screen,
          brightness: Brightness.light, locale: AppLocale.en);
      expect(tester.takeException(), isNull);

      // Every visible string should have been written in English. Bangla text
      // on an English screen means an L10nText was built without an `en`, and
      // the reader who chose English gets a script they may not read at all.
      final bangla = RegExp(r'[\u0980-\u09FF]');
      final leaked = <String>[];
      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        final v = t.data ?? '';
        if (bangla.hasMatch(v)) leaked.add(v);
      }
      expect(leaked, isEmpty,
          reason: '$name shows Bangla to a reader who chose English');
    });

    testWidgets('$name really is full of Bangla in Bangla', (tester) async {
      // The control for the sweep above. Without it, that test would pass just
      // as happily on a screen that drew no text at all, or if the finder
      // stopped matching — it would be asserting nothing and looking green.
      final screen = screens().firstWhere((s) => s.$1 == name).$2;
      await _draw(tester, screen, brightness: Brightness.light);
      final bangla = RegExp(r'[\u0980-\u09FF]');
      final found = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => bangla.hasMatch(t.data ?? ''));
      expect(found, isNotEmpty,
          reason: 'the English sweep cannot be trusted: this screen shows no '
              'Bangla even in Bangla, so finding none in English proves '
              'nothing');
    });

    testWidgets('$name holds together in English at the largest text',
        (tester) async {
      // English words are longer than their Bangla counterparts in several
      // places, so the narrow-phone case is a different test in each locale.
      final screen = screens().firstWhere((s) => s.$1 == name).$2;
      await _draw(tester, screen,
          brightness: Brightness.light,
          scale: _bigText,
          size: _smallPhone,
          locale: AppLocale.en);
      expect(tester.takeException(), isNull,
          reason: '$name overflows in English at 1.79x on 320dp');
    });
  }
}
