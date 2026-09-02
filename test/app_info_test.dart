import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/app_info.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';

void main() {
  test('the version shown in the app matches pubspec.yaml', () {
    // Hand-maintained version strings drift. This is what stops that.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*(\S+)\+(\d+)\s*$', multiLine: true)
            .firstMatch(pubspec);
    expect(match, isNotNull, reason: 'pubspec has no version line');
    expect(AppInfo.version, match!.group(1));
    expect(AppInfo.buildNumber, int.parse(match.group(2)!));
  });

  test('the application id matches the Android build', () {
    final gradle =
        File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('applicationId = "${AppInfo.applicationId}"'));
  });

  test('the release build is not signed with debug keys', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('signingConfigs.getByName("release")'));
    expect(gradle, contains('isMinifyEnabled = true'));
  });

  test('signing secrets are kept out of version control', () {
    final ignore = File('.gitignore').readAsStringSync();
    expect(ignore, contains('android/key.properties'));
    expect(ignore, contains('*.jks'));
  });

  test('copyright and licence are stated in both languages', () {
    expect(AppInfo.copyright.needsTranslation, isFalse);
    expect(AppInfo.licence.needsTranslation, isFalse);
    expect(AppInfo.licence.en, contains('Apache License 2.0'));
    expect(AppInfo.licence.en, contains('BY-SA 4.0'));
  });

  test('every attribution is explained, not just named', () {
    expect(AppInfo.attributions, isNotEmpty);
    for (final a in AppInfo.attributions) {
      expect(a.name.trim(), isNotEmpty);
      expect(a.detail.needsTranslation, isFalse, reason: a.name);
      expect(a.detail.of(AppLocale.en).trim(), isNotEmpty, reason: a.name);
    }
  });

  test('the licence files exist and name the project', () {
    expect(File('LICENSE').existsSync(), isTrue);
    expect(File('LICENSE').readAsStringSync(),
        contains('Copyright 2026 Nirman Pahara'));
    final notice = File('NOTICE').readAsStringSync();
    expect(notice, contains('SIL Open Font License'));
    expect(notice, contains('PWD Schedule of Rates'));
  });
}
