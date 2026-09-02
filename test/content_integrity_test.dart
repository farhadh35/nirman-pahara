import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;
  setUp(() => repo = ContentRepository(reader: _fromDisk));

  group('Every card', () {
    test('that states a number says where the number came from', () async {
      // Rule 1 of docs/CONTENT_RULES.md: every technical number carries a
      // source. Cards that state no number — what to take to a site, how to
      // stay safe — legitimately cite nothing, so the test looks for digits
      // rather than demanding a citation from every card regardless.
      final digit = RegExp(r'[0-9\u09E6-\u09EF]');
      for (final c in (await repo.guide()).cards) {
        final text = [
          c.body.bn,
          c.body.en ?? '',
          for (final w in c.watchFor) ...[w.bn, w.en ?? ''],
        ].join(' ');
        if (digit.hasMatch(text)) {
          expect(c.citations, isNotEmpty,
              reason: '${c.id} states a number and cites nothing');
        }
      }
    });

    test('says who it is for', () async {
      // Tier is a field rather than a convention so this test can exist.
      for (final c in (await repo.guide()).cards) {
        expect(CardTier.values, contains(c.tier), reason: c.id);
      }
    });

    test('is written in both languages, title, body and all', () async {
      for (final c in (await repo.guide()).cards) {
        expect(c.title.needsTranslation, isFalse, reason: '${c.id} title');
        expect(c.body.needsTranslation, isFalse, reason: '${c.id} body');
        for (final w in c.watchFor) {
          expect(w.needsTranslation, isFalse, reason: '${c.id} watch_for');
        }
      }
    });

    test('has an id nothing else shares', () async {
      final seen = <String>{};
      for (final c in (await repo.guide()).cards) {
        expect(seen.add(c.id), isTrue, reason: '${c.id} appears twice');
      }
    });
  });

  group('The split guide', () {
    test('keeps every module file under the isolate threshold', () async {
      // Above roughly 50 KB the bundle decodes on a worker isolate, which is
      // invisible on a device and hangs a widget test waiting to settle. This
      // is why the guide is split at all, so the reason is asserted, not
      // remembered.
      final dir = Directory('assets/content/guide/modules');
      final files = dir.listSync().whereType<File>().toList();
      expect(files, isNotEmpty);
      for (final f in files) {
        expect(f.lengthSync(), lessThan(50000),
            reason: '${f.path} would decode off the main isolate');
      }
    });

    test('lists exactly the module files that exist', () async {
      // A module on disk but not in the index is content nobody can reach; one
      // in the index but not on disk crashes the guide on open.
      final index = File('assets/content/guide/index.json').readAsStringSync();
      final onDisk = Directory('assets/content/guide/modules')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toSet();
      for (final name in onDisk) {
        expect(index, contains(name), reason: '$name is not in the index');
      }
      expect((await repo.guide()).modules.length, onDisk.length);
    });
  });

  group('A card badges itself by its weakest claim', () {
    test('one unchecked citation badges the whole card', () {
      const verified = Citation(
          source: L10nText('a', 'a'), status: ReviewStatus.verified);
      const review =
          Citation(source: L10nText('b', 'b'), status: ReviewStatus.review);
      const thumb = Citation(
          source: L10nText('c', 'c'), status: ReviewStatus.ruleOfThumb);

      GuideCard card(List<Citation> cites) => GuideCard(
            id: 'x',
            title: const L10nText('t', 't'),
            body: const L10nText('b', 'b'),
            citations: cites,
          );

      expect(card([verified]).status, ReviewStatus.verified);
      expect(card([verified, review]).status, ReviewStatus.review);
      // A rule of thumb outranks review: it needs the blunter warning.
      expect(card([verified, review, thumb]).status, ReviewStatus.ruleOfThumb);
    });
  });
}
