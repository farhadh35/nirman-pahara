# Play Console readiness

Ticked items are done in the repository. The rest need a person with the
developer account.

## Done in the build

- [x] Application ID `bd.nirmanpahara.nirman_pahara`
- [x] Version 1.0.0 (versionCode 1), asserted against `pubspec.yaml` by a test
- [x] Release signing from `android/key.properties` → `android/keystore/nirman-upload.jks`
      (debug fallback when the key is absent, so a build without the key can
      never be uploaded by accident)
- [x] `minSdk 24`
- [x] R8 minification and resource shrinking on release
- [x] Signed Android App Bundle builds and verifies as `CN=Nirman Pahara`
- [x] Adaptive launcher icon, all densities, plus the 512 px store icon
- [x] `LICENSE` (Apache-2.0) and `NOTICE` with every attribution
- [x] Store listing copy, Bangla and English
- [x] Privacy policy text
- [x] Data safety answers
- [x] Release notes

Project page: https://farhadh35.github.io/nirman-pahara/
Source: https://github.com/farhadh35/nirman-pahara

## Needs the account holder

- [ ] **Back the keystore up off this machine.** Losing
      `android/keystore/nirman-upload.jks` means this app can never be updated
      on Play again. Copy it and `android/key.properties` somewhere safe before
      the first upload.
- [x] Privacy policy published at https://farhadh35.github.io/nirman-pahara/privacy.html
      — paste that URL into the listing and the Data safety form
- [x] Contact email in the privacy policy and the listing
- [x] Screenshots: three in `store/screenshots/` (home, the checklists, an
      inspection starting), captured from the release build in Bangla. Add more
      if you want the report and the rate-schedule findings shown.
- [x] Feature graphic at `store/feature-graphic-1024x500.png`
- [ ] Content rating questionnaire
- [ ] Ads declaration: yes
- [ ] Target audience: adults
- [ ] Countries: Bangladesh at minimum
- [ ] Configure the ad network's category blocking before the first ad is
      served — see `docs/AD_POLICY.md`

## Should be done before the first public release

- [ ] **Engineer sign-off on the technical content.** `docs/CONTENT_REVIEW.md`
      lists every cited claim; the ones still marked `review` show an amber
      badge in the app. Publishing with structural claims unreviewed is the
      main outstanding risk, not a build problem.

## Building a release

```bash
flutter build appbundle --release
```

Bump `version:` in `pubspec.yaml` **and** `AppInfo` in `lib/core/app_info.dart`
before every upload — the test in `test/app_info_test.dart` fails if they drift.
Artifact: `build/app/outputs/bundle/release/app-release.aab`.
