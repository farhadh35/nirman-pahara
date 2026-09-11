import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/update/logic/update_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The update check, and the promise it must not break.
///
/// The listing says the app works offline and uploads nothing. That is why the
/// check is Play's and not ours: no socket is opened here, no identifier is
/// sent, and a reader with no connection gets an ordinary home screen rather
/// than an error. These tests hold the parts of that which are checkable
/// without a device.
void main() {
  test('the store link points at this app', () {
    final gradle = File('android/app/build.gradle.kts').existsSync()
        ? File('android/app/build.gradle.kts').readAsStringSync()
        : File('android/app/build.gradle').readAsStringSync();
    final id = RegExp(r'applicationId[ =]+"([^"]+)"').firstMatch(gradle)!;
    expect(UpdateCheck.storeUrl, contains('id=${id.group(1)}'),
        reason: 'the store link would open a different app, or nothing');
    expect(UpdateCheck.storeUrl, startsWith('https://'));
  });

  test('the check stays quiet for a day after it has asked', () async {
    // Someone on a site opens this app all day. Asking every launch would be
    // the app talking about itself instead of about the building.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var now = DateTime(2026, 9, 12, 9);
    final check = UpdateCheck(clock: () => now);

    expect(await check.dueForCheck(prefs), isTrue,
        reason: 'a fresh install should look once');
    await check.markAsked(prefs);
    expect(await check.dueForCheck(prefs), isFalse);

    now = now.add(const Duration(hours: 23));
    expect(await check.dueForCheck(prefs), isFalse,
        reason: 'still inside the quiet day');

    now = now.add(const Duration(hours: 2));
    expect(await check.dueForCheck(prefs), isTrue,
        reason: 'a day has passed, so looking again is reasonable');
  });

  test('no update path is written by hand against a server of our own',
      () async {
    // If someone later replaces Play's check with an http call to a version
    // file, the listing's "everything works offline, nothing is uploaded"
    // stops being true and Data safety has to change with it. This is the
    // tripwire for that.
    final src =
        File('lib/features/update/logic/update_check.dart').readAsStringSync();
    for (final banned in ['HttpClient', 'package:http', 'dart:io', 'get(Uri']) {
      expect(src, isNot(contains(banned)),
          reason: 'the update check is opening its own connection ($banned); '
              'the listing promises the app uploads nothing');
    }
  });

  test('the app asks for no INTERNET permission at all', () {
    // The strongest form of the offline promise, and the reason adding the
    // Play update check cost nothing: it goes through Play services by IPC,
    // not through a socket of ours. An app with no INTERNET permission cannot
    // upload anything, whatever its code says. If this ever fails, the
    // listing's "Everything works offline. Nothing is uploaded." needs
    // rewriting and Data safety needs revisiting in the same change.
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, isNot(contains('android.permission.INTERNET')),
        reason: 'something now wants network access directly');
  });

  test('the listing still promises offline, so the check must stay Play\'s',
      () {
    final listing = File('store/play-description-en.txt').readAsStringSync();
    expect(listing, contains('Everything works offline'),
        reason: 'if this promise is dropped the tripwire above can be relaxed; '
            'while it stands, the update check may not phone home');
  });
}
