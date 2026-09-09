import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/sources/logic/reference_work.dart';

/// What a source link has to be worth.
///
/// Play rejected this app three times over its government sources. The third
/// time was "Broken or Inaccessible Source Link", and it was right: ten
/// official addresses had been checked with curl from a machine in Dhaka and
/// all ten returned 200, but six of the publishers serve an incomplete TLS
/// certificate chain. That machine had already cached the missing
/// intermediate. Every other client in the world gets "unable to verify the
/// first certificate" and a security warning.
///
/// So the rule changed. A citation is not an address somebody once typed; it
/// is an address a stranger can open. These tests hold the app to the smaller
/// set that survives that test, and stop the six from being written back.
void main() {
  /// Verified from outside Bangladesh on 9 September 2026.
  const reachable = {
    'ss.pwd.gov.bd',
    'bdlaws.minlaw.gov.bd',
    'grs.gov.bd',
    'www.eprocure.gov.bd',
  };

  test('every link the app shows is one that opens for a stranger', () {
    final offending = <String>[];
    for (final w in ReferenceWork.all) {
      if (w.url == null) continue;
      final host = Uri.parse(w.url!).host;
      if (!reachable.contains(host)) offending.add('${w.id} -> $host');
    }
    expect(offending, isEmpty,
        reason: 'these link a host that was not verified reachable from '
            'outside Bangladesh: $offending. Check it with a client that has '
            'no cached intermediate before adding it — a local curl passing is '
            'not evidence, and that is exactly how the third rejection '
            'happened');
  });

  test('no publisher with a broken certificate is cited anywhere', () {
    // Not just in the reference list: the listing files and the app source
    // are where a dead address would do the damage.
    final searched = <String, String>{
      for (final path in [
        'lib/features/sources/logic/reference_work.dart',
        'store/play-description-en.txt',
        'store/LISTING-en.md',
        'store/LISTING-bn.md',
      ])
        path: File(path).readAsStringSync(),
    };
    final found = <String>[];
    searched.forEach((path, text) {
      for (final host in ReferenceWork.kKnownUnreachableHosts) {
        // The denylist itself is allowed to name them.
        if (path.endsWith('reference_work.dart') &&
            text.indexOf(host) > text.indexOf('kKnownUnreachableHosts')) {
          continue;
        }
        if (text.contains('://$host') || text.contains('://www.$host')) {
          found.add('$path: $host');
        }
      }
    });
    expect(found, isEmpty,
        reason: 'a publisher whose certificate chain is broken is being cited '
            'as a source again: $found');
  });

  test('the schedule of rates still carries its link', () {
    // The one heavyweight government document whose publisher does serve a
    // valid chain. If this ever goes, the app has no linkable government
    // source left at all and the listing has to say so.
    final work = ReferenceWork.all.firstWhere((w) => w.id == 'pwd_sor');
    expect(work.url, 'https://ss.pwd.gov.bd/sor');
    expect(work.isGovernment, isTrue);
  });

  test('source links are absolute https addresses', () {
    // http:// gets upgraded or warned about by the browser a reviewer uses,
    // which is its own kind of broken.
    for (final w in ReferenceWork.all) {
      if (w.url == null) continue;
      expect(w.url!.startsWith('https://'), isTrue,
          reason: '${w.id}: "${w.url}" is not https');
    }
  });

  test('a work with no reachable publisher carries no link at all', () {
    // Rather than a plausible-looking address that opens a security warning.
    for (final id in ['bnbc', 'gazette_2025', 'dg_food', 'bds_steel',
      'lged_roads', 'acc']) {
      final work = ReferenceWork.all.firstWhere((w) => w.id == id);
      expect(work.url, isNull,
          reason: '$id has a link again; its publisher had a broken '
              'certificate chain when this was written, so check it from '
              'outside Bangladesh before restoring one');
    }
  });

  test('both store listings disclaim being a government entity', () {
    final en = File('store/LISTING-en.md').readAsStringSync().toLowerCase();
    expect(en, contains('not a government'),
        reason: 'the English listing does not say the app is not government');
    expect(en, contains('not affiliated with'),
        reason: 'the English listing does not disclaim affiliation');

    final bn = File('store/LISTING-bn.md').readAsStringSync();
    expect(bn, contains('সরকারি অ্যাপ নয়'),
        reason: 'the Bangla listing does not say the app is not government');
  });

  test('the app itself disclaims being a government entity', () {
    final screen =
        File('lib/features/sources/ui/sources_screen.dart').readAsStringSync();
    expect(screen, contains('কোনো সরকারি দপ্তর নয়'),
        reason: 'the sources screen carries no Bangla disclaimer');
    expect(screen, contains('not a government body'),
        reason: 'the sources screen carries no English disclaimer');
  });
}
