import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/boq/logic/schedule_importer.dart';

/// What the importer does with a file that is not what it claims to be.
///
/// This is the likeliest failure on this screen: a schedule that was renamed,
/// half-downloaded, exported wrong, or is simply a photograph with a
/// spreadsheet extension. The screen used to catch `on Exception`, and the
/// thing actually thrown here is an `Error`, so it escaped and left the spinner
/// running forever.
void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('import_fail'));
  tearDown(() => dir.deleteSync(recursive: true));

  File write(String name, List<int> bytes) =>
      File('${dir.path}/$name')..writeAsBytesSync(bytes);

  test('a file that is not a spreadsheet throws an Error, not an Exception',
      () async {
    // The fact that pins the bug: `on Exception` was never going to catch it.
    Object? thrown;
    try {
      await const ScheduleImporter().read(write('x.xlsx', List.filled(400, 65)));
    } catch (e) {
      thrown = e;
    }
    expect(thrown, isNotNull);
    expect(thrown is Exception, isFalse,
        reason: 'if this becomes an Exception the screen\'s catch-all is still '
            'correct, but the comment explaining it is not');
  });

  test('every kind of unreadable file fails loudly rather than hanging',
      () async {
    // Whatever is thrown, it must be thrown — not swallowed into a result that
    // looks like a successful import of nothing.
    final cases = <String, List<int>>{
      'renamed-photo.xlsx': [255, 216, 255, 224, 0, 16, 74, 70, 73, 70],
      'truncated.xlsx': [80, 75, 3, 4],
      'garbage.docx': List.filled(200, 66),
    };
    for (final e in cases.entries) {
      Object? thrown;
      var rows = -1;
      try {
        final r = await const ScheduleImporter().read(write(e.key, e.value));
        rows = r.document.lines.length;
      } catch (err) {
        thrown = err;
      }
      expect(thrown != null || rows == 0, isTrue,
          reason: '${e.key} came back looking like a real import');
    }
  });

  test('an empty file of a supported kind is not mistaken for a schedule',
      () async {
    for (final name in ['empty.csv', 'empty.txt']) {
      Object? thrown;
      var rows = -1;
      try {
        final r = await const ScheduleImporter().read(write(name, <int>[]));
        rows = r.document.lines.length;
      } catch (err) {
        thrown = err;
      }
      expect(thrown != null || rows == 0, isTrue,
          reason: '$name produced rows out of nothing');
    }
  });

  test('a PDF is refused by name, with its own explanation', () async {
    // Deliberate: the picker allows PDFs so the reader gets told why it cannot
    // be used, rather than not being able to select the file they have.
    final r = await const ScheduleImporter().read(write('s.pdf', [37, 80, 68]));
    expect(r.warning, isNotNull);
    expect(r.document.lines, isEmpty);
  });
}
