import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `on Exception` is the clause that looks careful and is not.
///
/// Dart splits thrown things into Exception, meaning a condition the caller
/// might reasonably handle, and Error, meaning a mistake — and plenty of real
/// code throws the second kind for the first kind of reason. Feeding the
/// schedule importer a file that is not really a spreadsheet throws
/// UnsupportedError; the geolocation and PDF plugins throw Errors too. Every
/// one of those walked past an `on Exception` clause.
///
/// The consequences were not crashes, which would at least be visible. They
/// were a spinner that never stopped and a progress snackbar that never came
/// down, because the code that would have cleared them sat inside a catch that
/// never ran.
///
/// So the rule is: catch a specific type you have actually thought about, or
/// catch everything. Never the middle.
void main() {
  Iterable<File> dartFiles(String root) => Directory(root)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  test('nothing in lib catches `on Exception`', () {
    final offenders = <String>[];
    for (final file in dartFiles('lib')) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // The comments explaining this rule mention the phrase; a clause has a
        // brace or a `catch` after it.
        if (RegExp(r'\}\s*on\s+Exception\s*(catch\s*\([^)]*\)\s*)?\{')
            .hasMatch(line)) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'an Error thrown here walks straight past this clause, and '
            'whatever cleanup sits inside it never runs:\n'
            '${offenders.join('\n')}');
  });

  test('a specific catch is still fine, and still used', () {
    // The rule is about the broad-but-not-broad-enough clause, not about
    // catching a type deliberately. If these disappear the codebase has
    // started catching everything everywhere, which is its own problem.
    var specific = 0;
    for (final file in dartFiles('lib')) {
      specific += RegExp(r'on (CalcException|FormatException|ArgumentError)')
          .allMatches(file.readAsStringSync())
          .length;
    }
    expect(specific, greaterThan(0));
  });
}
