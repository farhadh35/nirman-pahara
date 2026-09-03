import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the real app against the real bundled content packs.
///
/// The default 800x600 test surface is shorter than any phone the app targets,
/// so screens are given a tall viewport; otherwise items scroll off and the
/// test fails for a reason no user would ever hit.
Future<void> _boot(
  WidgetTester tester, {
  bool onboarded = true,
  Map<String, Object> prefs = const {},
  EvidenceStore? evidence,
}) async {
  tester.view.physicalSize = const Size(1200, 3600);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    if (onboarded) 'onboarded': true,
    ...prefs,
  });
  final state = await AppState.load();
  final content = _diskContent();
  // Real file I/O has to happen outside the fake-async zone, otherwise the
  // read never completes while pumpAndSettle is spinning. Once the packs are
  // cached, every screen's future resolves on a microtask.
  // The published rate table is half a megabyte and deliberately outside
  // loadAll, but the prices screen needs it — and real file reads have to
  // happen outside the fake-async zone.
  await tester.runAsync(() async {
    await content.loadAll();
    await content.pwdRates();
    await content.pwdEmRates();
  });

  await tester.pumpWidget(
    NirmanPaharaApp(
      state: state,
      content: content,
      store: PrefsInspectionStore(await SharedPreferences.getInstance()),
      evidence: evidence ??
          EvidenceStore(
            directory: () async =>
                Directory.systemTemp.createTempSync('flow_evidence'),
          ),
      rates: SorRateStore(await SharedPreferences.getInstance()),
    ),
  );
  await tester.pumpAndSettle();
}

/// `rootBundle.loadString` moves UTF-8 decoding to a worker isolate for
/// payloads over 50 KB, and that isolate never completes under
/// `pumpAndSettle`'s fake async. The guide pack is over that threshold, so the
/// tests read the same files straight off disk. Parsing and every screen below
/// are unchanged.
ContentRepository _diskContent() =>
    ContentRepository(reader: (path) => File(path).readAsString());

