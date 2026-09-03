import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_run.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/inspection/logic/photo_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ContentRepository repo;
  late List<ChecklistPack> packs;
  late PrefsInspectionStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = ContentRepository(reader: _fromDisk);
    packs = await repo.checklists();
    store = PrefsInspectionStore(await SharedPreferences.getInstance());
  });

  InspectionRun newRun({String name = 'Ward 3 road', int day = 12}) {
    final date = DateTime(2026, 7, day, 9, 30);
    return InspectionRun(
      id: InspectionRun.idFor(date),
      pack: packs.firstWhere((p) => p.id == 'road_rural'),
      projectName: name,
      location: 'Palashbari',
      tenderId: 'LGED-2026-0142',
      date: date,
    );
  }

  group('Saving and reopening', () {
    test('an empty store returns nothing', () async {
      expect(await store.load(packs), isEmpty);
    });

    test('answers and notes survive a round trip', () async {
      final run = newRun();
      run.findings['r3']!
        ..answer = ItemAnswer.problem
        ..note = 'Sub-base measured 100 mm at 9 am.';
      run.findings['r1']!.answer = ItemAnswer.ok;
      await store.save(run);

      final loaded = (await store.load(packs)).single;
      expect(loaded.id, run.id);
      expect(loaded.projectName, 'Ward 3 road');
      expect(loaded.location, 'Palashbari');
      expect(loaded.tenderId, 'LGED-2026-0142');
      expect(loaded.date, run.date);
      expect(loaded.findings['r3']!.answer, ItemAnswer.problem);
      expect(loaded.findings['r3']!.note, 'Sub-base measured 100 mm at 9 am.');
      expect(loaded.findings['r1']!.answer, ItemAnswer.ok);
      expect(loaded.findings['r2']!.answer, isNull);
    });

    test('saving the same run again replaces it rather than duplicating',
        () async {
      final run = newRun();
      await store.save(run);
      run.findings['r1']!.answer = ItemAnswer.ok;
      await store.save(run);

      final loaded = await store.load(packs);
      expect(loaded.length, 1);
      expect(loaded.single.answered.length, 1);
    });

    test('several runs come back newest first', () async {
      await store.save(newRun(name: 'Older', day: 10));
      await store.save(newRun(name: 'Newer', day: 20));
      final loaded = await store.load(packs);
      expect(loaded.map((r) => r.projectName), ['Newer', 'Older']);
    });

    test('deleting removes only that run', () async {
      final a = newRun(name: 'A', day: 10);
      final b = newRun(name: 'B', day: 20);
      await store.save(a);
      await store.save(b);
      await store.delete(a.id);
      expect((await store.load(packs)).single.projectName, 'B');
    });

    test('photographs survive a round trip and are counted in the report',
        () async {
      final run = newRun();
      run.findings['r1']!
        ..answer = ItemAnswer.problem
        ..photos.addAll([
          PhotoRef(
            name: 'r1_r1_1.jpg',
            takenAt: DateTime(2026, 7, 12, 9, 45),
            latitude: 24.89431,
            longitude: 89.37215,
          ),
          PhotoRef(name: 'r1_r1_2.jpg', takenAt: DateTime(2026, 7, 12, 9, 46)),
        ]);
      await store.save(run);

      final loaded = (await store.load(packs)).single;
      expect(loaded.findings['r1']!.photos.map((p) => p.name),
          ['r1_r1_1.jpg', 'r1_r1_2.jpg']);
      expect(loaded.findings['r1']!.photos.first.latitude, 24.89431);
      expect(loaded.findings['r1']!.photos.first.takenAt,
          DateTime(2026, 7, 12, 9, 45));
      expect(loaded.findings['r1']!.photos.last.hasLocation, isFalse);
      expect(loaded.photoCount, 2);
      expect(loaded.withPhotos.length, 1);
      expect(loaded.report(AppLocale.bn), contains('ছবি'));
      expect(loaded.report(AppLocale.en), contains('Photographs: 2'));
      // Where it is known, it is stated; where it is not, that is stated too.
      expect(loaded.report(AppLocale.en), contains('24.89431, 89.37215'));
      expect(loaded.report(AppLocale.en), contains('location not recorded'));
    });

    test('photographs are listed even when the item was not a problem',
        () async {
      final run = newRun();
      // "Could not tell" is exactly when a photograph matters most: somebody
      // else has to look at it.
      run.findings['r2']!
        ..answer = ItemAnswer.unsure
        ..photos.add(PhotoRef(
          name: 'r1_r2_1.jpg',
          takenAt: DateTime(2026, 7, 12, 10, 15),
          latitude: 24.5,
          longitude: 89.5,
        ));
      await store.save(run);

      final report = (await store.load(packs)).single.report(AppLocale.en);
      expect(report, contains('PHOTOGRAPHS'));
      expect(report, contains('Could not tell'));
      expect(report, contains('24.50000, 89.50000'));
      expect(report, contains('2026-07-12 10:15'));
    });

    test('photographs saved before capture times existed still load',
        () async {
      // The shape written by the version that stored bare file names.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('inspection_runs', [
        jsonEncode({
          'id': 'legacy',
          'pack': 'road_rural',
          'name': 'Legacy run',
          'date': '2026-07-12T09:30:00.000',
          'findings': {
            'r1': {'answer': 'problem', 'photos': ['old_photo.jpg']},
          },
        }),
      ]);

      final loaded = (await store.load(packs)).single;
      final photo = loaded.findings['r1']!.photos.single;
      expect(photo.name, 'old_photo.jpg');
      // Falls back to the start of the inspection — the closest honest answer.
      expect(photo.takenAt, DateTime.parse('2026-07-12T09:30:00.000'));
      expect(photo.hasLocation, isFalse);
    });

    test('a run with no photographs says nothing about them', () async {
      final run = newRun();
      run.findings['r1']!.answer = ItemAnswer.ok;
      expect(run.photoCount, 0);
      expect(run.report(AppLocale.en), isNot(contains('Photographs')));
    });

    test('the list is ordered by when a run was last worked on', () async {
      var clock = DateTime(2026, 7, 1, 10);
      final ticking = PrefsInspectionStore(
        await SharedPreferences.getInstance(),
        now: () => clock,
      );
      final older = newRun(name: 'Started later', day: 20);
      final newer = newRun(name: 'Touched last', day: 10);

      await ticking.save(older);
      clock = clock.add(const Duration(hours: 1));
      await ticking.save(newer);

      // Ordering follows the last edit, not the day the run began.
      expect((await ticking.load(packs)).map((r) => r.projectName),
          ['Touched last', 'Started later']);
    });

    test('the report still reads the same after reopening', () async {
      final run = newRun();
      run.findings['r3']!
        ..answer = ItemAnswer.problem
        ..note = 'Measured 100 mm.';
      await store.save(run);
      final loaded = (await store.load(packs)).single;
      expect(loaded.report(AppLocale.bn), run.report(AppLocale.bn));
    });
  });

  group('Resilience', () {
    test('a run whose checklist no longer exists is dropped, not fatal',
        () async {
      await store.save(newRun());
      final withoutRoad = packs.where((p) => p.id != 'road_rural').toList();
      expect(await store.load(withoutRoad), isEmpty);
    });

    test('a corrupt entry does not take the rest down with it', () async {
      final prefs = await SharedPreferences.getInstance();
      await store.save(newRun(name: 'Good'));
      final raw = prefs.getStringList('inspection_runs')!;
      await prefs.setStringList('inspection_runs', ['not json', ...raw]);
      expect((await store.load(packs)).single.projectName, 'Good');
    });

    test('an answer for an item that has been removed is ignored', () async {
      final run = newRun();
      run.findings['r1']!.answer = ItemAnswer.ok;
      final json = run.toJson();
      (json['findings'] as Map)['no_such_item'] = {'answer': 'ok'};
      final rebuilt = InspectionRun.fromJson(json, packs)!;
      expect(rebuilt.findings.containsKey('no_such_item'), isFalse);
      expect(rebuilt.findings['r1']!.answer, ItemAnswer.ok);
    });

    test('ids are stable for a given start time and differ across runs', () {
      final t = DateTime(2026, 7, 12, 9, 30);
      expect(InspectionRun.idFor(t), InspectionRun.idFor(t));
      expect(InspectionRun.idFor(t),
          isNot(InspectionRun.idFor(t.add(const Duration(minutes: 1)))));
    });
  });

  test('one unreadable saved inspection does not take the rest with it',
      () async {
    // The catch here is `on FormatException`, which covers text that is not
    // JSON. It does not cover valid JSON of the wrong shape: `jsonDecode(...)
    // as Map<String, dynamic>` throws a TypeError, and a TypeError is an Error,
    // not an Exception. A single entry written by a different schema would
    // then throw straight out of load() — and load() is how the reader's list
    // of inspections is built, so every inspection they have would disappear
    // from the app at once.
    final good = newRun(name: 'Good run');
    await store.save(good);

    final prefs = await SharedPreferences.getInstance();
    final raw = List<String>.from(prefs.getStringList('inspection_runs') ?? []);
    await prefs.setStringList('inspection_runs', [
      'not json at all',
      '[1, 2, 3]', // valid JSON, wrong shape
      '{"id": 42}', // valid JSON object, wrong field types
      ...raw,
    ]);

    final loaded = await store.load(packs);
    expect(loaded.map((r) => r.projectName), contains('Good run'),
        reason: 'a readable inspection was lost with the unreadable ones');
  });

  test('a preferences key holding the wrong type does not break the list',
      () async {
    // getStringList casts. The key is read by save and delete as well as load,
    // so a wrong type there would leave the reader unable to see any
    // inspection or to record a new one.
    SharedPreferences.setMockInitialValues({'inspection_runs': 'not a list'});
    final fresh =
        PrefsInspectionStore(await SharedPreferences.getInstance());
    expect(await fresh.load(packs), isEmpty);
    await fresh.save(newRun(name: 'After the damage'));
    expect((await fresh.load(packs)).single.projectName, 'After the damage');
  });

  test('a photograph on an item with no answer and no note still survives',
      () async {
    // The commonest reason to photograph something is that you cannot judge it
    // — so this is not an edge case, it is the main one. The finding was only
    // written when it had an answer or a note, so adding a photograph saved a
    // run that did not contain it, orphaned the image file, and showed nothing
    // when the inspection was reopened.
    final run = newRun(name: 'Photo only');
    final f = run.findings.values.first;
    expect(f.isAnswered, isFalse);
    expect(f.note, isEmpty);
    f.photos.add(PhotoRef(name: 'seen.jpg', takenAt: DateTime(2026, 7, 12, 9)));

    await store.save(run);
    final reopened = (await store.load(packs))
        .firstWhere((r) => r.projectName == 'Photo only');
    expect(reopened.photoCount, 1,
        reason: 'the photograph was dropped by the save that added it');
    expect(reopened.findings[f.item.id]!.photos.single.name, 'seen.jpg');
  });
}
