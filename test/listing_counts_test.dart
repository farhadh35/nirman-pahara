import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/calculators/ui/calc_spec.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

/// The counts the store listing and the policy document promise.
///
/// docs/PLAY-POLICY-2.0.0.md records that these were wrong at 1.1.1 — the
/// listing was still offering six calculators and 42 cards while the build had
/// far more. That is the listing describing a different app from the one a
/// reader downloads, which is the sort of thing Play judges a listing on, and
/// nothing prevented it happening again.
void main() {
  late int modules;
  late int cards;
  late int calculators;

  setUpAll(() async {
    final pack = await ContentRepository(reader: _fromDisk).guide();
    // Counted by id, not by adding the two lists: `reference` is a filtered
    // view of `modules`, not a separate set, so summing them counts the
    // reference chapter twice.
    final byId = {
      for (final m in [...pack.modules, ...pack.reference]) m.id: m,
    };
    modules = byId.length;
    cards = byId.values.fold(0, (n, m) => n + m.cards.length);
    calculators = CalcSpec.all.length;
  });

  /// Whitespace-insensitive, because these files are hard-wrapped and a number
  /// is often on the line above the word it counts.
  String flat(String path) =>
      File(path).readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

  int bangla(String digits) => int.parse(digits.split('').map((c) {
        const bn = '০১২৩৪৫৬৭৮৯';
        final i = bn.indexOf(c);
        return i == -1 ? c : '$i';
      }).join());

  test('the English listing counts what the build contains', () {
    final text = flat('store/LISTING-en.md');
    final chapters = RegExp(r'(\d+) chapters').firstMatch(text);
    final cardCount = RegExp(r'(\d+) cards').firstMatch(text);
    expect(chapters, isNotNull, reason: 'the listing stopped naming a chapter '
        'count, so this test no longer checks anything');
    expect(cardCount, isNotNull);
    expect(int.parse(chapters!.group(1)!), modules);
    expect(int.parse(cardCount!.group(1)!), cards);
  });

  test('the Bangla listing counts what the build contains', () {
    final text = flat('store/LISTING-bn.md');
    final chapters = RegExp(r'([০-৯]+)টি অধ্যায়').firstMatch(text);
    final cardCount = RegExp(r'([০-৯]+)টি কার্ড').firstMatch(text);
    final calcCount = RegExp(r'([০-৯]+)টি হিসাব').firstMatch(text);
    expect(chapters, isNotNull);
    expect(cardCount, isNotNull);
    expect(calcCount, isNotNull);
    expect(bangla(chapters!.group(1)!), modules);
    expect(bangla(cardCount!.group(1)!), cards);
    expect(bangla(calcCount!.group(1)!), calculators);
  });

  test('the policy document counts what the build contains', () {
    final text = flat('docs/PLAY-POLICY-2.0.0.md');
    final calc = RegExp(r'(\d+) calculators').firstMatch(text);
    final chapters = RegExp(r'(\d+) guide chapters').firstMatch(text);
    expect(calc, isNotNull);
    expect(chapters, isNotNull);
    expect(int.parse(calc!.group(1)!), calculators);
    expect(int.parse(chapters!.group(1)!), modules);
  });

  test('the version in the app is the version in the release notes', () {
    // Two places drift apart quietly, and the one a reviewer reads is the
    // notes.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version =
        RegExp(r'^version:\s*([0-9.]+)\+(\d+)', multiLine: true)
            .firstMatch(pubspec)!;
    final notes = flat('store/RELEASE-NOTES.md');
    expect(notes, contains('${version.group(1)} (${version.group(2)})'),
        reason: 'store/RELEASE-NOTES.md has no block for '
            '${version.group(1)}+${version.group(2)}');
  });
}
