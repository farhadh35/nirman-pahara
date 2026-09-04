import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/sources/logic/reference_work.dart';

/// Google Play rejected this app on 4 September 2026 under the Misleading
/// Claims policy: "Missing Source Link for Government Information — your app
/// provides government information but lacks one or more clear and accessible
/// URL/link(s) to the original source(s)". The evidence Play quoted was the
/// store listing's paragraph about the PWD Schedule of Rates.
///
/// The fix has two halves, and both are held here, because the cost of either
/// silently coming undone is the app being pulled again.
void main() {
  test('every government work names where its publisher issues it', () {
    final missing = [
      for (final w in ReferenceWork.all)
        if (w.isGovernment && (w.url == null || w.url!.isEmpty)) w.id,
    ];
    expect(missing, isEmpty,
        reason: 'these government works cite no source URL, which is the exact '
            'thing Play rejected the app for');
  });

  test('at least the three works Play named carry a link', () {
    // The rate schedules, the building code and the gazette are the government
    // documents the app leans on hardest.
    for (final id in ['pwd_sor', 'bnbc', 'gazette_2025']) {
      final work = ReferenceWork.all.firstWhere((w) => w.id == id);
      expect(work.url, isNotNull, reason: '$id has no source link');
      expect(work.isGovernment, isTrue, reason: '$id is not marked government');
    }
  });

  test('source links are absolute http(s) addresses, not prose', () {
    for (final w in ReferenceWork.all) {
      if (w.url == null) continue;
      expect(RegExp(r'^https?://').hasMatch(w.url!), isTrue,
          reason: '${w.id}: "${w.url}" is not a URL a reader can open');
    }
  });

  test('both store listings carry the government source links', () {
    // Play read the listing, not the app, when it rejected this.
    for (final path in ['store/LISTING-en.md', 'store/LISTING-bn.md']) {
      final text = File(path).readAsStringSync();
      for (final host in [
        'ss.pwd.gov.bd',
        'hbri.gov.bd',
        'rajuk.gov.bd',
        'bdlaws.minlaw.gov.bd',
      ]) {
        expect(text, contains(host),
            reason: '$path does not link $host, so the government figures it '
                'quotes have no traceable origin');
      }
    }
  });

  test('both store listings disclaim being a government entity', () {
    final en = File('store/LISTING-en.md').readAsStringSync().toLowerCase();
    expect(en, contains('not a government body'),
        reason: 'the English listing does not say the app is not government');
    expect(en, contains('not affiliated with'),
        reason: 'the English listing does not disclaim affiliation');

    final bn = File('store/LISTING-bn.md').readAsStringSync();
    expect(bn, contains('কোনো সরকারি দপ্তর নয়'),
        reason: 'the Bangla listing does not say the app is not government');
  });

  test('the app itself disclaims being a government entity', () {
    // Play asked for the clarification in the app as well as the listing.
    final screen =
        File('lib/features/sources/ui/sources_screen.dart').readAsStringSync();
    expect(screen, contains('কোনো সরকারি দপ্তর নয়'),
        reason: 'the sources screen carries no Bangla disclaimer');
    expect(screen, contains('not a government body'),
        reason: 'the sources screen carries no English disclaimer');
  });
}
