import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/settings/ui/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings is where the app answers questions about itself — who runs it,
/// what it is funded by, what it is not, what it rests on. It had been opened
/// by one flow test to switch language and never rendered whole.
Future<Widget> _app(AppState state, {double textScale = 1.0}) async {
  final prefs = await SharedPreferences.getInstance();
  return AppScope(
    state: state,
    content: ContentRepository(reader: (p) => File(p).readAsString()),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('set'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const SettingsScreen(),
      ),
    ),
  );
}

Future<AppState> _state() async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  return AppState.load();
}

void main() {
  testWidgets('every section is on the page', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(await _app(await _state()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final section in const [
      'ভাষা',
      'লেখার আকার',
      'কে এই অ্যাপ চালায়, টাকা কোথা থেকে আসে',
      'সূত্র',
      'এই অ্যাপ সম্পর্কে',
    ]) {
      expect(find.textContaining(section), findsWidgets,
          reason: '"$section" is missing from settings');
    }
  });

  testWidgets('the two statements about the app itself are both here',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(await _app(await _state()));
    await tester.pumpAndSettle();

    // Not a government app, and not ad-funded. Both were wrong once.
    expect(find.textContaining('সরকারি অ্যাপ নয়'), findsOneWidget);
    expect(find.textContaining('কোনো বিজ্ঞাপন নেই'), findsOneWidget);
  });

  testWidgets('the track picker offers two options, not three',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(await _app(await _state()));
    await tester.pumpAndSettle();

    expect(find.byType(RadioListTile<Track>), findsNWidgets(2),
        reason: 'the picker should offer exactly the two real situations');
    expect(find.text('সরকারি কাজ'), findsOneWidget);
    expect(find.text('নিজের বাড়ি'), findsOneWidget);
    expect(find.text('দুটোই'), findsNothing,
        reason: 'the withdrawn track is still offered here');
  });

  testWidgets('it survives the smallest phone at the largest text',
      (tester) async {
    tester.view.physicalSize = const Size(320 * 3.0, 640 * 3.0);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        await _app(await _state(), textScale: 1.38 * 1.3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('it renders in English too', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final state = await _state();
    state.locale = AppLocale.en;
    await tester.pumpWidget(await _app(state));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('not a government app'), findsOneWidget);
    expect(find.textContaining('Sources'), findsWidgets);
  });
}
