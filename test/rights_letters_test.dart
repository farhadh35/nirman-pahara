import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

/// These letters go to a government office. What ships in them matters more
/// than what ships on most screens: a Right to Information application that
/// comes back for a formatting reason has cost the reader the twenty working
/// days they were waiting on.
void main() {
  test('every placeholder in a letter has a field to fill it', () async {
    // A token with no field behind it is never substituted, so the reader
    // copies a letter with {{something}} sitting in the middle of it.
    final pack = await ContentRepository(reader: _fromDisk).rights();
    final token = RegExp(r'\{\{(\w+)\}\}');
    final problems = <String>[];
    for (final letter in pack.letters) {
      final keys = {for (final f in letter.fields) f.key};
      for (final locale in AppLocale.values) {
        final body = letter.body.of(locale);
        final found = token.allMatches(body).map((m) => m.group(1)!).toSet();
        for (final t in found.difference(keys)) {
          problems.add('${letter.id} (${locale.name}): {{$t}} has no field');
        }
        for (final k in keys.difference(found)) {
          problems.add('${letter.id} (${locale.name}): field "$k" is asked for '
              'but never appears in the letter');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('an unfilled letter renders labels, never raw braces', () async {
    final pack = await ContentRepository(reader: _fromDisk).rights();
    for (final letter in pack.letters) {
      for (final locale in AppLocale.values) {
        final out = letter.render(const {}, locale);
        expect(out, isNot(contains('{{')),
            reason: '${letter.id} leaks a raw placeholder when nothing is '
                'filled in — that is what gets pasted into an application');
        expect(out, isNot(contains('}}')));
      }
    }
  });

  test('a filled letter keeps the reader\'s own words and drops the brackets',
      () async {
    final pack = await ContentRepository(reader: _fromDisk).rights();
    final letter = pack.letters.first;
    final values = {for (final f in letter.fields) f.key: 'X${f.key}X'};
    final out = letter.render(values, AppLocale.bn);
    for (final f in letter.fields) {
      expect(out, contains('X${f.key}X'),
          reason: 'the value for "${f.key}" did not reach the letter');
    }
    expect(out, isNot(contains('{{')));
  });

  test('whitespace alone counts as unfilled', () async {
    // Someone taps a field, types a space, moves on.
    final pack = await ContentRepository(reader: _fromDisk).rights();
    final letter = pack.letters.first;
    final key = letter.fields.first.key;
    final out = letter.render({key: '   '}, AppLocale.bn);
    expect(out, contains('['),
        reason: 'a field holding only spaces was treated as filled');
  });
}
