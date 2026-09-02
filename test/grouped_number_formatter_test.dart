import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/core/util/bn.dart';
import 'package:nirman_pahara/core/util/grouped_number_formatter.dart';

TextEditingValue _typed(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

void main() {
  const bn = GroupedNumberFormatter(AppLocale.bn);
  const en = GroupedNumberFormatter(AppLocale.en);

  String format(GroupedNumberFormatter f, String input) =>
      f.formatEditUpdate(const TextEditingValue(), _typed(input)).text;

  group('grouping', () {
    test('groups a contract value in lakh/crore style', () {
      expect(format(bn, '4250000'), '৪২,৫০,০০০');
      expect(format(en, '4250000'), '42,50,000');
    });

    test('leaves short numbers alone', () {
      expect(format(bn, '480'), '৪৮০');
      expect(format(en, '99'), '99');
    });

    test('handles crore-scale numbers', () {
      expect(format(en, '120000000'), '12,00,00,000');
    });

    test('accepts input already in Bangla digits', () {
      expect(format(bn, '৪২৫০০০০'), '৪২,৫০,০০০');
    });

    test('keeps one decimal point', () {
      expect(format(en, '122.7'), '122.7');
      expect(format(bn, '122.7'), '১২২.৭');
      expect(format(en, '12.3.4'), '12.34');
    });

    test('drops anything that is not a digit', () {
      expect(format(en, '4,2a5!0'), '4,250');
    });

    test('empties out cleanly', () {
      expect(format(en, ''), '');
      expect(format(en, 'abc'), '');
    });
  });

  group('caret', () {
    test('stays at the end while typing', () {
      final v = bn.formatEditUpdate(const TextEditingValue(), _typed('425000'));
      expect(v.selection.baseOffset, v.text.length);
    });

    test('keeps its distance from the end when a separator appears', () {
      // Caret sits after "4250" of "42500"; two digits follow it.
      const input = TextEditingValue(
        text: '42500',
        selection: TextSelection.collapsed(offset: 3),
      );
      final v = en.formatEditUpdate(const TextEditingValue(), input);
      expect(v.text, '42,500');
      // Two digits must still sit to the right of the caret.
      final right = v.text.substring(v.selection.baseOffset);
      expect(right.replaceAll(',', '').length, 2);
    });
  });

  test('the result round-trips back through Bn.parse', () {
    expect(Bn.parse(format(bn, '4250000')), 4250000);
    expect(Bn.parse(format(en, '4250000')), 4250000);
    expect(Bn.parse(format(bn, '122.7')), 122.7);
  });
}
