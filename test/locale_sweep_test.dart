import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/widgets/locale_fields.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';

/// Screens that seed a text box from the reader's locale must also rewrite it
/// when the reader changes language. This was fixed three times, in three
/// screens, before anyone checked whether a fourth had the same gap — and it
/// did. So the rule is checked against the source rather than screen by screen.
void main() {
  test('every screen that seeds a box from the locale also follows it', () {
    final offenders = <String>[];
    for (final file in Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && f.path.contains('/ui/'))) {
      final src = file.readAsStringSync();
      // Seeding means writing a localised string *into* a controller, as
      // opposed to localising a value at render time, which follows the locale
      // on its own because build re-runs.
      final seeds = RegExp(r'\.text\s*=\s*Bn\.localiseDigits').hasMatch(src) ||
          RegExp(r'TextEditingController\(\s*\n?\s*text:\s*Bn\.localiseDigits')
              .hasMatch(src);
      if (!seeds) continue;
      if (!src.contains('followLocaleDigits')) {
        offenders.add(file.path.split('/').last);
      }
    }
    expect(offenders, isEmpty,
        reason: 'these seed a box in one script and never rewrite it when the '
            'reader switches language:\n${offenders.join('\n')}');
  });

  test('the digits change and the number does not', () {
    final c = TextEditingController(text: '২৫০');
    followLocaleDigits([c], AppLocale.en);
    expect(c.text, '250');
    followLocaleDigits([c], AppLocale.bn);
    expect(c.text, '২৫০');
  });

  test('an empty box is left alone', () {
    final c = TextEditingController(text: '');
    followLocaleDigits([c], AppLocale.en);
    expect(c.text, '');
  });

  test('a money box keeps its grouping', () {
    final c = TextEditingController(text: '৪২,৫০,০০০');
    followLocaleDigits([c], AppLocale.en, grouped: true);
    expect(c.text, contains(','));
    expect(RegExp(r'^[0-9,]+$').hasMatch(c.text), isTrue);
    expect(c.text.replaceAll(',', ''), '4250000');
  });

  test('the cursor lands at the end, not inside the old text', () {
    final c = TextEditingController(text: '১০০');
    followLocaleDigits([c], AppLocale.en);
    expect(c.selection.baseOffset, c.text.length);
  });
}
