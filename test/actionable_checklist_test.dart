import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// An item that tells the reader to demand something has to say how.
///
/// The building pack's most consequential item — "were test cylinders cast?" —
/// had a `why` and no `how`, while the items either side of it in the same
/// pour stage both had one. So the app asked a homeowner to insist on the one
/// check that actually proves strength, and then said nothing about how a
/// private householder gets it done. That is the sort of gap that reads as
/// complete because every individual card looks finished.
List<Map<String, dynamic>> _items(String pack) {
  final root = jsonDecode(
      File('assets/content/checklists/$pack.json').readAsStringSync());
  final out = <Map<String, dynamic>>[];
  void walk(dynamic node) {
    if (node is Map<String, dynamic>) {
      if (node.containsKey('question')) out.add(node);
      node.values.forEach(walk);
    } else if (node is List) {
      node.forEach(walk);
    }
  }
  walk(root);
  return out;
}

void main() {
  test('the test-cylinder item says how, not just why', () {
    final item = _items('building').firstWhere((i) => i['id'] == 'b10');
    expect(item['how'], isNotNull,
        reason: 'b10 asks the reader to insist on a laboratory test and does '
            'not say how to arrange one');
    final en = (item['how'] as Map)['en'] as String;
    expect(en.toLowerCase(), contains('before the pour'),
        reason: 'the timing is the whole point — cylinders cannot be cast '
            'after the concrete is placed');
    expect((item['how'] as Map)['bn'], isNotEmpty);
  });

  test('no item demands something without explaining it', () {
    // A `how` is not required everywhere — plenty of questions answer
    // themselves. But an item carrying a citation is one the app is leaning
    // on a published source for, and those should tell the reader what to do.
    final missing = <String>[];
    for (final pack in ['building', 'road', 'godown', 'repair', 'electrical']) {
      for (final item in _items(pack)) {
        if (item['citations'] != null && item['how'] == null) {
          missing.add('$pack/${item['id']}');
        }
      }
    }
    expect(missing, isEmpty,
        reason: 'these cite a source for what they demand but never say how '
            'the reader acts on it: $missing');
  });
}
