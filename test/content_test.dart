import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/core/content/rights_models.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';

/// Reads the content packs straight off disk, so these tests exercise the real
/// shipped JSON rather than a fixture that can drift away from it.
Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;

  setUp(() => repo = ContentRepository(reader: _fromDisk));

  group('Guide pack', () {
    test('parses and is not empty', () async {
      final g = await repo.guide();
      expect(g.modules, isNotEmpty);
      expect(g.contentVersion, greaterThan(0));
      expect(g.updated, isNotEmpty);
    });

    test('module codes are unique', () async {
      final codes = (await repo.guide()).modules.map((m) => m.code).toList();
      expect(codes.toSet().length, codes.length);
    });

    test('card ids are unique across the whole pack', () async {
      final ids = (await repo.guide())
          .modules
          .expand((m) => m.cards)
          .map((c) => c.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every card is fully translated', () async {
      for (final m in (await repo.guide()).modules) {
        expect(m.title.needsTranslation, isFalse, reason: m.code);
        expect(m.summary.needsTranslation, isFalse, reason: m.code);
        for (final c in m.cards) {
          expect(c.title.needsTranslation, isFalse, reason: c.id);
          expect(c.body.needsTranslation, isFalse, reason: c.id);
          for (final w in c.watchFor) {
            expect(w.needsTranslation, isFalse, reason: '${c.id}: ${w.bn}');
          }
          for (final cit in c.citations) {
            expect(cit.source.needsTranslation, isFalse, reason: c.id);
          }
        }
      }
    });

    test('every diagram key a card names is one the app can draw', () async {
      // A card pointing at a diagram that does not exist would render as a
      // silent gap where an explanation should be.
      const known = {'rod_binding', 'curing', 'plaster', 'rcc_pour'};
      for (final m in (await repo.guide()).modules) {
        for (final c in m.cards) {
          if (c.diagram == null) continue;
          expect(known, contains(c.diagram), reason: c.id);
        }
      }
    });

    test('the tutorials that need a picture have one', () async {
      final cards = {
        for (final m in (await repo.guide()).modules)
          for (final c in m.cards) c.id: c
      };
      for (final id in ['m4c4', 'm4c5', 'm4c6', 'm5c4']) {
        expect(cards[id], isNotNull, reason: id);
        expect(cards[id]!.diagram, isNotNull, reason: id);
      }
    });

    test('track filtering works', () async {
      final g = await repo.guide();
      expect(g.forTrack(Track.government), isNotEmpty);
      expect(g.forTrack(Track.private), isNotEmpty);
      for (final m in g.forTrack(Track.private)) {
        expect(m.track, isNot(Track.government));
      }
    });

    test('a card with an unverified citation reports review status', () async {
      final cards = (await repo.guide()).modules.expand((m) => m.cards);
      final reviewed =
          cards.where((c) => c.status == ReviewStatus.review).toList();
      // The technical modules cite BNBC clauses that a licensed engineer has
      // still to sign off; the app must be able to badge them.
      expect(reviewed, isNotEmpty);
    });
  });

  group('Checklist packs', () {
    test('all listed packs parse', () async {
      final packs = await repo.checklists();
      expect(packs, isNotEmpty);
      for (final p in packs) {
        expect(p.stages, isNotEmpty, reason: p.id);
        expect(p.itemCount, greaterThan(0), reason: p.id);
      }
    });

    test('item ids are unique within a pack', () async {
      for (final p in await repo.checklists()) {
        final ids =
            p.stages.expand((s) => s.items).map((i) => i.id).toList();
        expect(ids.toSet().length, ids.length, reason: p.id);
      }
    });

    test('every item is fully translated and explains why it matters',
        () async {
      for (final p in await repo.checklists()) {
        for (final s in p.stages) {
          for (final i in s.items) {
            expect(i.question.needsTranslation, isFalse, reason: i.id);
            expect(i.why.needsTranslation, isFalse, reason: i.id);
            expect(i.why.bn.trim(), isNotEmpty, reason: i.id);
            expect(i.how?.needsTranslation ?? false, isFalse, reason: i.id);
            expect(
                i.standard?.needsTranslation ?? false, isFalse, reason: i.id);
          }
        }
      }
    });

    test('lookup by id works and unknown ids return null', () async {
      expect(await repo.checklistById('road_rural'), isNotNull);
      expect(await repo.checklistById('no_such_pack'), isNull);
    });

    test('answers carry both languages', () {
      for (final a in ItemAnswer.values) {
        expect(a.label.needsTranslation, isFalse);
      }
    });
  });

  group('Track correctness', () {
    // Terms that only mean something inside public procurement. A homeowner
    // shown any of these is being told to do something that does not apply to
    // their own house — which is how M1, M8 and M9 came to be mis-tagged.
    const governmentOnly = [
      'টেন্ডার',
      'তথ্য অধিকার',
      'উপজেলা প্রকৌশলী',
      'নির্বাহী প্রকৌশলী',
      'ইউএনও',
      'দুর্নীতি দমন',
      'সাইনবোর্ড',
      'BoQ',
      'কার্যাদেশ',
    ];

    String flatten(Iterable<String> parts) => parts.join(' \n ');

    test('nothing on the private track is public-procurement content',
        () async {
      final guide = await repo.guide();
      for (final m in guide.forTrack(Track.private)) {
        if (m.track != Track.private && m.track != Track.both) continue;
        final text = flatten([
          m.title.bn,
          m.summary.bn,
          for (final c in m.cards) ...[
            c.title.bn,
            c.body.bn,
            for (final w in c.watchFor) w.bn,
          ],
        ]);
        for (final term in governmentOnly) {
          expect(text.contains(term), isFalse,
              reason: 'module ${m.code} is on the private track but mentions '
                  '"$term"');
        }
      }
    });

    test('the private complaint ladder does not route through public offices',
        () async {
      final rights = await repo.rights();
      for (final s in rights.stepsFor(Track.private)) {
        final text = flatten([s.title.bn, s.who.bn, s.how.bn]);
        for (final term in governmentOnly) {
          expect(text.contains(term), isFalse,
              reason: 'step ${s.id} is on the private track but mentions '
                  '"$term"');
        }
      }
    });

    test('both tracks have somewhere to complain and something to send',
        () async {
      final rights = await repo.rights();
      for (final t in [Track.government, Track.private]) {
        expect(rights.stepsFor(t), isNotEmpty, reason: t.name);
        expect(rights.lettersFor(t), isNotEmpty, reason: t.name);
      }
    });

    test('both tracks have guide modules and a checklist', () async {
      final guide = await repo.guide();
      for (final t in [Track.government, Track.private]) {
        expect(guide.forTrack(t), isNotEmpty, reason: t.name);
        expect(await repo.checklistsForTrack(t), isNotEmpty, reason: t.name);
      }
    });
  });

  group('Rights pack', () {
    test('parses with a complaint ladder and letters', () async {
      final r = await repo.rights();
      expect(r.steps.length, greaterThanOrEqualTo(4));
      expect(r.letters, isNotEmpty);
    });

    test('every step and letter is fully translated', () async {
      final r = await repo.rights();
      for (final s in r.steps) {
        expect(s.title.needsTranslation, isFalse, reason: s.id);
        expect(s.who.needsTranslation, isFalse, reason: s.id);
        expect(s.how.needsTranslation, isFalse, reason: s.id);
      }
      for (final l in r.letters) {
        expect(l.title.needsTranslation, isFalse, reason: l.id);
        expect(l.body.needsTranslation, isFalse, reason: l.id);
        for (final f in l.fields) {
          expect(f.label.needsTranslation, isFalse, reason: '${l.id}.${f.key}');
        }
      }
    });

    test('every placeholder in a letter body has a matching field', () async {
      final r = await repo.rights();
      final placeholder = RegExp(r'\{\{(\w+)\}\}');
      for (final l in r.letters) {
        final keys = l.fields.map((f) => f.key).toSet();
        for (final locale in AppLocale.values) {
          for (final m in placeholder.allMatches(l.body.of(locale))) {
            expect(keys, contains(m.group(1)),
                reason: '${l.id} (${locale.code}) uses {{${m.group(1)}}}');
          }
        }
      }
    });

    test('rendering fills what is given and names what is still missing',
        () async {
      final r = await repo.rights();
      final rti = r.letterById('rti_application')!;
      final out = rti.render({'name': 'করিম মিয়া'}, AppLocale.bn);
      expect(out, contains('করিম মিয়া'));
      // An unfilled slot says what belongs there rather than showing an
      // anonymous rule. The only underscore rules left are the ones the
      // template writes on purpose — the date and signature lines, which the
      // user fills in with a pen after printing.
      expect(out, contains('[দপ্তরের নাম ও ঠিকানা]'));
      expect(out, contains('[মোবাইল নম্বর]'));
      expect(out, isNot(contains('{{')));

      final rules = RegExp('_{4,}').allMatches(out).length;
      expect(rules, lessThanOrEqualTo(2),
          reason: 'only the date and signature lines should be blank rules');
      for (final line in out.split('\n')) {
        if (RegExp('_{4,}').hasMatch(line)) {
          expect(line.replaceAll(RegExp('[_\\s]'), ''), isNotEmpty,
              reason: 'a blank rule must carry a label: "\$line"');
        }
      }
    });

    test('a contact line is translated, digits and all', () async {
      final r = await repo.rights();
      for (final st in r.steps.where((s) => s.contact != null)) {
        expect(st.contact!.needsTranslation, isFalse, reason: st.id);
        // A Bangla helpline number must not survive into the English screen.
        expect(RegExp('[০-৯]').hasMatch(st.contact!.en!), isFalse,
            reason: '${st.id}: Bangla digits leaked into English');
      }
    });

    test('a phone field asks for the phone keyboard', () async {
      final r = await repo.rights();
      for (final l in r.letters) {
        final phone = l.fields.where((f) => f.key == 'phone');
        for (final f in phone) {
          expect(f.keyboard, LetterKeyboard.phone, reason: l.id);
        }
      }
    });
  });
}
