import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/directory/ui/directory_screen.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The directory page carries no listings, and must not start carrying them
/// quietly.
///
/// The book's own directories were left out because they are 2019 telephone
/// numbers; the page exists to say so rather than leave a reader wondering. Two
/// things could go wrong later. Someone fills it with those stale numbers after
/// all. Or someone sells a place on it — which the store listing forbids in
/// terms: "This app takes no advertising from cement, steel, brick, tile,
/// paint, contracting or real-estate companies", and a soil-test firm or an
/// architect is squarely among the trades this app teaches a reader to check.
void main() {
  testWidgets('the page explains itself rather than sitting empty',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    final content = ContentRepository(reader: (p) => File(p).readAsString());
    late Widget app;
    await tester.runAsync(() async {
      await content.loadAll();
      app = AppScope(
        state: await AppState.load(),
        content: content,
        store: PrefsInspectionStore(prefs),
        evidence: EvidenceStore(
          directory: () async => Directory.systemTemp.createTempSync('dir'),
        ),
        rates: SorRateStore(prefs),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const DirectoryScreen(),
        ),
      );
    });
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // A bare "coming soon" screen is the kind of placeholder Play treats as
    // broken functionality. This one has to say why it is empty and what would
    // have to be true before it is not.
    final shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' | ');
    expect(shown, contains('এখনো আসেনি'),
        reason: 'the page does not say the list is still to come');
    expect(shown, contains('২০১৯'),
        reason: 'the page does not give the reason — that the available lists '
            'are 2019 telephone numbers');
    expect(shown, contains('কোনো টাকা নেওয়া হবে না'),
        reason: 'the page no longer states that inclusion is not for sale');
  });

  test('no firm listing has been added to the page', () {
    // Telephone numbers and email addresses are what a directory is made of.
    // Their appearance here is the signal that this stopped being a placeholder.
    final src =
        File('lib/features/directory/ui/directory_screen.dart').readAsStringSync();
    final phone = RegExp(r'[০-৯0-9]{7,}');
    final matches = phone.allMatches(src).map((m) => m.group(0)!).toSet()
      ..removeWhere((m) => m.startsWith('২০১৯') || m.startsWith('2019'));
    expect(matches, isEmpty,
        reason: 'something that looks like a telephone number is on the '
            'directory page: $matches');
    // Not a bare '@' — every Dart override annotation carries one. An address
    // is what matters.
    final email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+');
    expect(email.allMatches(src).map((m) => m.group(0)).toList(), isEmpty,
        reason: 'an email address is on the directory page');
  });

  test('the listing still promises no advertising from the judged trades', () {
    // The claim the page above is written to stay inside.
    final desc = File('store/play-description-en.txt').readAsStringSync();
    expect(desc, contains('takes no advertising'),
        reason: 'the no-advertising promise left the store description, so the '
            'directory page\'s constraint has lost its source');
  });
}
