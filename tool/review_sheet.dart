// Regenerates docs/CONTENT_REVIEW.md from the shipped content packs.
//
// Run: dart run tool/review_sheet.dart
//
// The sheet is generated rather than hand-kept so it cannot drift away from
// what the app actually shows.
//
// It used to be one long table of citations: where the claim lived, what it
// cited, and its status — but never the claim itself. A reviewer reading
// "M3 · m3c2 | BDS ISO 6935-2 | review" cannot check anything without opening
// the JSON to find out what was asserted, and 103 rows sat unreviewed. So the
// pending claims are now written out in full, in both languages, with the
// source beside them: an engineer can work down this file on its own and only
// needs the repository to record the answer.
import 'dart:convert';
import 'dart:io';

/// One claim the app makes, and the source it rests on.
class Claim {
  Claim({
    required this.group,
    required this.where,
    required this.title,
    required this.bn,
    required this.en,
    required this.source,
    required this.clause,
    required this.status,
  });

  final String group;
  final String where;
  final String title;
  final String bn;
  final String en;
  final String source;
  final String clause;
  final String status;

  bool get pending => status != 'verified';
}

String _bn(dynamic v) =>
    v is Map ? (v['bn'] as String? ?? '') : (v as String? ?? '');
String _en(dynamic v) =>
    v is Map ? (v['en'] as String? ?? '') : (v as String? ?? '');

