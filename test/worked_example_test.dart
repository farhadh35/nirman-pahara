import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/calculators/logic/concrete.dart';
import 'package:nirman_pahara/features/calculators/logic/mix_ratio.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

/// The guide's worked example and the app's own calculator, side by side.
///
/// The estimating card states what 100 cft of concrete takes. The calculator
/// works the same question out. They do not agree exactly and should not: the
/// card carries the estimator's round figures, set a little high for buying,
/// and the calculator does the arithmetic. But a reader who uses both gets two
/// answers from one app, so the gap has to stay small and the card has to own
/// up to it.
void main() {
  test('the guide and the calculator stay within a buying margin', () async {
    final pack = await ContentRepository(reader: _fromDisk).guide();
    final card = pack.modules
        .expand((m) => m.cards)
        .firstWhere((c) => c.title.bn.contains('ঘনফুট ঢালাইয়ে'));

    // What the calculator makes of the same pour.
    final exact =
        const ConcreteCalculator().compute(volume: 100, ratio: MixRatio.c1_2_4);
    double lineOf(String key) =>
        exact.lines.firstWhere((l) => l.key == key).value;

    // The card's figures. Checked against its own prose rather than trusted
    // from here, so this test cannot go on comparing numbers the card stopped
    // saying.
    const stated = {'cement': 18.0, 'sand': 45.0, 'aggregate': 90.0};
    const asWritten = {'cement': '১৮', 'sand': '৪৫', 'aggregate': '৯০'};
    for (final key in stated.keys) {
      expect(card.body.bn, contains(asWritten[key]!),
          reason: 'the card no longer says ${asWritten[key]} for $key, so the '
              'figures compared below are not the ones a reader sees');
    }
    final computed = {
      'cement': lineOf('cement_bags'),
      'sand': lineOf('sand_cft'),
      'aggregate': lineOf('aggregate_cft'),
    };

    for (final key in stated.keys) {
      final gap = (stated[key]! - computed[key]!) / computed[key]!;
      expect(gap, greaterThanOrEqualTo(0),
          reason: '$key: the card is below the arithmetic, so its figure is '
              'not a buying margin but an error');
      expect(gap, lessThan(0.10),
          reason: '$key: the card says ${stated[key]} and the calculator says '
              '${computed[key]!.toStringAsFixed(1)} — too far apart for a '
              'reader to reconcile');
    }
  });

  test('the card says its figures are rounded, and by how much', () async {
    // Without this the app answers the same question two ways and explains
    // neither, which reads as one of them being wrong.
    final pack = await ContentRepository(reader: _fromDisk).guide();
    final card = pack.modules
        .expand((m) => m.cards)
        .firstWhere((c) => c.title.bn.contains('ঘনফুট ঢালাইয়ে'));

    expect(card.body.bn, contains('গোল হিসাব'),
        reason: 'the card does not say its figures are rounded');
    expect(card.body.bn, contains('১৭.৬'),
        reason: 'the card does not give the calculator its own figure, so a '
            'reader who sees both is left guessing which to trust');
  });
}
