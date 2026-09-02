import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;
  setUp(() => repo = ContentRepository(reader: _fromDisk));

  group('Every checklist item', () {
    test('that states a standard says where the standard came from', () async {
      // An item that quotes a figure sends the reader to argue with a
      // contractor, and it has to say what the figure rests on. Items that ask
      // an observational question -- is there rubbish on site, does water stand
      // here -- state no standard and need no source.
      for (final pack in await repo.checklists()) {
        for (final stage in pack.stages) {
          for (final item in stage.items) {
            if (item.standard == null) continue;
            expect(item.citations, isNotEmpty,
                reason: '${pack.id} / ${item.id} states a standard '
                    'and cites nothing');
          }
        }
      }
    });

    test('that states a standard also says how to check it', () async {
      // A figure without a method is not actionable: the reader knows what the
      // answer should be and not how to find out what it is.
      for (final pack in await repo.checklists()) {
        for (final stage in pack.stages) {
          for (final item in stage.items) {
            expect(item.why.needsTranslation, isFalse, reason: item.id);
            expect(item.question.needsTranslation, isFalse, reason: item.id);
            if (item.standard == null) continue;
            expect(item.how, isNotNull,
                reason: '${item.id} gives a figure but not a way to check it');
          }
        }
      }
    });

    test('has an id unique inside its pack', () async {
      for (final pack in await repo.checklists()) {
        final seen = <String>{};
        for (final stage in pack.stages) {
          for (final item in stage.items) {
            expect(seen.add(item.id), isTrue,
                reason: '${pack.id} repeats ${item.id}');
          }
        }
      }
    });
  });

  group('The godown pack', () {
    test('asks for the drawing before it asks for any measurement', () async {
      // Every dimension in this pack is stated as "what the drawing says",
      // so the drawing has to be the first thing on the list rather than an
      // afterthought two stages in.
      final pack = (await repo.checklists())
          .firstWhere((p) => p.id == 'food_godown');
      expect(pack.stages.first.id, 'g0_drawing');
      final first = pack.stages.first.items.first;
      expect(first.question.bn, contains('নকশা'));
    });

    test('names the type design rather than passing it off as a standard',
        () async {
      // The figures come from one Directorate General of Food type design. They
      // recur at many sites, which is what makes them useful, and they are still
      // not a national standard. Every item that quotes one has to say so.
      final pack = (await repo.checklists())
          .firstWhere((p) => p.id == 'food_godown');
      final quoting = [
        for (final s in pack.stages)
          for (final i in s.items)
            if (i.citations.any((c) => c.source.bn.contains('টাইপ ডিজাইন'))) i,
      ];
      expect(quoting.length, greaterThanOrEqualTo(6));
      for (final i in quoting) {
        expect(i.citations.first.source.en, contains('not a universal standard'),
            reason: i.id);
      }
    });

    test('every measurable item tells the reader to use their own drawing',
        () async {
      final pack = (await repo.checklists())
          .firstWhere((p) => p.id == 'food_godown');
      final typeDesign = [
        for (final s in pack.stages)
          for (final i in s.items)
            if (i.citations.any((c) => c.source.bn.contains('টাইপ ডিজাইন')) &&
                i.id != 'g0a' &&
                i.id != 'g0b')
              i,
      ];
      for (final i in typeDesign) {
        final text = '${i.question.bn} ${i.standard?.bn ?? ''} ${i.how?.bn ?? ''}';
        expect(text, contains('নকশা'),
            reason: '${i.id} quotes a dimension without pointing at the drawing');
      }
    });
  });

  test('the RTI application asks for the approved drawing', () async {
    // Everything the godown pack measures is measured against that drawing, so
    // the application that fetches documents has to ask for it.
    final rights = await repo.rights();
    final rti = rights.letters.firstWhere((l) => l.id == 'rti_application');
    expect(rti.body.bn, contains('অনুমোদিত নকশা'));
    expect(rti.body.en, contains('approved drawings'));
  });
}
