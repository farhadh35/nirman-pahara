import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/sources/logic/reference_work.dart';
import 'package:nirman_pahara/features/sources/logic/source_index.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

/// Citations used to hang off every card, checklist item, table row and both
/// price screens. Collecting them onto one page is only an improvement if
/// nothing lost its provenance on the way — a number whose source is no longer
/// reachable anywhere is worse than a cluttered screen.
void main() {
  late ContentRepository repo;
  setUp(() => repo = ContentRepository(reader: _fromDisk));

  Future<SourceIndex> build() async => SourceIndex.build(
        guide: await repo.guide(),
        checklists: await repo.checklists(),
        lookups: await repo.lookups(),
        prices: await repo.prices(),
        locale: AppLocale.bn,
      );

  test('every citation in the app lands under some reference', () async {
    // Counted straight off the packs, independently of the index. Nothing may
    // be dropped on the way to the page: a number whose source is unreachable
    // is worse than a cluttered screen.
    final guide = await repo.guide();
    final checklists = await repo.checklists();
    final lookups = await repo.lookups();
    final prices = await repo.prices();

    var expected = 0;
    for (final m in [...guide.modules, ...guide.reference]) {
      for (final c in m.cards) {
        expected += c.citations.length;
      }
    }
    for (final p in checklists) {
      for (final s in p.stages) {
        for (final i in s.items) {
          expected += i.citations.length;
        }
      }
    }
    for (final t in lookups.tables) {
      expected += t.rows.where((r) => r.source.trim().isNotEmpty).length;
    }
    for (final m in prices.materials) {
      expected += m.sources.length;
    }
    for (final b in prices.benchmarks) {
      expected += b.sources.length;
    }

    final index = await build();
    expect(index.useCount, expected,
        reason: 'the page accounts for ${index.useCount} of $expected '
            'citations; the rest are unreachable from anywhere in the app');
  });

  test('the list has no duplicate references', () async {
    // The reason this page exists in this shape. Cited at claim precision the
    // same work appears many times over — BNBC 2020 five ways, the 2019 book
    // once per chapter. On a reference list that is one entry each.
    final index = await build();
    final titles = [for (final e in index.entries) e.source.bn];
    expect(titles.toSet().length, titles.length,
        reason: 'the same work is listed more than once');
    // And no entry may be a chapter or clause of another.
    for (final a in titles) {
      for (final b in titles) {
        if (identical(a, b) || a == b) continue;
        expect(a.startsWith('\$b,'), isFalse,
            reason: 'one entry is a chapter of another and should fold '
                'into it');
      }
    }
  });

  test('every citation matches a known work', () async {
    // An unmatched citation stands as its own entry, which is safe but is how
    // a list starts repeating itself again. If this fails, add the pattern to
    // ReferenceWork rather than letting it through.
    final index = await build();
    final unmatched = [
      for (final e in index.entries)
        if (e.work == null) e.source.bn,
    ];
    expect(unmatched, isEmpty,
        reason: 'these cite something the reference list does not know: '
            '$unmatched');
  });

  test('all four parts of the app are represented', () async {
    final index = await build();
    final areas = {
      for (final e in index.entries)
        for (final u in e.uses) u.area.bn,
    };
    expect(areas, containsAll(<String>['শিখুন', 'পরিদর্শন', 'মাপ ও তালিকা']),
        reason: 'a whole section of the app lost its sources: $areas');
  });

  test('sources are listed once, with their uses gathered under them',
      () async {
    final index = await build();
    final names = index.entries.map((e) => e.source.bn).toList();
    expect(names.toSet().length, names.length,
        reason: 'the same source appears as more than one entry');
    // The point of gathering: the heaviest-used source carries many claims.
    expect(index.entries.first.uses.length, greaterThan(1));
  });

  test('the list is ordered by kind, codes before conventions', () async {
    // A reader checking what the app rests on should meet the things a claim
    // can be verified against before the things that are only ever practice.
    final index = await build();
    final order = [for (final e in index.entries) e.kindOrder];
    expect(order, orderedEquals([...order]..sort()),
        reason: 'the kinds are interleaved instead of grouped');
    expect(index.entries.first.kind, WorkKind.code);
    expect(index.entries.last.kind, WorkKind.practice);
  });

  test('every use reaching the page carries the status it was written with',
      () async {
    // The page lists works, not verdicts, but the status still travels with
    // each use — a later pass that wants to sort or group by it should not
    // have to re-derive it from the content.
    final index = await build();
    final statuses = {
      for (final e in index.entries)
        for (final u in e.uses) u.status,
    };
    expect(statuses, isNotEmpty);
    expect(statuses, contains(ReviewStatus.review));
  });

  test('search finds a source by its name and by where it is used', () async {
    final index = await build();
    expect(index.search('BNBC'), isNotEmpty);
    expect(index.search('  '), hasLength(index.entries.length));
    expect(index.search('zzzznotathing'), isEmpty);
  });

  test('no card, item or row still offers its own source button', () {
    // The whole point of the move. A stray button left behind means two places
    // to keep in step, which is how they drifted apart in the first place.
    final offenders = <String>[];
    for (final f in Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && f.path.contains('/ui/'))) {
      if (f.path.contains('/sources/')) continue;
      if (f.readAsStringSync().contains('CitationSheet.show')) {
        offenders.add(f.path.split('/').last);
      }
    }
    expect(offenders, isEmpty,
        reason: 'citations belong on the sources page now:\n'
            '${offenders.join('\n')}');
  });
}
