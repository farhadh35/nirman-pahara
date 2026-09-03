import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/lookups/ui/lookups_screen.dart';
import 'package:nirman_pahara/features/measure/ui/measure_screen.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/prices/ui/prices_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The measuring tools, the lookup tables and the prices screens, used rather
/// than merely drawn. Each of these had been rendered by a test and none had
/// been typed into.
Future<Widget> _app(Widget child) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await content.loadAll();
  await content.lookups();
  await content.prices();
  await content.pwdRates();
  await content.pwdEmRates();
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('measure'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

void main() {
  Future<void> open(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    late Widget app;
    await tester.runAsync(() async => app = await _app(screen));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('a land measurement typed in Bangla converts', (tester) async {
    // The screen opens on শতাংশ, and a reader at a land office types Bangla
    // digits. One শতাংশ is a hundredth of an acre: 435.6 square feet, which is
    // 0.605 কাঠা and 0.03 বিঘা. These are the numbers a deed is argued over,
    // so they are checked rather than assumed.
    await open(tester, const MeasureScreen());

    await tester.enterText(find.byType(TextField).first, '১');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' | ');
    for (final expected in [
      '৪৩৫.৬০', // square feet
      '৪৮.৪০', // square yards, 435.6 / 9
      '৯.৬৮', // ছটাক, at 45 sft each
      '০.৬০', // কাঠা, at 720 sft each
    ]) {
      expect(shown, contains(expected),
          reason: 'one শতাংশ did not convert to $expected: $shown');
    }
  });

  testWidgets('the lookup search narrows the tables', (tester) async {
    await open(tester, const LookupsScreen());

    final before = tester.widgetList<Text>(find.byType(Text)).length;
    expect(before, greaterThan(10));

    await tester.enterText(find.byType(TextField).first, 'কিউরিং');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final after = tester.widgetList<Text>(find.byType(Text)).length;
    expect(after, lessThan(before),
        reason: 'searching showed just as much as before, so it did not filter');
    expect(after, greaterThan(1),
        reason: 'searching for a word the tables contain emptied the screen');
  });

  testWidgets('a search that matches nothing says so rather than going blank',
      (tester) async {
    // An empty screen with no explanation reads as the app being broken.
    await open(tester, const LookupsScreen());

    await tester.enterText(find.byType(TextField).first, 'zzzzzzz');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((t) => t.trim().isNotEmpty)
        .toList();
    // Not merely "something was drawn" — the search box's own hint would
    // satisfy that. The reader has to be told the search found nothing and
    // what to try, or an empty screen reads as the app being broken.
    expect(shown.join(' | '), contains('কিছু পাওয়া যায়নি'),
        reason: 'a search with no matches says nothing to the reader');
    expect(shown.join(' | '), contains('অন্য বানানে'),
        reason: 'the reader is not told what to try instead — spelling is the '
            'likeliest reason a Bangla search misses');
  });

  testWidgets('the prices screen opens on all three tabs', (tester) async {
    await open(tester, const PricesScreen());
    expect(tester.takeException(), isNull);

    for (final tab in find.byType(Tab).evaluate().toList()) {
      await tester.tap(find.byWidget(tab.widget));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'a prices tab threw when it was opened');
    }
  });
}
