import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/sources/ui/sources_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reference page had tests for the index behind it and none for the page,
/// so nothing had ever drawn it. A screen that has never been rendered is a
/// screen nobody knows renders.
Future<Widget> _app({double textScale = 1.0}) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await content.loadAll();
  await content.lookups();
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('src'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const SourcesScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('the page draws, and lists works rather than citations',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late Widget app;
    await tester.runAsync(() async => app = await _app());
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // The works a reader would look for, each named once.
    expect(find.textContaining('BNBC'), findsOneWidget);
    expect(find.textContaining('PWD Schedule of Rates'), findsOneWidget);
    expect(find.textContaining('তথ্য অধিকার আইন'), findsOneWidget);
    expect(find.textContaining('ঢাকা মহানগর ইমারত বিধিমালা'), findsOneWidget);

    // Grouped by kind, codes before conventions — and each heading appears
    // once. Two kinds share the words "কোড ও মান", a building code and a
    // materials standard, and grouping by the enum value rather than by the
    // heading printed it twice on the page whose point is that nothing does.
    expect(find.text('কোড ও মান'), findsOneWidget);
    expect(find.text('আইন ও বিধি'), findsOneWidget);
    final headings = <String>[
      'কোড ও মান', 'আইন ও বিধি', 'সরকারি দর তফসিল', 'নকশা', 'বই',
      'সরকারি সেবা ও পোর্টাল', 'গবেষণা ও মূল্যায়ন', 'সংবাদমাধ্যম',
      'বাজারদর', 'প্রচলিত চর্চা',
    ];
    for (final h in headings) {
      final n = find.text(h).evaluate().length;
      expect(n, lessThanOrEqualTo(1), reason: '"\$h" appears \$n times');
    }
  });

  testWidgets('a chapter reference does not appear as its own entry',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late Widget app;
    await tester.runAsync(() async => app = await _app());
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // These are how the citations are written on the cards, at the precision
    // the claim needs. On a reference list they fold into the work.
    for (final chapter in const [
      'BNBC 2020, পার্ট ৫ — বিল্ডিং মেটেরিয়ালস',
      'PWD SoR 2022, chapter 15',
      'book, section 12-5',
    ]) {
      expect(find.text(chapter), findsNothing,
          reason: '"$chapter" is listed as though it were its own work');
    }
  });

  testWidgets('it holds together at the largest text on the smallest phone',
      (tester) async {
    tester.view.physicalSize = const Size(320 * 3.0, 640 * 3.0);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late Widget app;
    await tester.runAsync(() async => app = await _app(textScale: 1.38 * 1.3));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('both entry points into the page still exist', () {
    // One link from the guide, one from settings. If a refactor drops both,
    // the page is unreachable and no other test would notice.
    var entries = 0;
    for (final f in ['lib/features/guide/ui/guide_screens.dart',
                     'lib/features/settings/ui/settings_screen.dart']) {
      if (File(f).readAsStringSync().contains('SourcesScreen')) entries++;
    }
    expect(entries, 2, reason: 'the sources page lost an entry point');
  });
}
