import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/sources/logic/reference_work.dart';
import 'package:nirman_pahara/features/sources/ui/ref_marks.dart';
import 'package:nirman_pahara/features/sources/ui/sources_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _host(Widget child) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  // Everything the reference page reads, warmed before it is drawn: the page
  // builds its index from all four packs.
  await content.loadAll();
  await content.lookups();
  await content.prices();
  await content.checklists();
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('marks'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  testWidgets('a claim shows the number of the work it rests on',
      (tester) async {
    const cited = 'BNBC 2020, পার্ট ৬';
    late Widget app;
    await tester.runAsync(
        () async => app = await _host(RefMarks(sources: [cited])));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    // Bangla digits: the reader reads this number and matches it against the
    // same number printed on the reference page, which is localised too.
    expect(find.textContaining('[').hitTestable(), findsOneWidget);
  });

  testWidgets('two claims on one work print one number, not two',
      (tester) async {
    const cited = 'BNBC 2020, পার্ট ৬';
    late Widget app;
    await tester.runAsync(() async => app = await _host(
          RefMarks(sources: [cited, 'BNBC 2020, পার্ট ৭ — নিরাপত্তা']),
        ));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(find.byType(Text)).data!;
    expect(text.split(',').length, 1, reason: 'printed "$text"');
  });

  testWidgets('a source matching no work prints nothing at all',
      (tester) async {
    late Widget app;
    await tester.runAsync(() async =>
        app = await _host(const RefMarks(sources: ['not a work in the list'])));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('tapping a mark opens the reference page at that entry',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    const cited = 'BNBC 2020, পার্ট ৬';
    final work = ReferenceWork.match(cited)!;
    late Widget app;
    await tester.runAsync(
        () async => app = await _host(RefMarks(sources: [cited])));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(SourcesScreen), findsOneWidget);
    final screen = tester.widget<SourcesScreen>(find.byType(SourcesScreen));
    expect(screen.focus, work.number,
        reason: 'the page opened without knowing which entry was asked for');
    // And the work it was asked for is actually on the page it landed on.
    expect(find.textContaining(work.title.bn), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
