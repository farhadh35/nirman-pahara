import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/calculators/ui/calc_spec.dart';
import 'package:nirman_pahara/features/calculators/ui/calculator_screen.dart';
import 'package:nirman_pahara/features/guide/ui/guide_screens.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A card may name a calculator, and that name has to resolve.
///
/// The seventeen calculators sat behind one door for the life of the app, which
/// serves somebody who already knows what they want and nobody who has just
/// been told how many bricks a stack should hold. Cards now name the tool that
/// answers the question they raise.
///
/// The failure this guards is silent: a card naming a calculator that has been
/// renamed or removed renders nothing at all — no button, no error — so the
/// link simply disappears and the card looks finished.
Future<String> _read(String p) => File(p).readAsString();

void main() {
  test('every calculator a card names exists', () async {
    final pack = await ContentRepository(reader: _read).guide();
    final ids = {for (final s in CalcSpec.all) s.id};
    final broken = <String>[];
    var linked = 0;
    for (final m in pack.modules) {
      for (final c in m.cards) {
        if (c.calc == null) continue;
        linked++;
        if (!ids.contains(c.calc)) broken.add('${c.id} -> ${c.calc}');
      }
    }
    expect(linked, greaterThan(0),
        reason: 'no card links a calculator any more; the cards and the tools '
            'have gone back to being separate things');
    expect(broken, isEmpty,
        reason: 'these cards name a calculator that does not exist, and render '
            'no button at all rather than failing: $broken');
  });

  test('the calculators keep their own door', () async {
    // Linking from cards is a second way in, not a replacement. Someone who
    // knows they want the brick-stack calculator should not have to find the
    // card that mentions it.
    final home =
        await _read('lib/features/home/ui/home_screen.dart');
    expect(home, contains('CalculatorsScreen'),
        reason: 'the calculators door has gone from the home screen');
    expect(CalcSpec.all.length, greaterThanOrEqualTo(17),
        reason: 'a calculator was dropped; check no card still names it');
  });

  test('a linked calculator answers the question its card raises', () async {
    // Spot-checks, because the mapping is a judgement and a wrong one is worse
    // than none: it sends a reader to a tool that does not answer them.
    final pack = await ContentRepository(reader: _read).guide();
    final byId = {
      for (final m in pack.modules)
        for (final c in m.cards) c.id: c,
    };
    const expected = {
      'm4c1': 'concrete',     // what the ratio means
      'm5c1': 'rebar',        // count the bars, measure the spacing
      'm3c3': 'brick_stack',  // judging a delivered stack of brick
      'm21c3': 'water_store', // where the water comes from and sits
      'm2c3': 'unit_cost',    // divide the contract value
    };
    expected.forEach((card, calc) {
      expect(byId[card]?.calc, calc,
          reason: '$card should open the $calc calculator');
    });
  });

  testWidgets('the link renders on the card and opens the calculator',
      (tester) async {
    // The three tests above check the data. This checks the thing a reader
    // actually meets: a button on the card that goes somewhere.
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    final content = ContentRepository(reader: _read);
    late Widget app;
    await tester.runAsync(() async {
      await content.loadAll();
      final pack = await content.guide();
      app = AppScope(
        state: await AppState.load(),
        content: content,
        store: PrefsInspectionStore(prefs),
        evidence: EvidenceStore(
          directory: () async => Directory.systemTemp.createTempSync('calc'),
        ),
        rates: SorRateStore(prefs),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: GuideModuleScreen(
            module: pack.modules.firstWhere((m) => m.id == 'm4_mixing'),
          ),
        ),
      );
    });
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final link = find.textContaining('এই হিসাবটা করে দেখুন');
    expect(link, findsOneWidget,
        reason: 'the calculator link does not render on the card');
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorScreen), findsOneWidget,
        reason: 'tapping the link did not open the calculator');
  });
}
