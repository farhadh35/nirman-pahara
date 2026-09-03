import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The build declares, in three places, that it carries no advertising:
/// store/CHECKLIST.md ("Ads declaration: no"), store/DATA-SAFETY.md ("no
/// advertising SDK"), and the Play Console answer that follows from them.
///
/// That declaration is only true as long as the binary stays free of an ad SDK
/// and the AD_ID permission. If one is added and the declaration is not flipped
/// to "yes" in the same release, Google has been told something untrue about
/// the uploaded binary — which is exactly the failure CHECKLIST.md warns
/// against. This fails the moment the binary and the declaration disagree, so
/// the reminder is a red test rather than a rejected upload.
void main() {
  // Package names of the ad SDKs a Flutter app is realistically shipped with.
  const adPackages = [
    'google_mobile_ads',
    'admob_flutter',
    'firebase_admob',
    'applovin_max',
    'unity_ads_plugin',
    'facebook_audience_network',
    'appodeal_flutter',
    'ironsource_mediation',
  ];

  test('no advertising SDK is a dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final lock = File('pubspec.lock').readAsStringSync();
    final found = [
      for (final pkg in adPackages)
        if (pubspec.contains(pkg) || lock.contains(pkg)) pkg,
    ];
    expect(found, isEmpty,
        reason: 'an ad SDK ($found) is in the build, but store/CHECKLIST.md and '
            'store/DATA-SAFETY.md still declare no ads. Flip the Play ads '
            'declaration to "yes" in this release and update both files.');
  });

  test('the manifest requests no advertising ID', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest.contains('AD_ID'), isFalse,
        reason: 'the AD_ID permission is declared, which means something in the '
            'build reads the advertising ID — reconcile with the no-ads '
            'declaration in store/DATA-SAFETY.md');
  });

  test('the data-safety file still states there is no ad SDK', () {
    // If the "no ads" line is edited out, the tests above go quiet about a
    // claim nobody is making any more. This keeps the claim present so the
    // guards above stay meaningful.
    final safety = File('store/DATA-SAFETY.md').readAsStringSync();
    expect(safety.toLowerCase(), contains('no advertising sdk'),
        reason: 'store/DATA-SAFETY.md no longer states there is no ad SDK; the '
            'ad-SDK guards are now checking against nothing');
  });
}
