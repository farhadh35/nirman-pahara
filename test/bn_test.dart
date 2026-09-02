import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/core/util/bn.dart';

void main() {
  group('Bn.digits', () {
    test('converts western digits', () {
      expect(Bn.digits('2026'), '২০২৬');
      expect(Bn.digits('1:2:4'), '১:২:৪');
    });

    test('leaves Bangla text untouched', () {
      expect(Bn.digits('সিমেন্ট ১০ ব্যাগ'), 'সিমেন্ট ১০ ব্যাগ');
    });
  });

  group('Bn.parse', () {
    test('accepts Bangla digits', () {
      expect(Bn.parse('১২৩'), 123);
      expect(Bn.parse('১২.৫'), 12.5);
    });

    test('accepts commas and spaces', () {
      expect(Bn.parse('৪২,৫০,০০০'), 4250000);
      expect(Bn.parse(' 100 '), 100);
    });

    test('returns null on rubbish', () {
      expect(Bn.parse(''), isNull);
      expect(Bn.parse('abc'), isNull);
    });
  });

  group('Bn.number', () {
    test('groups in lakh and crore style', () {
      expect(Bn.number(4250000, decimals: 0), '৪২,৫০,০০০');
      expect(Bn.number(1234, decimals: 0), '১,২৩৪');
      expect(Bn.number(123, decimals: 0), '১২৩');
      expect(Bn.number(12345678, decimals: 0), '১,২৩,৪৫,৬৭৮');
    });

    test('keeps decimals', () {
      expect(Bn.number(17.6, decimals: 1), '১৭.৬');
    });

    test('handles negatives and non-numbers', () {
      expect(Bn.number(-1234, decimals: 0), '-১,২৩৪');
      expect(Bn.number(double.nan), '—');
    });
  });

  group('Bn.takaWords', () {
    test('speaks in lakh and crore', () {
      expect(Bn.takaWords(4250000), '৳ ৪২.৫০ লাখ');
      expect(Bn.takaWords(12000000), '৳ ১.২০ কোটি');
      expect(Bn.takaWords(5000), '৳ ৫.০ হাজার');
      expect(Bn.takaWords(500), '৳ ৫০০');
    });
  });

  test('round trips through Bangla digits', () {
    expect(Bn.toWestern(Bn.digits('98765')), '98765');
  });

  group('English locale', () {
    test('keeps western digits and lakh/crore grouping', () {
      expect(Bn.number(4250000, decimals: 0, locale: AppLocale.en), '42,50,000');
      expect(Bn.taka(4250000, locale: AppLocale.en), 'Tk 42,50,000');
    });

    test('spells the unit in English', () {
      expect(Bn.takaWords(4250000, locale: AppLocale.en), 'Tk 42.50 lakh');
      expect(Bn.takaWords(12000000, locale: AppLocale.en), 'Tk 1.20 crore');
      expect(Bn.takaWords(500, locale: AppLocale.en), 'Tk 500');
    });

    test('localiseDigits switches both ways', () {
      expect(Bn.localiseDigits('২০২৬', AppLocale.en), '2026');
      expect(Bn.localiseDigits('2026', AppLocale.bn), '২০২৬');
    });
  });
}
