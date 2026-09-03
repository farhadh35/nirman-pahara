import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/photo_ref.dart';

void main() {
  final taken = DateTime(2026, 7, 12, 9, 5);
  final fallback = DateTime(2026, 1, 1);

  group('describe', () {
    test('states the time and the place when both are known', () {
      const location = 24.89431;
      final p = PhotoRef(
        name: 'a.jpg',
        takenAt: taken,
        latitude: location,
        longitude: 89.37215,
      );
      expect(p.describe(AppLocale.en), '2026-07-12 09:05 · 24.89431, 89.37215');
      expect(p.describe(AppLocale.bn),
          '২০২৬-০৭-১২ ০৯:০৫ · 24.89431, 89.37215');
    });

    test('says why the location is missing, not merely that it is', () {
      // Each cause needs a different action from the user, so each is named.
      final cases = {
        LocationOutcome.serviceOff: 'switched off',
        LocationOutcome.permissionDenied: 'not given permission',
        LocationOutcome.noFix: 'no GPS signal',
      };
      for (final e in cases.entries) {
        final p = PhotoRef(name: 'a.jpg', takenAt: taken, outcome: e.key);
        expect(p.hasLocation, isFalse);
        expect(p.describe(AppLocale.en), contains('location not recorded'));
        expect(p.describe(AppLocale.en), contains(e.value), reason: e.key.name);
        expect(p.describe(AppLocale.bn), contains('অবস্থান রেকর্ড হয়নি'));
      }
    });

    test('a half-known position counts as no position', () {
      final p = PhotoRef(name: 'a.jpg', takenAt: taken, latitude: 24.9);
      expect(p.hasLocation, isFalse);
      expect(p.describe(AppLocale.en), contains('not recorded'));
    });

    test('a recorded location says nothing about failure causes', () {
      final p = PhotoRef(
        name: 'a.jpg',
        takenAt: taken,
        latitude: 24.9,
        longitude: 89.3,
        outcome: LocationOutcome.recorded,
      );
      expect(p.describe(AppLocale.en), isNot(contains('not recorded')));
    });
  });

  group('json', () {
    test('round trips', () {
      final p = PhotoRef(
        name: 'a.jpg',
        takenAt: taken,
        latitude: 24.89431,
        longitude: 89.37215,
      );
      expect(PhotoRef.fromJson(p.toJson(), fallbackTakenAt: fallback), p);
    });

    test('omits a location it does not have but records the reason', () {
      final json = PhotoRef(
        name: 'a.jpg',
        takenAt: taken,
        outcome: LocationOutcome.permissionDenied,
      ).toJson();
      expect(json.containsKey('lat'), isFalse);
      expect(json.containsKey('lon'), isFalse);
      expect(json['location_outcome'], 'permission_denied');
      expect(
        PhotoRef.fromJson(json, fallbackTakenAt: fallback).outcome,
        LocationOutcome.permissionDenied,
      );
    });

    test('reads a bare file name from the earlier format', () {
      final p = PhotoRef.fromJson('old.jpg', fallbackTakenAt: fallback);
      expect(p.name, 'old.jpg');
      expect(p.takenAt, fallback);
      expect(p.hasLocation, isFalse);
    });

    test('a photograph saved before reasons existed reads cleanly', () {
      // It must not claim a cause it never recorded, and must not leave a
      // dangling separator with nothing after it.
      final p = PhotoRef.fromJson(
        {'name': 'old.jpg', 'taken_at': '2026-07-12T09:05:00.000'},
        fallbackTakenAt: fallback,
      );
      expect(p.outcome, LocationOutcome.unknown);
      expect(p.describe(AppLocale.en), '2026-07-12 09:05 · location not recorded');
      expect(p.describe(AppLocale.en), isNot(endsWith('· ')));
      expect(p.describe(AppLocale.bn), isNot(endsWith('· ')));
    });

    test('a located photograph never shows a trailing separator', () {
      final p = PhotoRef(
        name: 'a.jpg',
        takenAt: taken,
        latitude: 24.9,
        longitude: 89.3,
        outcome: LocationOutcome.recorded,
      );
      expect(p.describe(AppLocale.en), endsWith('24.90000, 89.30000'));
    });

    test('falls back when an object has no capture time', () {
      final p = PhotoRef.fromJson({'name': 'x.jpg'}, fallbackTakenAt: fallback);
      expect(p.takenAt, fallback);
    });
  });
}
