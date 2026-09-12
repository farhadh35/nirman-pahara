import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Precise location is not declared, and must not come back by accident.
///
/// `ACCESS_FINE_LOCATION` was declared from 2.0.0 and never used — the single
/// call site asks for `LocationAccuracy.medium`, which coarse satisfies. Play
/// treats precise location as a permission a developer has to justify, and a
/// report saying which building a defect was seen at does not need a fix good
/// to a few metres.
///
/// It cannot simply be left out of the app manifest: the geolocator plugin
/// declares it, and manifest merging would put it back. It is removed
/// explicitly instead, which is a thing a careless merge-conflict resolution
/// can undo without anyone noticing.
void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('the app asks for coarse location and removes fine', () {
    expect(manifest, contains('ACCESS_COARSE_LOCATION'),
        reason: 'coarse location has gone; photographs can no longer be stamped');
    expect(
        RegExp(r'ACCESS_FINE_LOCATION"\s*\n?\s*tools:node="remove"')
            .hasMatch(manifest),
        isTrue,
        reason: 'ACCESS_FINE_LOCATION is no longer explicitly removed, so the '
            'geolocator plugin\'s own declaration will merge back in and the '
            'app will ask for precise location again');
    expect(manifest, contains('xmlns:tools='),
        reason: 'the tools namespace is missing, so tools:node="remove" is inert');
  });

  test('nothing in the app asks for a precise fix', () {
    // The permission and the accuracy have to move together. Raising the
    // accuracy without restoring the permission gives a worse fix silently;
    // restoring the permission without raising the accuracy is the state this
    // test was written to end.
    final src = File('lib/features/inspection/logic/evidence_store.dart')
        .readAsStringSync();
    expect(src, contains('LocationAccuracy.medium'),
        reason: 'the requested accuracy changed; check whether coarse location '
            'still satisfies it before shipping');
    for (final high in ['LocationAccuracy.high', 'LocationAccuracy.best']) {
      expect(src.contains(high), isFalse,
          reason: '$high needs ACCESS_FINE_LOCATION, which this build removes');
    }
  });
}
