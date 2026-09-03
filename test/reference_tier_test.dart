import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nirman_pahara/app/widgets/common.dart';
import 'package:nirman_pahara/features/guide/ui/guide_screens.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  _referenceCardsAreBadged();
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

/// The reference tier is the app's most technical content — foundation
/// classes, pile caps, tie beams, reading a bore log — and every one of its
/// claims is still `review`, meaning no licensed engineer has signed it off.
///
/// Its index screen renders no badge and no citation button, which looked like
/// a hole until you follow where it navigates: it pushes the same
/// GuideModuleScreen the guide uses, and the badge and the source live on the
/// card renderer inside it. So the honesty holds — by reuse rather than by
/// anything asserting it, which is what this adds.
void _referenceCardsAreBadged() {
  group('the reference tier wears its badges', () {
    late ContentRepository repo;
    setUp(() => repo = ContentRepository(reader: _fromDisk));

    test('every reference claim is still unverified, and says so in its data',
        () async {
      final pack = await repo.guide();
      expect(pack.reference, isNotEmpty);
      for (final module in pack.reference) {
        for (final card in module.cards) {
          expect(card.citations, isNotEmpty,
              reason: '${card.id} states detailing with no source at all');
          for (final c in card.citations) {
            expect(c.status.needsBadge, isTrue,
                reason: '${card.id} claims a verified source; if an engineer '
                    'really has signed this off, docs/CONTENT_REVIEW.md '
                    'should say so too');
          }
        }
      }
    });

    testWidgets('a reference card renders the badge and offers its source',
        (tester) async {
      // Tall on purpose: the card is a lazily built list and the source
      // button sits under the body text.
      tester.view.physicalSize = const Size(1200, 12000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      late GuideModule module;
      await tester.runAsync(() async {
        module = (await repo.guide()).reference.first;
      });

      SharedPreferences.setMockInitialValues({'onboarded': true});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(AppScope(
        state: await AppState.load(),
        content: repo,
        store: PrefsInspectionStore(prefs),
        evidence: EvidenceStore(
          directory: () async => Directory.systemTemp.createTempSync('ref'),
        ),
        rates: SorRateStore(prefs),
        child: MaterialApp(home: GuideModuleScreen(module: module)),
      ));
      await tester.pumpAndSettle();

      // The amber badge stays on the card, because it is a warning about the
      // sentence in front of the reader rather than a reference. The source
      // itself moved to the sources page — see source_index_test.dart, which
      // holds that every citation in the app reaches it.
      expect(find.byType(ReviewBadge), findsWidgets,
          reason: 'unverified detailing is being shown as settled');
      expect(find.byIcon(Icons.menu_book_outlined), findsNothing,
          reason: 'the per-card source button is back; citations belong on the '
              'sources page');
      expect(tester.takeException(), isNull);
    });
  });
}
