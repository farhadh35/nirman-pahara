import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
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

  test('every citation in the app reaches the sources page', () async {
    // Counted straight off the packs, independently of the index.
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
        reason: 'the page carries ${index.useCount} of $expected citations; '
            'the rest are now unreachable from anywhere in the app');
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

  test('the most relied-upon source is listed first', () async {
    final index = await build();
    final counts = [for (final e in index.entries) e.uses.length];
    expect(counts, orderedEquals([...counts]..sort((a, b) => b.compareTo(a))),
        reason: 'a reader checking what the app rests on should meet the '
            'load-bearing sources first');
  });

  test('the unverified count matches what the badges claim', () async {
    final index = await build();
    var pending = 0;
    for (final e in index.entries) {
      pending += e.uses.where((u) => u.status.needsBadge).length;
    }
    expect(index.pendingCount, pending);
    expect(index.pendingCount, greaterThan(0),
        reason: 'if nothing is pending, the amber badge should be gone too');
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
