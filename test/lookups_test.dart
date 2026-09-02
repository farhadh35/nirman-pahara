import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;
  setUp(() => repo = ContentRepository(reader: _fromDisk));

  test('the pack loads with every table it is meant to carry', () async {
    final p = await repo.lookups();
    for (final id in ['mix', 'curing', 'striking', 'sand', 'cost_share']) {
      expect(p.byId(id), isNotNull, reason: id);
    }
  });

  test('every row says where its figure came from', () async {
    // The whole point of a lookup is that the answer can be traced. A row
    // without a source is a bare number, which rule 1 of CONTENT_RULES forbids.
    for (final t in (await repo.lookups()).tables) {
      for (final r in t.rows) {
        expect(r.source.trim(), isNotEmpty, reason: '${t.id} / ${r.subject.bn}');
        expect(r.value.trim(), isNotEmpty, reason: '${t.id} / ${r.subject.bn}');
        expect(r.subject.needsTranslation, isFalse, reason: r.subject.bn);
      }
    }
  });

  test('every table carries its caveat, not just its numbers', () async {
    for (final t in (await repo.lookups()).tables) {
      expect(t.lead.needsTranslation, isFalse, reason: t.id);
      expect(t.footer, isNotNull, reason: '${t.id} has no caveat');
      expect(t.footer!.needsTranslation, isFalse, reason: t.id);
    }
  });

  test('the cost shares are marked as rules of thumb, never as standards',
      () async {
    // They move a lot between buildings. Shown as a specification they would
    // be used to argue a bill is wrong, which they cannot show.
    final t = (await repo.lookups()).byId('cost_share')!;
    for (final r in t.rows) {
      expect(r.status, ReviewStatus.ruleOfThumb, reason: r.subject.bn);
    }
  });

  test('the sand table follows the schedule a bill is measured against',
      () async {
    // The book puts F.M. 1.05 on plaster and 1.50 on mortar. Every plaster and
    // mortar item in the shipped PWD schedule calls for F.M. 1.2, and the bill
    // is measured against the schedule — so the schedule is what ships.
    final t = (await repo.lookups()).byId('sand')!;
    final plaster = t.rows.firstWhere((r) => r.subject.en == 'Plaster');
    final mortar = t.rows.firstWhere((r) => r.subject.en == 'Brickwork mortar');
    expect(plaster.value, '1.2');
    expect(mortar.value, '1.2');
    expect(plaster.status, ReviewStatus.verified);
    expect(plaster.source, contains('PWD SoR'));
  });

  test('a verified row names a real source, not the book', () async {
    for (final t in (await repo.lookups()).tables) {
      for (final r in t.rows.where((r) => r.status == ReviewStatus.verified)) {
        expect(r.source.toLowerCase(), isNot(startsWith('book')),
            reason: '${t.id} / ${r.subject.bn} is verified against the book');
      }
    }
  });

  test('searching finds a row by its work or its value', () async {
    final mix = (await repo.lookups()).byId('mix')!;
    expect(mix.search('plaster'), isNotEmpty);
    expect(mix.search('1:6'), isNotEmpty);
    expect(mix.search('zzzz'), isEmpty);
    expect(mix.search('  '), hasLength(mix.rows.length));
  });

  test('every mix a checklist asks about can be looked up', () async {
    // The completeness gate: a checklist item that tells someone to check the
    // mix is useless if the app cannot then say what the mix should be.
    final mix = (await repo.lookups()).byId('mix')!;
    final subjects = mix.rows
        .map((r) => '${r.subject.bn} ${r.subject.en}'.toLowerCase())
        .join(' | ');
    for (final work in [
      'plaster',
      'masonry',
      'damp proof',
      'rcc',
      'mass concrete',
    ]) {
      expect(subjects, contains(work.split(' ').first),
          reason: 'no mix row covers "$work"');
    }
  });

  group('ReviewStatus', () {
    test('a rule of thumb is its own status, not a kind of review', () {
      expect(ReviewStatus.parse('ruleOfThumb'), ReviewStatus.ruleOfThumb);
      expect(ReviewStatus.parse('verified'), ReviewStatus.verified);
      expect(ReviewStatus.parse(null), ReviewStatus.review);
      expect(ReviewStatus.parse('anything else'), ReviewStatus.review);
    });

    test('everything unverified carries a badge', () {
      expect(ReviewStatus.verified.needsBadge, isFalse);
      expect(ReviewStatus.review.needsBadge, isTrue);
      expect(ReviewStatus.ruleOfThumb.needsBadge, isTrue);
    });
  });
}
