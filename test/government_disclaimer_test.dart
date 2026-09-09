import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/boq/ui/schedule_check_screen.dart';
import 'package:nirman_pahara/features/guide/ui/guide_screens.dart';
import 'package:nirman_pahara/features/home/ui/home_screen.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/lookups/ui/lookups_screen.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/prices/ui/prices_screen.dart';
import 'package:nirman_pahara/features/rights/ui/rights_screen.dart';
import 'package:nirman_pahara/features/rules/ui/far_screen.dart';
import 'package:nirman_pahara/features/sources/logic/reference_work.dart';
import 'package:nirman_pahara/features/sources/ui/not_government_notice.dart';
import 'package:nirman_pahara/features/sources/ui/sources_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The second rejection, and what it was actually about.
///
/// Play rejected this app on 4 September 2026 for showing government
/// information with no link to the source and no statement that the app is not
/// the government. Links and a disclaimer were added — to the store listing,
/// and to the sources page — and Play rejected it again on 7 September under
/// the same policy.
///
/// The lesson is in *where*, not *whether*. The store disclaimer sat 2,530
/// characters into a description Play collapses after about eighty, and the
/// in-app one sat on a page reachable only through settings. Play's own words
/// are "an easy-to-see disclaimer" and "check all areas of your app". So these
/// tests do not ask whether the sentence exists anywhere; they ask whether it
/// is in front of somebody who opens the app or reads the listing.
Future<Widget> _wrap(Widget child, {bool onboarded = true}) async {
  SharedPreferences.setMockInitialValues({
    'onboarded': onboarded,
    'locale': AppLocale.bn.name,
  });
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await content.loadAll();
  await content.lookups();
  await content.prices();
  await content.rights();
  await content.pwdRates();
  await content.pwdEmRates();
  await content.far();
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('disclaim'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

String _description() =>
    File('store/play-description-en.txt').readAsStringSync().trimRight();

String _shortDescription() =>
    File('store/play-short-description-en.txt').readAsStringSync().trim();

void main() {
  group('the listing Play actually reads', () {
    test('the full description fits the field', () {
      // Play truncates at 4000 and refuses the save. A description that cannot
      // be pasted is a fix that never ships.
      expect(_description().length, lessThanOrEqualTo(4000),
          reason: 'the description is ${_description().length} characters; '
              'Play takes 4000');
    });

    test('the disclaimer is in the opening line, not buried', () {
      // The first version put it at character 2,530. Play shows roughly the
      // first eighty before "read more", so "easy-to-see" means the top.
      final text = _description();
      final at = text.toUpperCase().indexOf('NOT A GOVERNMENT');
      expect(at, isNonNegative, reason: 'the description does not disclaim '
          'being a government app at all');
      expect(at, lessThan(120),
          reason: 'the disclaimer starts at character $at. That is below the '
              'fold on the store page, which is where the first fix failed');
      expect(text.toLowerCase(), contains('not affiliated with'),
          reason: 'the description does not disclaim affiliation');
    });

    test('the short description says it too, and still fits', () {
      // The one line every search result and every store card shows.
      final short = _shortDescription();
      expect(short.length, lessThanOrEqualTo(80),
          reason: 'the short description is ${short.length} characters; '
              'Play takes 80');
      expect(short.toLowerCase(), contains('not a government app'),
          reason: 'the line most readers see makes no disclaimer');
    });

    test('every link the app holds is also given in the description', () {
      // The rule used to be "every government work must be linked". That
      // produced ten addresses, six of which opened a security warning for
      // anyone outside Bangladesh, and the third rejection. Now the app keeps
      // a link only where the publisher's site actually opens, and the
      // description has to carry exactly those.
      final text = _description();
      final missing = <String>[];
      for (final w in ReferenceWork.all) {
        if (w.url == null) continue;
        final host = Uri.parse(w.url!).host.replaceFirst('www.', '');
        if (!text.contains(host)) missing.add('${w.id} ($host)');
      }
      expect(missing, isEmpty,
          reason: 'the app cites these addresses but the store description '
              'does not: $missing');
    });

    test('the description promises no source it cannot open', () {
      // The failure the third rejection was actually about.
      final text = _description();
      final dead = [
        for (final host in ReferenceWork.kKnownUnreachableHosts)
          if (text.contains(host)) host,
      ];
      expect(dead, isEmpty,
          reason: 'the description links $dead, whose certificate chain is '
              'broken for every reader outside Bangladesh');
    });

    test('the description still says where the unlinked works are named', () {
      // Six works lost their address. Saying nothing about them would read as
      // figures with no provenance at all, which is the first rejection.
      expect(_description().toLowerCase(), contains('reference page'),
          reason: 'the description drops the works it cannot link without '
              'telling the reader they are named inside the app');
    });

    test('the description links nothing the app does not cite', () {
      // The mirror of the test above: a link list that drifts ahead of the app
      // is a different kind of misleading claim.
      final hosts = RegExp(r'https?://([^/\s]+)')
          .allMatches(_description())
          .map((m) => m.group(1)!.replaceFirst('www.', ''))
          .toSet();
      final cited = {
        for (final w in ReferenceWork.all)
          if (w.url != null) Uri.parse(w.url!).host.replaceFirst('www.', ''),
      };
      expect(hosts.difference(cited), isEmpty,
          reason: 'the description links sources the app never cites');
    });
  });

  group('the app, on the screens a reader opens', () {
    Future<void> open(WidgetTester tester, Widget screen,
        {bool onboarded = true}) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      late Widget app;
      await tester.runAsync(
          () async => app = await _wrap(screen, onboarded: onboarded));
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
    }

    testWidgets('the first screen of a new install says it', (tester) async {
      // Onboarding names both tracks, one of them "সরকারি কাজ". Somebody
      // arriving there can reasonably wonder whose app this is.
      await open(tester, const OnboardingScreen(), onboarded: false);
      expect(find.byType(NotGovernmentNotice), findsOneWidget,
          reason: 'the first screen of the app makes no disclaimer');
      expect(find.textContaining('সরকারি অ্যাপ নয়'), findsWidgets);
    });

    testWidgets('the home screen says it, above the doors', (tester) async {
      await open(tester, const HomeScreen());
      final notice = find.byType(NotGovernmentNotice);
      expect(notice, findsOneWidget,
          reason: 'the home screen makes no disclaimer');

      // Above the first door, not at the bottom of a ten-item list. Position
      // is the whole point of this round of fixes.
      final noticeY = tester.getTopLeft(notice).dy;
      final firstDoor = tester.getTopLeft(find.byType(Card).first).dy;
      expect(noticeY, lessThan(firstDoor),
          reason: 'the disclaimer sits below the doors, so a reader scrolls '
              'past everything before meeting it');
    });

    testWidgets('and it opens the list of sources when tapped', (tester) async {
      // "Clear and accessible" — the reader has to be able to get from the
      // disclaimer to the addresses without knowing the app.
      await open(tester, const HomeScreen());
      await tester.tap(find.byType(NotGovernmentNotice));
      await tester.pumpAndSettle();
      expect(find.byType(SourcesScreen), findsOneWidget,
          reason: 'tapping the disclaimer leads nowhere');
    });

    for (final (name, screen) in <(String, Widget)>[
      ('rates', PricesScreen()),
      ('the gazette table', FarScreen()),
      ('the standards tables', LookupsScreen()),
      ('the schedule check', ScheduleCheckScreen()),
      ('the letters', RightsScreen()),
      ('the guide', GuideScreen()),
    ]) {
      testWidgets('$name carries it on the screen itself', (tester) async {
        await open(tester, screen);
        expect(find.byType(NotGovernmentNotice), findsWidgets,
            reason: '$name shows government information with no disclaimer on '
                'the screen — this is the "check all areas of your app" that '
                'the second rejection was about');
      });
    }
  });
}
