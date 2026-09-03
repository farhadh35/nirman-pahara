import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/boq/logic/schedule_importer.dart';
import 'package:nirman_pahara/features/boq/logic/schedule_row_parser.dart';

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

  test('the RTI letter asks for a document the app can actually read',
      () async {
    // The app can check a BoQ line by line, but only if the BoQ arrives as a
    // sheet rather than as a photograph of one. The letter used to ask for
    // "printed copies", which guarantees the checker cannot be used on what
    // comes back — the reader files an application, waits twenty working days,
    // and receives something the app can do nothing with.
    final pack = await ContentRepository(reader: _fromDisk).rights();
    final rti = pack.letters.firstWhere((l) => l.id == 'rti_application');

    for (final locale in AppLocale.values) {
      final body = rti.body.of(locale);
      expect(body.toLowerCase(), contains(locale == AppLocale.bn ? 'এক্সেল' : 'excel'),
          reason: 'the letter does not ask for a machine-readable copy');
      // Naming PDF is fine, and the letter does — to say it cannot be used.
      // What must not happen is asking for one: an earlier version requested
      // "a PDF whose text can be selected", and the importer declines every
      // PDF on purpose, because guessing which number belongs in which column
      // turns into a confident claim about someone's money. That reader would
      // have waited twenty working days for a file the app will not open.
      // The extension check below is what enforces it.
      expect(ScheduleImporter.supportedExtensions, isNot(contains('pdf')));
      // And it must not close the door: an office with no soft copy should
      // still send paper rather than refuse the application over its form.
      expect(body, contains(locale == AppLocale.bn ? 'ছাপানো কপি' : 'printed copy'),
          reason: 'the letter demands a format the office may not have, which '
              'invites a refusal instead of an answer');
    }
  });

  test('every file type the letter names is one the importer reads', () async {
    // The letter and the importer have to agree about format as well as
    // columns: an office sends what it was asked for, once.
    final pack = await ContentRepository(reader: _fromDisk).rights();
    final body =
        pack.letters.firstWhere((l) => l.id == 'rti_application').body.en!;
    final named = RegExp(r'\.([a-z]{2,5})\b')
        .allMatches(body)
        .map((m) => m.group(1)!)
        .toSet();
    expect(named, isNotEmpty, reason: 'the letter names no file type at all');
    for (final ext in named) {
      expect(ScheduleImporter.supportedExtensions, contains(ext),
          reason: 'the letter asks for .$ext, which the importer cannot read');
    }
  });

  test('the columns the letter asks for are the columns the parser finds',
      () async {
    // If these two drift apart, the reader asks an office for a shape the
    // importer can no longer read, and finds out twenty working days later.
    final pack = await ContentRepository(reader: _fromDisk).rights();
    final body =
        pack.letters.firstWhere((l) => l.id == 'rti_application').body.bn;
    final missing = [
      for (final heading in ScheduleRowParser.columnHeadingsBn)
        if (!body.contains(heading)) heading,
    ];
    expect(missing, isEmpty,
        reason: 'the letter does not name these columns the importer looks '
            'for, so a sheet supplied to the letter may still import empty');
  });
}