/// Taps text, scrolling to it first.
///
/// Lists build lazily, so anything below the fold does not exist in the tree
/// until it is scrolled into range. `.first` is applied only after the finder
/// has matched, because a `.first` finder throws when nothing matches.
Future<void> _scrollTo(WidgetTester tester, Finder base) async {
  for (var i = 0; base.evaluate().isEmpty && i < 20; i++) {
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final base = find.text(text);
  // The route underneath keeps its own list alive, so drag the topmost one.
  for (var i = 0; base.evaluate().isEmpty && i < 20; i++) {
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(base.first);
  await tester.pumpAndSettle();
  await tester.tap(base.first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first run shows onboarding, then the home screen',
      (tester) async {
    await _boot(tester, onboarded: false);
    expect(find.text('নির্মাণ পাহারা'), findsWidgets);
    expect(find.text('ভাষা'), findsOneWidget);

    // Onboarding no longer answers for the reader: the button stays disabled
    // until one of the two tracks is chosen. Tapping straight through used to
    // hand a homeowner the government complaint ladder.
    expect(find.text('দুটোর একটি বেছে নিন — পরে সেটিংসে বদলানো যাবে।'),
        findsOneWidget);
    await _tapText(tester, 'পরবর্তী');
    expect(find.text('শিখুন'), findsNothing,
        reason: 'onboarding let the reader past without answering');

    await _tapText(tester, 'নিজের বাড়ি');
    await _tapText(tester, 'পরবর্তী');
    // The track chips sit above the doors, so they are checked before the page
    // is scrolled down past them.
    expect(find.text('নিজের বাড়ি'), findsOneWidget);
    // Every door on the home page, found by scrolling to it rather than by
    // assuming the whole list fits: the page grew past one screen when the
    // measuring tools, the tables and the plot rules were added, and a test
    // that only sees the top of it stops testing the bottom of it.
    for (final door in const [
      'শিখুন',
      'পরিদর্শন',
      'হিসাব',
      'মাপজোখ',
      'মাপ ও তালিকা',
      'জমিতে কতটুকু করা যাবে',
      'দাম যাচাই',
      'অধিকার',
      'প্রকৌশলীর রেফারেন্স',
    ]) {
      await _scrollTo(tester, find.text(door));
      expect(find.text(door), findsOneWidget, reason: 'no door for "$door"');
    }
  });

  testWidgets('the guide opens a module and pages through its cards',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'শিখুন');
    expect(find.text('সাইনবোর্ড পড়া'), findsOneWidget);

    await _tapText(tester, 'সাইনবোর্ড পড়া');
    expect(find.text('বোর্ডে কী কী থাকার কথা'), findsOneWidget);
    expect(find.text('কী দেখবেন'), findsOneWidget);

    await _tapText(tester, 'পরবর্তী');
    expect(find.text('টেন্ডার আইডি দিয়ে খোঁজা'), findsOneWidget);
  });

  testWidgets('the concrete calculator computes and shows its assumptions',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'হিসাব');
    await _tapText(tester, 'ঢালাইয়ের মালামাল');

    // Default is 100 cft at 1:2:4 → 17.6 bags, 44 cft sand, 88 cft khoa.
    expect(find.textContaining('১৭.৬'), findsOneWidget);
    expect(find.textContaining('৪৪.০০'), findsOneWidget);
    expect(find.textContaining('৮৮.০০'), findsOneWidget);
    expect(find.text('কীভাবে হিসাব হলো'), findsOneWidget);
    expect(find.text('যা ধরে নেওয়া হয়েছে'), findsOneWidget);
  });

  testWidgets('a bad input shows a readable message, not a crash',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'হিসাব');
    await _tapText(tester, 'ঢালাইয়ের মালামাল');

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.pumpAndSettle();
    expect(find.textContaining('শূন্যের বেশি হতে হবে'), findsOneWidget);
  });

  testWidgets('the price screen warns before it compares countries',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'দাম যাচাই');
    expect(find.textContaining('দাম প্রতি সপ্তাহে বদলায়'), findsOneWidget);

    await _tapText(tester, 'অন্য দেশের সঙ্গে');
    expect(find.text('আগে এটা পড়ুন'), findsOneWidget);
    expect(find.textContaining('সাল নিশ্চিত নয়'), findsWidgets);
  });

  testWidgets('the rights screen opens a letter', (tester) async {
    await _boot(tester);
    await _tapText(tester, 'অধিকার');

    await _tapText(tester, 'তথ্য অধিকার আবেদন');
    expect(find.text('চিঠির খসড়া'), findsOneWidget);
    // Unfilled placeholders stay visibly blank rather than printing {{name}}.
    expect(find.textContaining('____________'), findsOneWidget);
    expect(find.textContaining('{{'), findsNothing);
  });

  testWidgets('an inspection runs from setup to report', (tester) async {
    await _boot(tester);
    await _tapText(tester, 'পরিদর্শন');
    await _tapText(tester, 'গ্রামীণ সড়ক');

    expect(find.textContaining('সাইনবোর্ডের একটা ছবি'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'পরীক্ষামূলক সড়ক');
    await tester.pumpAndSettle();

    await _tapText(tester, 'পরিদর্শন শুরু করুন');
    expect(find.text('কাজ শুরুর আগে'), findsOneWidget);

    await _tapText(tester, 'সমস্যা আছে');
    await _tapText(tester, 'রিপোর্ট তৈরি করুন');
    expect(find.textContaining('পরিদর্শন রিপোর্ট'), findsOneWidget);
    expect(find.textContaining('নিয়মে যা থাকার কথা'), findsOneWidget);
  });

  testWidgets('inputs are seeded in the reader\'s own digits', (tester) async {
    await _boot(tester);
    await _tapText(tester, 'হিসাব');
    await _tapText(tester, 'ঢালাইয়ের মালামাল');

    // The answer prints Bangla digits, so the box above it must too.
    expect(find.text('১০০'), findsOneWidget);
    expect(find.text('100'), findsNothing);
    expect(find.text('১:২:৪'), findsWidgets);
    expect(find.text('1:2:4'), findsNothing);
  });

  testWidgets('English seeds western digits instead', (tester) async {
    await _boot(tester, prefs: {'locale': 'en'});
    await _tapText(tester, 'Calculate');
    await _tapText(tester, 'Rod weight');

    expect(find.text('40'), findsOneWidget);
    expect(find.text('16 mm'), findsWidgets);
    expect(find.text('১৬ মিমি'), findsNothing);
  });

  testWidgets('a contract value is grouped so it can be read at a glance',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'হিসাব');
    await _tapText(tester, 'চুক্তি বনাম বাস্তব');

    // Seven ungrouped digits are unreadable; 42 lakh must look like 42 lakh.
    expect(find.text('৪২,৫০,০০০'), findsOneWidget);
    expect(find.text('৪২৫০০০০'), findsNothing);

    // The grouping survives a round trip into the calculation.
    expect(find.textContaining('৩,৫৪২'), findsOneWidget);
    expect(find.textContaining('চুক্তিমূল্য (প্রতি মিটার)'), findsOneWidget);
    expect(find.textContaining('প্রতি মিটার-এ'), findsNothing);
  });

  testWidgets('typing into a money field keeps it grouped', (tester) async {
    await _boot(tester);
    await _tapText(tester, 'হিসাব');
    await _tapText(tester, 'চুক্তি বনাম বাস্তব');

    await tester.enterText(find.byType(TextField).first, '12000000');
    await tester.pumpAndSettle();
    expect(find.text('১,২০,০০,০০০'), findsOneWidget);
  });

  testWidgets('a price band shows one currency symbol, not two',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'দাম যাচাই');
    expect(find.textContaining('৳ ৪৮০ – ৫৩০'), findsOneWidget);
    expect(find.textContaining('৳ ৪৮০ – ৳ ৫৩০'), findsNothing);
  });

  testWidgets('dollar figures spell the unit out in Bangla', (tester) async {
    await _boot(tester);
    await _tapText(tester, 'দাম যাচাই');
    await _tapText(tester, 'অন্য দেশের সঙ্গে');
    expect(find.textContaining('মিলিয়ন'), findsWidgets);
    // One currency symbol and one unit per range, however many numbers.
    expect(find.text('\$১.১–১.৩ মিলিয়ন'), findsOneWidget);
    expect(find.textContaining('\$১.১–\$১.৩'), findsNothing);
  });

  testWidgets('the language picker names each language in its own script',
      (tester) async {
    // Someone who reads only English must be able to find English while the
    // app is still in its Bangla default.
    await _boot(tester, onboarded: false);
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('ইংরেজি'), findsNothing);

    await _tapText(tester, 'English');
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Bangla'), findsNothing);
  });

  testWidgets('an inspection survives leaving the screen and coming back',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'পরিদর্শন');
    await _tapText(tester, 'গ্রামীণ সড়ক');

    await tester.enterText(find.byType(TextField).first, 'ওয়ার্ড ৩ সড়ক');
    await tester.pumpAndSettle();
    await _tapText(tester, 'পরিদর্শন শুরু করুন');

    await _tapText(tester, 'সমস্যা আছে');
    await tester.enterText(
        find.byType(TextField).first, '১২ জুলাই সকাল ৯টা — ১০০ মিমি।');
    await tester.pumpAndSettle();

    // Walk away, as someone does to look something up in the guide.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // The run is listed, not lost.
    expect(find.text('ওয়ার্ড ৩ সড়ক'), findsOneWidget);
    expect(find.text('চলতি পরিদর্শন'), findsOneWidget);

    // Reopening restores the answer and the note.
    await _tapText(tester, 'ওয়ার্ড ৩ সড়ক');
    expect(find.textContaining('১২ জুলাই সকাল ৯টা'), findsOneWidget);
    final chip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text('সমস্যা আছে').first,
        matching: find.byType(ChoiceChip),
      ).first,
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('a saved inspection can be deleted, with a warning first',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'পরিদর্শন');
    await _tapText(tester, 'গ্রামীণ সড়ক');
    await tester.enterText(find.byType(TextField).first, 'মুছে ফেলার কাজ');
    await tester.pumpAndSettle();
    await _tapText(tester, 'পরিদর্শন শুরু করুন');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('মুছে ফেলার কাজ'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    // Destructive, so it must say what is lost before it happens.
    expect(find.textContaining('আর ফেরানো যাবে না'), findsOneWidget);
    await _tapText(tester, 'মুছে ফেলুন');
    expect(find.text('মুছে ফেলার কাজ'), findsNothing);
  });

  testWidgets('removing a photograph asks first, and cancelling keeps it',
      (tester) async {
    // A run that already has a photograph attached to its first finding.
    final dir = Directory.systemTemp.createTempSync('photo_flow');
    addTearDown(() => dir.deleteSync(recursive: true));
    final evidence = EvidenceStore(directory: () async => dir);
    File('${dir.path}/r1_r1_1.jpg').writeAsBytesSync(_onePixelPng);

    await _boot(tester, evidence: evidence, prefs: {
      'inspection_runs': <String>[
        jsonEncode({
          'id': 'r1',
          'pack': 'road_rural',
          'name': 'ছবিওয়ালা সড়ক',
          'date': '2026-07-12T09:30:00.000',
          'findings': {
            'r1': {
              'answer': 'problem',
              'photos': [
                {'name': 'r1_r1_1.jpg', 'taken_at': '2026-07-12T09:45:00.000'},
              ],
            },
          },
        }),
      ],
    });

    await _tapText(tester, 'পরিদর্শন');
    await _tapText(tester, 'ছবিওয়ালা সড়ক');
    expect(find.byType(Image), findsWidgets);

    // Cancelling must leave the evidence alone.
    await tester.tap(find.byIcon(Icons.cancel).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('আর ফেরানো যাবে না'), findsOneWidget);
    await _tapText(tester, 'বাতিল');
    expect(File('${dir.path}/r1_r1_1.jpg').existsSync(), isTrue);

    // Confirming removes both the thumbnail and the file.
    await tester.tap(find.byIcon(Icons.cancel).first);
    await tester.pumpAndSettle();
    await _tapText(tester, 'মুছে ফেলুন');
    expect(File('${dir.path}/r1_r1_1.jpg').existsSync(), isFalse);
    // The delete awaits real file I/O, so the rebuild lands some frames later.
    for (var i = 0; i < 20 && find.byIcon(Icons.cancel).evaluate().isNotEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byIcon(Icons.cancel), findsNothing);
  });

  testWidgets('the report offers a PDF, a plain send, and a copy',
      (tester) async {
    await _boot(tester);
    await _tapText(tester, 'পরিদর্শন');
    await _tapText(tester, 'গ্রামীণ সড়ক');
    await tester.enterText(find.byType(TextField).first, 'পাঠানোর কাজ');
    await tester.pumpAndSettle();
    await _tapText(tester, 'পরিদর্শন শুরু করুন');
    await _tapText(tester, 'সমস্যা আছে');
    await _tapText(tester, 'রিপোর্ট তৈরি করুন');

    // A PDF is the primary action: an officer should receive one document,
    // not a message with attachments to match up by hand.
    expect(find.text('পিডিএফ পাঠান'), findsOneWidget);
    await _scrollTo(tester, find.text('লেখা ও ছবি আলাদা করে পাঠান'));
    expect(find.text('লেখা ও ছবি আলাদা করে পাঠান'), findsOneWidget);
    await _scrollTo(tester, find.text('কপি করুন'));
    expect(find.text('কপি করুন'), findsOneWidget);
  });

  testWidgets('switching to English changes the whole interface',
      (tester) async {
    await _boot(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await _tapText(tester, 'English');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Nine doors now, most of them below the fold, so each is scrolled to.
    for (final door in const [
      'Learn',
      'Inspect',
      'Measuring tools',
      'Standards and tables',
      'What the plot allows',
      'Check prices',
      'Your rights',
    ]) {
      await _scrollTo(tester, find.text(door));
      expect(find.text(door), findsOneWidget, reason: 'no door for "$door"');
    }
  });

  testWidgets('English carries through into content, not just chrome',
      (tester) async {
    await _boot(tester, prefs: {'locale': 'en'});

    await _tapText(tester, 'Learn');
    expect(find.text('Reading the signboard'), findsOneWidget);
    await _tapText(tester, 'Reading the signboard');
    expect(find.text('What the board should carry'), findsOneWidget);
  });
}


/// Smallest valid PNG, so Image.file has something real to decode.
final _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmM'
  'IQAAAABJRU5ErkJggg==',
);
