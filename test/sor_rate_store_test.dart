import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The rates a reader has typed in to compare against a bill.
///
/// `all()` is called while the prices screen is building, so anything it
/// throws becomes a red screen rather than a caught error — and it had the
/// same fault the inspection list had: it caught FormatException, which covers
/// text that is not JSON but not valid JSON of the wrong shape.
void main() {
  Future<SorRateStore> store() async =>
      SorRateStore(await SharedPreferences.getInstance());

  test('a rate saved is a rate read back', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await store();
    await s.save('04.1', const SavedRate(rateBdt: 512.5));
    expect(s.forItem('04.1')!.rateBdt, 512.5);
  });

  test('nothing saved reads as nothing, not as a crash', () async {
    SharedPreferences.setMockInitialValues({});
    expect((await store()).all(), isEmpty);
  });

  for (final (name, damaged) in [
    ('text that is not JSON', 'not json at all'),
    ('valid JSON of the wrong shape', '[1, 2, 3]'),
    ('an entry of the wrong shape', '{"04.1": 7}'),
  ]) {
    test('$name reads as empty rather than throwing', () async {
      SharedPreferences.setMockInitialValues({'sor_rates': damaged});
      final s = await store();
      expect(s.all(), isEmpty);
      expect(s.forItem('04.1'), isNull);
      // And it can still be written to afterwards, so the reader is not stuck.
      await s.save('04.1', const SavedRate(rateBdt: 100));
      expect(s.forItem('04.1')!.rateBdt, 100);
    });
  }

  test('the key holding the wrong type reads as empty', () async {
    SharedPreferences.setMockInitialValues({'sor_rates': 42});
    expect((await store()).all(), isEmpty);
  });
}
