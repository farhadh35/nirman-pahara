import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Where the app has to agree with itself.
///
/// Three figures were found disagreeing across the shipped content: a damp
/// proof course that was 40 mm in a guide card and 75 mm in the checklist that
/// inspects it; a contractor overhead the guide attributed to the government
/// schedule at 4.5 per cent while the schedule shipped beside it records 3.5;
/// and a card titled "what this app cannot tell you" that denied a FAR answer
/// the app's own FAR screen gives.
///
/// None of those is the kind of thing a reader can catch. Each is pinned here.
Map<String, dynamic> _module(String name) => jsonDecode(
    File('assets/content/guide/modules/$name.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _card(String module, String id) =>
    (_module(module)['cards'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((c) => c['id'] == id);

void main() {
  test('the DPC is the same thickness in the guide and in the checklist', () {
    // PWD SoR 2022 item 03.6.1 prices a 75 mm damp proof course at 1:1.5:3,
    // and docs/FACTS_V2.md records that as verified.
    final card = _card('m22_maintenance', 'm22c2');
    expect(card['body']['en'], contains('75 millimetres'),
        reason: 'the maintenance card no longer says 75 mm');
    expect(card['body']['bn'], contains('৭৫ মিলিমিটার'));
    expect(card['body']['en'], isNot(contains('40 millimetres')),
        reason: 'the 40 mm figure is back, and it contradicts both the '
            'building checklist and the PWD schedule');

    final checklist =
        File('assets/content/checklists/building.json').readAsStringSync();
    expect(checklist, contains('75 mm thick'),
        reason: 'the checklist changed its DPC figure; the guide card and '
            'this file have to move together');
  });

  test('the overhead the guide attributes to the schedule is the schedule\'s',
      () {
    // The card says the government schedule's rates already contain profit and
    // overhead, so the numbers it quotes have to be the ones in the schedule
    // this app ships — not the book's share-of-building-cost figures, which
    // are a different quantity (4.5 per cent there, and still correct there).
    final rates = jsonDecode(
        File('assets/content/rates/pwd_sor_2022.json').readAsStringSync())
        as Map<String, dynamic>;
    final markups = rates['markups'] as Map<String, dynamic>;
    final profit = (markups['profit_percent'] as num).toString();
    final overhead = (markups['overhead_percent'] as num).toString();

    final card = _card('m19_cost', 'm19c4');
    expect(card['body']['en'], contains('10 and $overhead per cent'),
        reason: 'the card quotes an overhead the shipped PWD schedule does '
            'not carry. The schedule says $profit and $overhead.');
  });

  test('no card denies something the app ships a screen for', () {
    // The FAR screen has been on the home page since 2.0.0.
    final card = _card('m17_approval', 'm17c5');
    final en = card['body']['en'] as String;
    expect(en, isNot(contains('not something this app can say')),
        reason: 'the approval card is denying the FAR answer again, and the '
            'FAR screen still ships');
    expect(en.toLowerCase(), contains('table 5'),
        reason: 'the card should say what the FAR screen actually reads');
    expect((card['title']['en'] as String).toLowerCase(),
        isNot('what this app cannot tell you'),
        reason: 'the title promises less than the app does');
    expect(File('lib/features/rules/ui/far_screen.dart').existsSync(), isTrue,
        reason: 'the FAR screen was removed; this card should go back to '
            'saying the app cannot answer');
  });
}
