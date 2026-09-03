# Play Console readiness

Ticked items are done in the repository. The rest need a person with the
developer account.

## Done in the build

- [x] Application ID `bd.nirmanpahara.nirman_pahara`
- [x] Version 2.0.0 (versionCode 4), asserted against `pubspec.yaml` by a test
- [x] Release signing from `android/key.properties` → `android/keystore/nirman-upload.jks`.
      A release build **refuses** to run without the key rather than falling back
      to debug signing, because that fallback was silent: the Gradle output looks
      the same either way and Play is the first thing that tells you. Building
      one on purpose takes `-PallowDebugSigning=true`.
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

- [ ] **Get the keystore off this machine.** A staging copy of
      `nirman-upload.jks` now sits in `~/nirman-pahara-signing-backup/` with a
      checksum and instructions, but that is the same disk as the original: it
      survives a mistaken delete and nothing else. Move it to an encrypted
      drive or an encrypted archive in cloud storage, then delete the folder.
      The password is deliberately **not** in that folder — put it in a
      password manager, because a key and its password in one place is one
      leak rather than two.
      Losing both means this listing can never be updated again: a new app ID,
      a new listing, and every existing install left on the version it has.
- [ ] **Confirm Play App Signing is enabled** (Play Console → the app → Test and
      release → Setup → App signing). If it is, a lost upload key can be reset
      by registering a new one. If it is not, there is no recovery — which
      makes the item above the single most important line on this page.

The upload certificate, for checking a restored key or an upload that is
refused. None of this is secret; the fingerprint ships inside every APK:

```
Owner   CN=Nirman Pahara, OU=Nirman Pahara, O=Nirman Pahara, L=Dhaka, ST=Dhaka, C=BD
Alias   nirman-upload
SHA256  F9:99:42:F9:43:CE:96:49:77:E7:C1:80:62:97:3B:EE:12:43:32:B1:AC:41:D8:CE:05:48:4A:D2:E2:8C:31:47
Valid   2026-09-02 to 2054-01-18
```

Verified against the shipped artifact: `apksigner verify --print-certs` on
`app-arm64-v8a-release.apk` reports the same digest, so release builds really
are signed with this key and not with a debug fallback.
- [x] Privacy policy published at https://farhadh35.github.io/nirman-pahara/privacy.html
      — paste that URL into the listing and the Data safety form
- [x] Contact email in the privacy policy and the listing
- [x] Screenshots: three in `store/screenshots/` (home, the checklists, an
      inspection starting), captured from the release build in Bangla. Add more
      if you want the report and the rate-schedule findings shown.
- [x] Feature graphic at `store/feature-graphic-1024x500.png`
- [ ] Content rating questionnaire
- [ ] **Ads declaration: no.** This said "yes". There is no ad SDK in the
      build — nothing in `pubspec.yaml`, nothing in the manifest — so declaring
      ads would be telling Google something untrue about the binary being
      uploaded. Change it to "yes" in the same release that first ships an ad
      SDK, not before, and set the ad network's category blocking first
      (`docs/AD_POLICY.md`).
- [ ] Target audience: adults
- [ ] Countries: Bangladesh at minimum
- [ ] Configure the ad network's category blocking before the first ad is
      served — see `docs/AD_POLICY.md`

## Should be done before the first public release

- [ ] **Engineer sign-off on the technical content.** `docs/CONTENT_REVIEW.md`
      lists every cited claim; the ones still marked `review` show an amber
      badge in the app. Publishing with structural claims unreviewed is the
      main outstanding risk, not a build problem.

## Uploading 2.0.0

The listing text changed this release, so it is not a bundle-only upload.

1. **Bundle** — `build/app/outputs/bundle/release/app-release.aab`, built from
   `flutter build appbundle --release`. Version 2.0.0, versionCode 4.
2. **Release notes** — the `2.0.0 (4)` block in `store/RELEASE-NOTES.md`. Paste
   the `<bn-BD>` text into Bengali and the `<en-US>` text into English. Both are
   inside Play's 500-character limit.
3. **Store listing** — `store/LISTING-bn.md` and `store/LISTING-en.md` under
   Main store listing. These are **two separate listings**, one per language,
   each with its own title and short description — set the language in Play
   Console before pasting, or the English text overwrites the Bangla one.
   The English title is deliberately "Nirman Pahara: Civil Works" and the
   Bangla one is "নির্মাণ পাহারা" alone: Play has no keywords field, so the
   title and short description are what English search matches against, and
   a Bangla searcher is already typing the name. The full descriptions changed: they were still
   describing six calculators and 42 guide cards, and the app now has seventeen
   and ninety-seven. Both are under the 4,000-character limit.
4. **What is new to mention if asked**: the plot-rules screen reads the FAR
   index off Table 5 of the 2025 Dhaka building rules gazette. It reports a
   ceiling, not an approval, and says so on the screen — worth keeping that
   distinction in any description written outside these files.
5. Roll out staged, not to 100% at once.

## Building a release

```bash
flutter build appbundle --release
```

Bump `version:` in `pubspec.yaml` **and** `AppInfo` in `lib/core/app_info.dart`
before every upload — the test in `test/app_info_test.dart` fails if they drift.
Artifact: `build/app/outputs/bundle/release/app-release.aab`.
