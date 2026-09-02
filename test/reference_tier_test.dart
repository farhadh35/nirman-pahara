import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;
  setUp(() => repo = ContentRepository(reader: _fromDisk));

  test('the reference tier exists and is not empty', () async {
    final pack = await repo.guide();
    expect(pack.reference, isNotEmpty);
    for (final m in pack.reference) {
      expect(m.cards, isNotEmpty, reason: m.id);
    }
  });

  test('nothing in the reference tier is reachable from the guide list',
      () async {
    // The whole point of the split. A homeowner checking their plaster should
    // not have to scroll past pile group efficiency to reach it.
    final pack = await repo.guide();
    final referenceIds = pack.reference.map((m) => m.id).toSet();
    for (final track in Track.values) {
      for (final m in pack.forTrack(track)) {
        expect(referenceIds, isNot(contains(m.id)),
            reason: '${m.id} appears in both the guide and the reference tier');
      }
    }
  });

  test('a reference module is reference all the way down', () async {
    // isReference is derived from the cards rather than declared, so a module
    // cannot claim to be general reading while carrying detailing tables.
    for (final m in (await repo.guide()).reference) {
      for (final c in m.cards) {
        expect(c.tier, CardTier.reference, reason: '${m.id} / ${c.id}');
      }
    }
  });

  test('no reference card leaks into a general module', () async {
    final pack = await repo.guide();
    for (final m in pack.modules.where((m) => !m.isReference)) {
      for (final c in m.cards) {
        expect(c.tier, isNot(CardTier.reference),
            reason: '${m.id} / ${c.id} is reference content in a guide module');
      }
    }
  });

  test('reference cards still carry their sources', () async {
    // Being for engineers is not a reason to drop the citation: it is a reason
    // the citation gets read.
    for (final m in (await repo.guide()).reference) {
      for (final c in m.cards) {
        expect(c.citations, isNotEmpty, reason: '${m.id} / ${c.id}');
      }
    }
  });
}
