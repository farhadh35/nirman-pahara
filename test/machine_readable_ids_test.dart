import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Identifiers must reach the reader in the form a machine will accept.
///
/// Bangla digits are correct for a number someone reads and wrong for one they
/// type back into a search box or paste into a map. Three had been converted —
/// the tender ID, photograph coordinates and the BoQ serial — and each was in
/// the document handed to an authority. This holds the line against the fourth.
void main() {
  String read(String p) => File(p).readAsStringSync();

  test('a schedule item code is never put through digit localisation', () {
    // The code is how a reader and an official find the same row in the
    // printed schedule. It has always been correct; nothing says so.
    final src = read('lib/features/prices/ui/boq_tab.dart');
    expect(src, contains('item.code'));
    expect(src, isNot(contains('localiseDigits(item.code')));
  });

  test('the tender ID reaches both reports unconverted', () {
    for (final p in const [
      'lib/features/inspection/logic/inspection_run.dart',
      'lib/features/inspection/report/report_sheet.dart',
    ]) {
      final src = read(p);
      expect(src, isNot(contains('localiseDigits(run.tenderId')),
          reason: '$p converts a tender ID the portal will not match');
      expect(src, isNot(contains('d(tenderId)')),
          reason: '$p converts a tender ID the portal will not match');
    }
  });

  test('coordinates are not converted', () {
    final src = read('lib/features/inspection/logic/photo_ref.dart');
    // The timestamp above them still is — both live in one caption.
    expect(src, contains('Bn.localiseDigits('),
        reason: 'the timestamp should still be localised');
    expect(src, isNot(contains('localiseDigits(\n      \'\${latitude')),
        reason: 'a coordinate no map will accept');
    final describe = src.substring(src.indexOf('String describe'));
    final where = describe.substring(describe.indexOf('final where'));
    expect(where.split('\n').take(3).join('\n'),
        isNot(contains('localiseDigits')),
        reason: 'the place half of the caption is being converted');
  });

  test('the rule is written down where someone will reach for it', () {
    // The next person to call this function should not have to rediscover it
    // from a bug in a shared PDF.
    final src = read('lib/core/util/bn.dart');
    expect(src, contains('do they put it back into a machine'));
  });
}
