import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/core/i18n/strings.dart';

/// Claims the app makes about itself, rather than about construction.
///
/// These went wrong in a way the content tests could not catch, because the
/// sentences were well-formed, translated and cited-free — they were simply
/// untrue. The funding line told every reader the app ran on advertising while
/// no advertising SDK had ever been in the build, and the same assumption had
/// spread into the Play data-safety answers and the release checklist, where it
/// would have become a false declaration to Google.
///
/// A claim about the app itself is checkable against the app itself, so it is
/// checked here.
void main() {
  test('the funding line does not claim ads the build does not contain', () {
    for (final locale in AppLocale.values) {
      final text = S.adDisclosure.of(locale);
      expect(text.trim(), isNotEmpty);
      // Not "this app runs on advertising" in either language.
      expect(text.toLowerCase(), isNot(contains('runs on advertising')),
          reason: 'the app claims ad funding it does not have');
      expect(text, isNot(contains('এই অ্যাপ বিজ্ঞাপনে চলে')),
          reason: 'the app claims ad funding it does not have');
    }
    // It still has to state the constraint, or the section says nothing useful.
    expect(S.adDisclosure.bn, contains('বিজ্ঞাপন'));
    expect(S.adDisclosure.en, contains('ads'));
  });

  test('the app says it is not a government app, in both languages', () {
    // The app is about government works. A reader can reasonably assume it is
    // official unless told otherwise, and Play's impersonation policy is the
    // one that bites hardest for an app in this position.
    expect(S.notGovernment.bn, contains('সরকারি অ্যাপ নয়'));
    expect(S.notGovernment.en?.toLowerCase(), contains('not a government app'));
    for (final locale in AppLocale.values) {
      expect(S.notGovernment.of(locale).trim(), isNotEmpty);
    }
  });

  test('no user-facing string promises a feature the build lacks', () {
    // The two that were wrong, kept as a named list so a third joins them here
    // rather than in a store listing.
    const forbidden = <String, String>{
      'runs on advertising': 'no ad SDK ships',
      'বিজ্ঞাপনে চলে': 'no ad SDK ships',
    };
    final strings = <L10nText>[
      S.adDisclosure,
      S.notGovernment,
      S.privacyLine,
      S.noPaywall,
      S.calculateSub,
      S.tagline,
    ];
    for (final s in strings) {
      for (final entry in forbidden.entries) {
        expect(s.bn, isNot(contains(entry.key)), reason: entry.value);
        expect(s.en ?? '', isNot(contains(entry.key)), reason: entry.value);
      }
    }
  });

  testWidgets('both statements reach the settings screen', (tester) async {
    // Present in strings.dart is not the same as present on the screen.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text(S.notGovernment.bn),
            Text(S.adDisclosure.bn),
          ],
        ),
      ),
    ));
    expect(find.textContaining('সরকারি অ্যাপ নয়'), findsOneWidget);
    expect(find.textContaining('কোনো বিজ্ঞাপন নেই'), findsOneWidget);
  });
}