void main() {
  final claims = <Claim>[];

  void add({
    required String group,
    required String where,
    required String title,
    required String bn,
    required String en,
    required List<dynamic>? citations,
  }) {
    for (final c in citations ?? const []) {
      final m = c as Map<String, dynamic>;
      claims.add(Claim(
        group: group,
        where: where,
        title: title,
        bn: bn,
        en: en,
        source: _bn(m['source']),
        clause: m['clause'] == null ? '' : _bn(m['clause']),
        status: (m['status'] as String?) ?? 'review',
      ));
    }
  }

  final guideIndex = jsonDecode(
      File('assets/content/guide/index.json').readAsStringSync()) as Map;
  for (final f in guideIndex['modules'] as List) {
    final mod = jsonDecode(
        File('assets/content/guide/modules/$f').readAsStringSync()) as Map;
    for (final card in mod['cards'] as List) {
      add(
        group: 'Guide · ${mod['code']}',
        where: '${mod['code']} · ${card['id']}',
        title: _bn(card['title']),
        bn: _bn(card['body']),
        en: _en(card['body']),
        citations: card['citations'] as List<dynamic>?,
      );
    }
  }

  final index = jsonDecode(
      File('assets/content/checklists/index.json').readAsStringSync()) as Map;
  for (final f in index['packs'] as List) {
    final pack = jsonDecode(
        File('assets/content/checklists/$f').readAsStringSync()) as Map;
    for (final stage in pack['stages'] as List) {
      for (final item in stage['items'] as List) {
        // For a checklist the reviewable claim is the standard, not the
        // question: the question is what to look at, the standard is what the
        // app asserts the rule requires.
        add(
          group: 'Checklist · ${pack['id']}',
          where: '${pack['id']} · ${item['id']}',
          title: _bn(item['question']),
          bn: _bn(item['standard']),
          en: _en(item['standard']),
          citations: item['citations'] as List<dynamic>?,
        );
      }
    }
  }

  final prices = jsonDecode(
      File('assets/content/rates/prices.json').readAsStringSync()) as Map;
  for (final m in prices['materials'] as List) {
    add(
      group: 'Price',
      where: 'price · ${m['id']}',
      title: _bn(m['name']),
      bn: '${m['low_bdt']}–${m['high_bdt']} টাকা প্রতি ${_bn(m['unit'])}, '
          '${m['as_of']} অনুযায়ী।',
      en: '${m['low_bdt']}–${m['high_bdt']} BDT per ${_en(m['unit'])}, '
          'as of ${m['as_of']}.',
      citations: m['sources'] as List<dynamic>?,
    );
  }
  for (final b in prices['benchmarks'] as List) {
    // A benchmark's reviewable claim is the figure and the year together. The
    // year is what usually fails: a cost per kilometre with no year attached
    // cannot be compared to anything.
    add(
      group: 'Benchmark',
      where: 'benchmark · ${b['id']}',
      title: '${_bn(b['country'])} — ${_bn(b['unit'])}',
      bn: '${b['low_usd']}–${b['high_usd']} মার্কিন ডলার, '
          '${_bn(b['unit'])}, বছর ${b['year'] ?? 'অনিশ্চিত'}।',
      en: '${b['low_usd']}–${b['high_usd']} USD, ${_en(b['unit'])}, '
          'year ${b['year'] ?? 'unconfirmed'}.',
      citations: b['sources'] as List<dynamic>?,
    );
  }

  final pending = claims.where((c) => c.pending).toList();
  final byGroup = <String, List<Claim>>{};
  for (final c in pending) {
    byGroup.putIfAbsent(c.group, () => []).add(c);
  }

  final out = StringBuffer()
    ..writeln('# Content review sheet')
    ..writeln()
    ..writeln('Generated by `dart run tool/review_sheet.dart`. Do not edit by '
        'hand — change the `status` field in the content JSON instead.')
    ..writeln()
    ..writeln('- Claims with a citation: **${claims.length}**')
    ..writeln('- Awaiting sign-off: **${pending.length}**')
    ..writeln()
    ..writeln('## For the reviewer')
    ..writeln()
    ..writeln('You do not need the code, the app or the repository to do this. '
        'Every claim still awaiting sign-off is written out below in full, in '
        'Bangla and English, with the source it rests on. For each one, the '
        'question is narrow: **does the cited source actually support this '
        'sentence?**')
    ..writeln()
    ..writeln('Three answers are useful, and "wrong" is the most useful of the '
        'three:')
    ..writeln()
    ..writeln('- **Correct** — the source supports it as written.')
    ..writeln('- **Wrong** — it does not. Say what the source actually says.')
    ..writeln('- **Right but misleading** — true in the source, misleading to '
        'a homeowner reading it without the surrounding context. This one '
        'matters: the readers are not engineers, and a claim that is '
        'technically correct and practically misread is a defect here even '
        'though it would pass a code review.')
    ..writeln()
    ..writeln('Mark each block and send it back however is easiest — a marked '
        'copy of this file, a list of IDs, or notes on paper. Nothing moves to '
        '`verified` without a name against it.')
    ..writeln()
    ..writeln('The rights and procurement claims need someone who has actually '
        'filed RTI applications in Bangladesh, not a civil engineer.')
    ..writeln()
    ..writeln('Until a claim is signed off the app shows an amber '
        '"ইঞ্জিনিয়ার যাচাই বাকি" badge on it, so nothing here is being '
        'presented to a reader as settled.')
    ..writeln()
    ..writeln('## What is left, by area')
    ..writeln()
    ..writeln('| Area | Awaiting |')
    ..writeln('|---|---|');
  final groups = byGroup.keys.toList()..sort();
  for (final g in groups) {
    out.writeln('| $g | ${byGroup[g]!.length} |');
  }

  out
    ..writeln()
    ..writeln('## The claims')
    ..writeln();
  for (final g in groups) {
    out
      ..writeln('### $g')
      ..writeln();
    for (final c in byGroup[g]!) {
      out
        ..writeln('#### `${c.where}` — ${c.title}')
        ..writeln()
        ..writeln('> ${c.bn.replaceAll('\n', '\n> ')}')
        ..writeln()
        ..writeln('> *${c.en.replaceAll('\n', '\n> ')}*')
        ..writeln()
        ..writeln('**Source** ${c.source}'
            '${c.clause.isEmpty ? '' : ' — ${c.clause}'}')
        ..writeln()
        ..writeln('Correct ☐  Wrong ☐  Right but misleading ☐ '
            '  Reviewer \\_\\_\\_\\_\\_  Date \\_\\_\\_\\_\\_')
        ..writeln()
        ..writeln('---')
        ..writeln();
    }
  }

  final verified = claims.where((c) => !c.pending).toList();
  out
    ..writeln('## Already signed off (${verified.length})')
    ..writeln()
    ..writeln('| Where | Source |')
    ..writeln('|---|---|');
  for (final c in verified) {
    out.writeln('| ${c.where} | ${c.source} |');
  }

  Directory('docs').createSync(recursive: true);
  File('docs/CONTENT_REVIEW.md').writeAsStringSync(out.toString());
  stdout.writeln('docs/CONTENT_REVIEW.md: ${claims.length} claims, '
      '${pending.length} awaiting review');
}
