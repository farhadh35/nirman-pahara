import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The store listing must not advertise things the build no longer has.
///
/// Two features were removed on request — the complaint letter/ladder and the
/// amber "engineer review pending" badge — and the listing went on promising
/// both. A listing that describes a different app from the one downloaded is
/// exactly what Play judges a listing on, and it had already happened once
/// here (the counts at 1.1.1). These are the removed features by name.
void main() {
  final listings = ['store/LISTING-en.md', 'store/LISTING-bn.md'];

  test('the listing does not advertise the removed complaint path', () {
    for (final path in listings) {
      final text = File(path).readAsStringSync().toLowerCase();
      expect(text, isNot(contains('complaint template')),
          reason: '$path still offers a complaint template that was removed');
      expect(text, isNot(contains('in what order')),
          reason: '$path still promises an escalation order that was removed');
      expect(text, isNot(contains('অভিযোগের ধাপ')),
          reason: '$path still names the removed complaint ladder');
    }
  });

  test('the listing does not advertise the removed review badge', () {
    for (final path in listings) {
      final text = File(path).readAsStringSync().toLowerCase();
      expect(text, isNot(contains('visible mark')),
          reason: '$path still promises a review badge that was removed; '
              'claims now carry numbered references instead');
      expect(text, isNot(contains('যাচাই বাকি')),
          reason: '$path still names the removed review badge');
    }
  });
}
