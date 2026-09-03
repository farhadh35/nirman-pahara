import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/inspection/ui/inspection_screens.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The walk itself, driven the way somebody standing at a site does it.
///
/// Every part of this had unit tests and none of it had ever been driven
/// through the screens in order: name the work, start, answer something, come
/// back out, and find it again.
late PrefsInspectionStore store;

Future<Widget> _wrap(Widget child) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await content.loadAll();
  await content.checklists();
  store = PrefsInspectionStore(prefs);
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: store,
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('flow'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

void main() {
  late List<ChecklistPack> packs;

  setUp(() async {
    packs = await ContentRepository(reader: (p) => File(p).readAsString())
        .checklists();
  });

  Future<void> open(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    late Widget app;
    await tester.runAsync(() async => app = await _wrap(screen));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('naming a work starts it, and an answer given survives the walk',
      (tester) async {
    await open(tester, InspectionSetupScreen(pack: packs.first));

    // The start button is refused until the work has a name, and says why.
    final start = find.widgetWithText(FilledButton, 'পরিদর্শন শুরু করুন');
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
    expect(find.text('কাজের নাম লিখুন'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'ওয়ার্ড ৩ সড়ক');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);

    await tester.tap(start);
    await tester.pumpAndSettle();

    expect(find.byType(InspectionRunScreen), findsOneWidget,
        reason: 'naming the work and pressing start did not open the walk');

    // Answer the first item.
    final ok = find.widgetWithText(ChoiceChip, 'ঠিক আছে');
    expect(ok, findsWidgets, reason: 'no answer chips on the walk');
    await tester.tap(ok.first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // It is on disk, with the answer, without the reader pressing save.
    final saved = await tester.runAsync(() => store.load(packs));
    expect(saved!.single.projectName, 'ওয়ার্ড ৩ সড়ক');
    expect(saved.single.answered, isNotEmpty,
        reason: 'the answer was not saved as it was given');
  });

  testWidgets('a walk with nothing wrong still produces a report',
      (tester) async {
    await open(tester, InspectionSetupScreen(pack: packs.first));
    await tester.enterText(find.byType(TextField).first, 'সব ঠিক');
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(FilledButton, 'পরিদর্শন শুরু করুন'));
    await tester.pumpAndSettle();

    for (final chip in find.widgetWithText(ChoiceChip, 'ঠিক আছে').evaluate()) {
      await tester.tap(find.byWidget(chip.widget));
      await tester.pumpAndSettle();
    }

    final report = find.textContaining('রিপোর্ট');
    expect(report, findsWidgets, reason: 'no way through to the report');
    await tester.tap(report.first);
    await tester.pumpAndSettle();

    expect(find.byType(InspectionReportScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
