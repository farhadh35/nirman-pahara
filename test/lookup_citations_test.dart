import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

/// Does a cited item actually say what the row says?
///
/// The five-inch wall row stated a 1:4 mortar and cited PWD SoR item 04.15,
/// which is the 1:6 version of that wall; 04.16 is the 1:4. The figure was
/// right and the citation pointed at the item contradicting it, on a row marked
/// verified — in an app whose whole case is that every number is traceable.
///
/// Nothing checked citations against the schedule the app already ships, so
/// nothing could have caught it. This does.
void main() {
  late Map<String, String> sorDescriptions;

  setUpAll(() async {
    final raw = await _fromDisk('assets/content/rates/pwd_sor_2022.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    sorDescriptions = {
      for (final item in (json['items'] as List).cast<Map<String, dynamic>>())
        item['code'] as String: (item['desc'] as String? ?? ''),
    };
    expect(sorDescriptions, isNotEmpty);
  });

  test('every cited PWD item exists in the schedule the app ships', () async {
    final pack = await ContentRepository(reader: _fromDisk).lookups();
    final cited = RegExp(r'PWD SoR 2022,\s*item\s*([0-9.]+)');
    final missing = <String>[];
    var checked = 0;

    for (final table in pack.tables) {
      for (final row in table.rows) {
        final m = cited.firstMatch(row.source);
        if (m == null) continue;
        checked++;
        final code = m.group(1)!;
        if (!sorDescriptions.containsKey(code)) {
          missing.add('${table.id}: "${row.subject.bn}" cites item $code, '
              'which is not in the schedule');
        }
      }
    }
    expect(checked, greaterThan(0), reason: 'no PWD citations were examined');
    expect(missing, isEmpty);
  });

  test('a cited item whose row states a mix ratio actually carries that ratio',
      () async {
    // The narrow, checkable version of the error that happened: the row says
    // 1:4, the schedule item says (1:6). Only rows that state a ratio and cite
    // a specific item can be checked this way, which is exactly the shape the
    // mistake took.
    final pack = await ContentRepository(reader: _fromDisk).lookups();
    final cited = RegExp(r'PWD SoR 2022,\s*item\s*([0-9.]+)');
    final rowRatio = RegExp(r'^(\d+\s*:\s*\d+)$');
    // The schedule prints the mortar ratio in brackets: "... mortar (1:6) ...".
    final printedRatio = RegExp(r'\((\d+\s*:\s*\d+)\)');
    final wrong = <String>[];
    var checked = 0;

    String tidy(String s) => s.replaceAll(' ', '');

    for (final table in pack.tables) {
      for (final row in table.rows) {
        final m = cited.firstMatch(row.source);
        if (m == null || !rowRatio.hasMatch(row.value.trim())) continue;
        final desc = sorDescriptions[m.group(1)!] ?? '';
        // Read the ratio out of the cited item, then compare. An earlier
        // version of this test skipped any item whose description did not
        // already contain the row's ratio — which is exactly the failing case,
        // so it passed on the very error it was written for.
        final printed = printedRatio.firstMatch(desc);
        if (printed == null) continue;
        checked++;
        if (tidy(printed.group(1)!) != tidy(row.value.trim())) {
          wrong.add('${table.id}: "${row.subject.bn}" says ${row.value} but '
              'item ${m.group(1)} prints (${printed.group(1)}) — '
              '${desc.substring(0, 70)}…');
        }
      }
    }
    expect(checked, greaterThan(0),
        reason: 'no ratio-bearing citation was examined, so this proves '
            'nothing — the pattern that matches the schedule text has drifted');
    expect(wrong, isEmpty);
  });

  test('a table of shares adds up to a whole', () async {
    // The cost-share table shipped nine rows summing to 95%. Its own cited
    // source is a ten-item list summing to 100; the missing line was বিবিধ at
    // 5%. A share table that does not reach 100 is either incomplete or wrong,
    // and either way the reader is budgeting against a hole.
    final pack = await ContentRepository(reader: _fromDisk).lookups();
    final percent = RegExp(r'^([\d.]+)\s*%$');
    var tablesChecked = 0;

    for (final table in pack.tables) {
      final values = [
        for (final row in table.rows) percent.firstMatch(row.value.trim()),
      ];
      // Only a table where every row is a percentage can be a share table.
      if (values.isEmpty || values.any((v) => v == null)) continue;
      tablesChecked++;
      final total = values
          .map((v) => double.parse(v!.group(1)!))
          .fold<double>(0, (a, b) => a + b);
      expect(total, closeTo(100, 0.01),
          reason: '${table.id}: the shares add up to $total, not 100');
    }
    expect(tablesChecked, greaterThan(0),
        reason: 'no share table was found, so this test proves nothing');
  });
}
