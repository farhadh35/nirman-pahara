import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/sources/logic/reference_work.dart';

/// Every claim has to land on the reference page.
///
/// A card's citation is matched to a work by the prefix of its source string.
/// Get that string slightly wrong — a different edition wording, a stray space,
/// a chapter named where the work expects none — and the claim still renders on
/// the card while quietly reaching no work at all. Nothing on screen says so.
/// The reader is then looking at a citation that leads nowhere, which is the
/// failure the reference page exists to prevent.
void main() {
  List<Map<String, dynamic>> guideCards() {
    final index = jsonDecode(
        File('assets/content/guide/index.json').readAsStringSync()) as Map;
    return [
      for (final f in index['modules'] as List)
        ...((jsonDecode(File('assets/content/guide/modules/$f').readAsStringSync())
                as Map)['cards'] as List)
            .cast<Map<String, dynamic>>(),
    ];
  }

  test('every guide citation resolves to a work on the reference page', () {
    final orphans = <String>[];
    var counted = 0;
    for (final card in guideCards()) {
      for (final cit in (card['citations'] as List? ?? const [])) {
        counted++;
        final source = ((cit as Map)['source'] as Map)['bn'] as String;
        if (ReferenceWork.match(source) == null) {
          orphans.add('${card['id']}: "${source.substring(0, 40)}…"');
        }
      }
    }
    expect(counted, greaterThan(0), reason: 'no citations were read at all');
    expect(orphans, isEmpty,
        reason: 'these citations reach no reference work, so the number beside '
            'them on the card leads nowhere: $orphans');
  });

  test('the foundation chapter reaches the general reader', () {
    // r1_foundations is reference tier throughout and is reached only from the
    // engineer's entry — a module counts as reference when every one of its
    // cards is. The lay-reader foundation material therefore lives in its own
    // module; putting it inside r1 would have pulled the detailing out of the
    // reference page altogether.
    final index = jsonDecode(
        File('assets/content/guide/index.json').readAsStringSync()) as Map;
    expect((index['modules'] as List), contains('m23_foundation.json'));

    final lay = jsonDecode(
            File('assets/content/guide/modules/m23_foundation.json')
                .readAsStringSync()) as Map;
    final tiers = (lay['cards'] as List)
        .map((c) => (c as Map)['tier'])
        .toSet();
    expect(tiers, {'general'},
        reason: 'a reference-tier card here would fence this module off again');

    final ref = jsonDecode(File('assets/content/guide/modules/r1_foundations.json')
        .readAsStringSync()) as Map;
    final refTiers =
        (ref['cards'] as List).map((c) => (c as Map)['tier']).toSet();
    expect(refTiers, {'reference'},
        reason: 'r1_foundations stopped being all-reference, so the engineer '
            'detailing has dropped out of the reference page');
  });
}
