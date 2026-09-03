import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Checklist pack and item ids are a data contract with the phones already out
/// there, not just names in a JSON file.
///
/// A saved inspection stores its findings keyed by item id, and its photographs
/// hang off those findings. On load, a finding whose item no longer exists is
/// dropped with `?.` and a run whose pack no longer exists returns null. Neither
/// crashes, which is right — but neither says anything either. Rename an id and
/// a reader's recorded observation, and the photograph they took to prove it,
/// disappear from their report with no word, while the image file stays on disk
/// orphaned.
///
/// Between 1.0.0 and 2.0.0 the godown and building checklists nearly doubled
/// and not one id was lost. That was care, not machinery. This is the
/// machinery: ids may be added, never removed or renamed.
void main() {
  Map<String, Set<String>> currentIds() {
    final out = <String, Set<String>>{};
    for (final f in Directory('assets/content/checklists').listSync()) {
      if (f is! File || f.path.endsWith('index.json')) continue;
      final d = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      out[d['id'] as String] = {
        for (final s in d['stages'] as List)
          for (final i in (s as Map)['items'] as List) (i as Map)['id'] as String,
      };
    }
    return out;
  }

  test('no checklist id that has ever shipped has been dropped', () {
    final shipped = (jsonDecode(
            File('test/fixtures/shipped_checklist_ids.json').readAsStringSync())
        as Map<String, dynamic>);
    final now = currentIds();

    final missingPacks = <String>[];
    final missingItems = <String>[];
    shipped.forEach((pack, ids) {
      final live = now[pack];
      if (live == null) {
        missingPacks.add(pack);
        return;
      }
      for (final id in (ids as List).cast<String>()) {
        if (!live.contains(id)) missingItems.add('$pack · $id');
      }
    });

    expect(missingPacks, isEmpty,
        reason: 'every saved inspection in this pack silently vanishes from '
            'the reader\'s list on upgrade:\n${missingPacks.join('\n')}');
    expect(missingItems, isEmpty,
        reason: 'saved findings under these ids, and the photographs attached '
            'to them, are silently dropped on upgrade:\n'
            '${missingItems.join('\n')}\n'
            'Add ids freely; renaming one destroys data already on phones. If '
            'a rename is genuinely needed, migrate the saved runs first.');
  });

  test('the fixture covers every pack the app ships today', () {
    // Otherwise a new pack could be added, renamed, and never noticed.
    final shipped = (jsonDecode(
            File('test/fixtures/shipped_checklist_ids.json').readAsStringSync())
        as Map<String, dynamic>);
    for (final pack in currentIds().keys) {
      expect(shipped.containsKey(pack), isTrue,
          reason: 'pack "$pack" is shipping but is not in the contract '
              'fixture — regenerate it so its ids are protected too');
    }
  });
}
