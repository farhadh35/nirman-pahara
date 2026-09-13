import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Play policy document says the location service is bound but never
/// started in the foreground, and never takes a wake lock. That is true only
/// because of what this app declines to call: the plugin foregrounds itself
/// exclusively through `enableBackgroundMode`, which comes with a position
/// stream and a notification.
///
/// So the claim is a fact about the app's source, not about the plugin, and it
/// stops being true the moment somebody subscribes to a stream. This reads the
/// source rather than the behaviour, because that is where the claim lives.
void main() {
  final lib = Directory('lib');

  Iterable<File> dartFiles() => lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  test('nothing asks the location plugin for a stream or background mode', () {
    // Any of these would put the service into the foreground, at which point
    // docs/PLAY-POLICY.md section 7 is wrong and Play's foreground
    // service declaration becomes something the listing has to answer for.
    const foregrounding = [
      'getPositionStream',
      'enableBackgroundMode',
      'foregroundNotificationConfig',
      'ForegroundNotificationConfig',
    ];

    final found = <String>[];
    for (final file in dartFiles()) {
      final text = file.readAsStringSync();
      for (final call in foregrounding) {
        if (text.contains(call)) found.add('${file.path}: $call');
      }
    }
    expect(found, isEmpty,
        reason: 'the app now foregrounds the location service, so section 7 of '
            'docs/PLAY-POLICY.md no longer describes the build');
  });

  test('the policy document still names both declared services', () {
    // If the doc is rewritten back to "no services", the binary contradicts it
    // again — and the reviewer's own command is the one that finds out.
    final doc = File('docs/PLAY-POLICY.md').readAsStringSync();
    expect(doc, contains('GeolocatorLocationService'));
    expect(doc, contains('ModuleDependencies'));
    expect(doc, contains('aapt2 dump xmltree'),
        reason: 'the doc lists commands that cannot show a service, and omits '
            'the one that can');
    expect(doc, isNot(contains('no foreground services')),
        reason: 'the flat denial is back, and the shipped manifest still '
            'declares one');
  });
}
