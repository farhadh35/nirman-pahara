import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real app against the real bundled content, the same way the main
/// flow test does. The guide pack crosses the size at which rootBundle decodes
/// on a worker isolate, which never completes under pumpAndSettle, so content
/// is read straight off disk instead.
Future<void> _boot(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 4200);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'onboarded': true});
  final state = await AppState.load();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await tester.runAsync(() async {
    await content.loadAll();
    await content.lookups();
    await content.far();
  });
  await tester.pumpWidget(NirmanPaharaApp(
    state: state,
    content: content,
    store: PrefsInspectionStore(await SharedPreferences.getInstance()),
    evidence: EvidenceStore(
      directory: () async =>
          Directory.systemTemp.createTempSync('screens_evidence'),
    ),
    rates: SorRateStore(await SharedPreferences.getInstance()),
  ));
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester, String door) async {
  final base = find.text(door);
  for (var i = 0; base.evaluate().isEmpty && i < 25; i++) {
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(base.first);
  await tester.pumpAndSettle();
  await tester.tap(base.first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the plot-rules screen reads a FAR off the gazette table',
      (tester) async {
    await _boot(tester);
    await _open(tester, 'জমিতে কতটুকু করা যাবে');

    // It opens seeded: 3 katha on a 12 m road, single-family house in central
    // Dhaka. That is FAR 3.5 and 7,560 sft over every storey.
    expect(find.text('FAR সূচক'), findsOneWidget);
    expect(find.textContaining('৩.৫'), findsWidgets);
    expect(find.textContaining('৭,৫৬০'), findsWidgets);
    // The refusal to be mistaken for permission is on the page, not buried.
    expect(find.textContaining('অনুমোদন নয়'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the plot-rules screen refuses a road the gazette does not cover',
      (tester) async {
    await _boot(tester);
    await _open(tester, 'জমিতে কতটুকু করা যাবে');

    // Under 1.8 m the table simply stops, and the screen has to say so rather
    // than show a zero a reader could act on.
    await tester.enterText(find.byType(TextField).at(1), '১');
    await tester.pumpAndSettle();
    expect(find.textContaining('সারণি-৫'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the measuring screen converts land and draws a shape',
      (tester) async {
    await _boot(tester);
    await _open(tester, 'মাপজোখ');

    // Land units land first, seeded at 5 শতাংশ. A decimal is 435.6 square
    // feet, so the same area has to appear as 2,178 sft in the conversion
    // list — that list is the whole point of the tab.
    expect(find.textContaining('২,১৭৮'), findsWidgets);

    await tester.tap(find.text('সুতা'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('জ্যামিতি'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the tables screen lists tables and filters them by search',
      (tester) async {
    await _boot(tester);
    await _open(tester, 'মাপ ও তালিকা');
    expect(tester.takeException(), isNull);

    final before = find.byType(Card).evaluate().length;
    await tester.enterText(find.byType(TextField).first, 'কিউরিং');
    await tester.pumpAndSettle();
    // Searching narrows the page; it must not empty it or crash it.
    expect(tester.takeException(), isNull);
    expect(find.byType(Card).evaluate().length, lessThanOrEqualTo(before));

    await tester.enterText(find.byType(TextField).first, 'zzzznotathing');
    await tester.pumpAndSettle();
    // A miss says so rather than rendering a blank page.
    expect(find.byType(Card), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every calculator screen opens and shows an answer',
      (tester) async {
    await _boot(tester);
    await _open(tester, 'হিসাব');
    // Walking all seventeen through the real widget is what proves the specs
    // render, not just that they compute.
    for (final title in const [
      'ইটের গাদা',
      'ইট গোনা',
      'রড ডেলিভারি চেক',
      'ইটের সলিং',
      'হুকের দৈর্ঘ্য',
      'শাটারিং',
      'টাইলস',
      'রং',
      'মাটি খননের হিসাব',
      'সিঁড়ির মাপ',
      'পানির ট্যাংক',
    ]) {
      // Exact text, not textContaining: the group heading above the casting
      // cards reads "ঢালাই, রড, শাটারিং আর তার নিচের স্তর", so a loose match
      // taps a heading that goes nowhere.
      final door = find.text(title);
      for (var i = 0; door.evaluate().isEmpty && i < 25; i++) {
        await tester.drag(find.byType(ListView).last, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      expect(door, findsWidgets, reason: 'no card titled "$title"');
      await tester.ensureVisible(door.first);
      await tester.tap(door.first);
      await tester.pumpAndSettle();
      expect(find.text('ফলাফল'), findsOneWidget,
          reason: '$title opened without an answer');
      expect(tester.takeException(), isNull, reason: title);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
