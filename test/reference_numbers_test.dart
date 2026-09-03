import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/sources/logic/reference_work.dart';
import 'package:nirman_pahara/features/sources/logic/source_index.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

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

  test('the numbers run 1..N with no gap and no repeat', () {
    // A reader matches a number on a card against a number on the page. A gap
    // means a card points at nothing; a repeat means it points at two things.
    final numbers = [for (final w in ReferenceWork.all) w.number]..sort();
    expect(numbers, List.generate(ReferenceWork.all.length, (i) => i + 1));
  });

  test('the page order is the numbering order', () async {
    // The numbers are printed down the page, so they have to arrive in order.
    // If the page ever re-sorts, this fails rather than shipping 1, 4, 2.
    final index = await build();
    final onPage = [
      for (final e in index.entries)
        if (e.number != null) e.number!,
    ];
    expect(onPage, [...onPage]..sort(),
        reason: 'the reference page lists its entries out of numerical order');
  });

  testWidgets('every citation the app carries resolves to a number',
      (tester) async {
    // A citation matching no known work renders no mark at all — the claim
    // would silently lose its source. This is the test that catches a new
    // citation being written in a form the matcher does not recognise.
    late List<String> orphans;
    await tester.runAsync(() async {
      final guide = await repo.guide();
      final checklists = await repo.checklists();
      final lookups = await repo.lookups();
      final prices = await repo.prices();
      final all = <String>[
        for (final m in [...guide.modules, ...guide.reference])
          for (final c in m.cards)
            for (final cit in c.citations) cit.source.bn,
        for (final ChecklistPack p in checklists)
          for (final s in p.stages)
            for (final i in s.items)
              for (final cit in i.citations) cit.source.bn,
        for (final t in lookups.tables)
          for (final r in t.rows) r.source,
        for (final m in prices.materials)
          for (final c in m.sources) c.source.bn,
        for (final b in prices.benchmarks)
          for (final c in b.sources) c.source.bn,
      ];
      orphans = [
        for (final s in all)
          if (s.trim().isNotEmpty && ReferenceWork.numberFor(s) == null) s,
      ];
    });
    expect(orphans, isEmpty,
        reason: 'these citations would show no reference mark at all');
  });

  test('a source matching nothing gets no number rather than a wrong one', () {
    expect(ReferenceWork.numberFor('something never written down'), isNull);
  });
}
