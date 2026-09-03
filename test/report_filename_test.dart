import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/inspection/ui/inspection_screens.dart';

/// The name a shared report file gets.
///
/// It comes straight from the project name the reader typed off a signboard,
/// and signboard names in Bangladesh are long: "ওয়ার্ড ৩ নম্বর সড়ক
/// পুনর্নির্মাণ ও সম্প্রসারণ প্রকল্প, দ্বিতীয় পর্যায়, পালাশবাড়ি ইউনিয়ন,
/// গাইবান্ধা জেলা" is a hundred and twenty characters and three hundred and
/// thirty-seven bytes. Filenames stop at two hundred and fifty-five, so the
/// write failed and the reader was told the PDF could not be built — a true
/// sentence about the wrong thing, since the page had rendered fine.
void main() {
  int bytes(String s) => utf8.encode(s).length;

  test('a signboard-length project name still produces a usable filename', () {
    const long = 'ওয়ার্ড ৩ নম্বর সড়ক পুনর্নির্মাণ ও সম্প্রসারণ প্রকল্প, '
        'দ্বিতীয় পর্যায়, পালাশবাড়ি ইউনিয়ন, গাইবান্ধা জেলা, এলজিইডি টেন্ডার';
    expect(bytes(long), greaterThan(255), reason: 'the fixture is too short to '
        'exercise the limit any more');
    final name = InspectionReportScreen.safeFileName(long);
    expect(bytes('$name.pdf'), lessThan(255));
    expect(name, isNotEmpty);
  });

  test('a short name is left alone', () {
    expect(InspectionReportScreen.safeFileName('ওয়ার্ড ৩ সড়ক'),
        'ওয়ার্ড ৩ সড়ক');
  });

  test('a path separator cannot survive into the filename', () {
    // Not a traversal risk so much as a write that lands somewhere else.
    for (final bad in const ['ওয়ার্ড ৩/৪ সড়ক', '../../etc/passwd', 'a:b']) {
      final out = InspectionReportScreen.safeFileName(bad);
      expect(out, isNot(contains('/')));
      expect(out, isNot(contains(':')));
      expect(out, isNot(contains('..')));
    }
  });

  test('a name with nothing usable in it falls back rather than empty', () {
    for (final empty in const ['', '   ', '///', '...']) {
      expect(InspectionReportScreen.safeFileName(empty), 'report');
    }
  });

  test('the cut lands on a character, not inside one', () {
    // Bangla clusters are several code units; slicing one leaves a broken
    // grapheme in the middle of a filename.
    final long = 'পরিদর্শন ' * 60;
    final name = InspectionReportScreen.safeFileName(long);
    expect(bytes('$name.pdf'), lessThan(255));
    // Re-encoding must round-trip: a split cluster would not.
    expect(utf8.decode(utf8.encode(name)), name);
  });
}
