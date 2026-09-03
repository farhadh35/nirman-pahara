# Google Play policy alignment — version 2.0.0 (versionCode 4)

Written against the binary built from commit-tagged `2.0.0+4`. Each section
names the policy, states what this app does, and — where it can be checked
mechanically — how to check it. Re-do this file for the next version rather than
editing it; a policy statement that outlives the build it describes is worse
than none.

**How to verify the binary this describes**

```bash
flutter build apk --release --target-platform android-arm64
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
# Permissions alone will not show a <service>. This is what section 7 describes:
aapt2 dump xmltree build/app/outputs/flutter-apk/app-release.apk \
  --file AndroidManifest.xml | grep -A 4 "E: service"
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

Expected: two location permissions, no `INTERNET`, and signer SHA-256
`f999…3147` (full fingerprint in `store/CHECKLIST.md`).

---

## 1. User Data — no collection

The app declares **no `INTERNET` permission**. It cannot transmit anything;
Android enforces that, not our good intentions. There is no server, no account,
no analytics and no advertising SDK.

Photographs, coordinates and inspection notes live in the app's private
directory. They leave only when the user taps share and chooses where to send
them. Data safety answers: `store/DATA-SAFETY.md`.

**Deletion.** Deleting an inspection removes it; uninstalling removes
everything. There is no server copy — including none we could hand over if
asked.

## 2. Permissions — minimum, and justified

| Permission | Why | Scope |
|---|---|---|
| `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | Stamps a photograph so a finding can say where it was seen | Foreground only, at capture |

No background location, so the background-location declaration does not apply.
`CAMERA` is deliberately **not** declared — the system camera is invoked by
intent. `INTERNET` is not declared. No storage permission is requested; files
arrive through the system picker.

Refusing location is a supported path, not a degraded one: the photograph is
still taken and the report says the location was not recorded, rather than
leaving a gap the reader might misread as "nothing to see".

## 3. Ads — none in this version

No ad SDK is present in `pubspec.yaml` or the manifest. The Play ads declaration
is **No** for 2.0.0. The app used to tell its own users, in the section headed
"where the money comes from", that it ran on advertising — while no ad SDK had
ever been in the build. It now says there are none, and what the rule will be if
any ever come. `docs/AD_POLICY.md` sets out the constraint that will
govern any future integration: no advertising from cement, steel, brick, tile,
paint, contractor or developer businesses, because the app's entire function is
telling someone whether those things are sound. An app that grades materials
and takes money from the people selling them is not worth shipping.

## 4. Misrepresentation and impersonation

This is the policy that matters most for an app about government works.

- **It does not claim to be a government app.** It says the opposite, in plain
  Bangla, in Settings under "who runs this app and where the money comes from":
  not a government app, not connected to any department, contractor or company,
  and nothing in it is an official decision. Pinned by
  `test/honest_claims_test.dart`. The developer name, icon and listing use no
  government emblem, seal or department name in a way that implies endorsement.
- **It does not accuse anyone.** Findings are framed as *what the rule requires*
  against *what was seen*, kept apart, so an authority can check for itself.
  Report generation is tested for phrasing that never asserts fraud.
- **It does not overstate what it is.** The listing and the app both say this is
  not an engineering test and not legal advice.
- **It never presents an unchecked claim as settled.** 103 of 136 cited
  technical claims have not been checked by a licensed civil engineer. The app
  does not call any claim verified, approved or engineer-checked anywhere in the
  product. What it shows on every claim instead is a numbered reference to the
  work the figure came from, resolving to one reference page that lists each of
  the twenty-one works once — so a reader can go to the source rather than take
  the app's word for it. Review backlog: `docs/CONTENT_REVIEW.md`.

## 5. Government data and published schedules

The app reproduces published government rate schedules and one gazette table.
They are shown unaltered, attributed, and dated, and are cited rather than
relicensed — see `NOTICE`. Where the published PDF misprints a cell, the cell is
recorded as unavailable rather than repaired by guesswork.

The plot-rules screen reports a FAR **ceiling** and says on the screen that it
is not an approval, because setbacks, ground coverage and the detailed area plan
cut the same envelope and RAJUK decides. Presenting it as a permission would be
the kind of misleading claim this policy exists to stop.

## 6. Families, content rating, and audience

Not directed at children. Target audience is adults. No violence, sexual
content, gambling, or in-app purchases. No user-to-user content: a report goes
only where its author sends it, so there is nothing to moderate between users.
Content rating questionnaire: **Reference / Education** utility.

## 7. Device and network abuse, background work

No scheduled jobs, no wake locks, no boot receiver, and no work of the app's own
while it is closed.

Two services are declared, both by plugins rather than by this app, and they are
in the shipped binary whatever this section says — so they are named here rather
than left for a reviewer to find:

- `com.baseflow.geolocator.GeolocatorLocationService`, from the location plugin,
  declared with `android:foregroundServiceType="location"`. The plugin binds it
  when the Flutter engine attaches, which is why a device log shows "Binding to
  location service" at every launch. It only enters the foreground through the
  plugin's `enableBackgroundMode`, which this app never calls: the app asks for
  one fix at the moment a photograph is taken and never subscribes to a stream.
  So the service is bound but never foregrounded, and takes no wake lock.
- `com.google.android.gms.metadata.ModuleDependencies`, from the image picker,
  declared `android:enabled="false"`. It exists to tell Play Services which
  module to install and does not run.

Both are left in place. The geolocator declaration could be deleted with
`tools:node="remove"` without breaking what this app does — a one-shot position
is served by the plugin's `GeolocationManager`, not by the service, which
carries position streams and background mode. But removing it would make the
plugin's `bindService` call fail at every launch and would break any later use
of a position stream, in exchange for nothing a reviewer needs: Play asks what
a foreground service is *used* for, and this one is never started. Declaring it
accurately here is the honest answer, not editing it out of the binary.

## 8. Technical requirements

`minSdk 24`, `targetSdk` from the current Flutter toolchain, R8 minification and
resource shrinking on release, App Bundle upload. Release builds **refuse** to
run without the upload keystore rather than silently falling back to debug
signing — see `store/CHECKLIST.md`.

## 9. Store listing accuracy

The listing describes what the build does, checked against it for this release:
17 calculators, 21 guide chapters, 94 cards, both rate volumes, the gazette FAR
table. It was wrong at 1.1.1 — still promising six calculators and 42 cards —
and the README was wrong in the other direction, calling a shipped feature "not
yet". Both are corrected. Anything the app does not do is named as not done, in
the README's own table.

Screenshots in `store/screenshots/` are from the release build, in Bangla, for
phone, 7-inch and 10-inch tablets.

## 10. Known gaps at this version

Stated here so a reviewer is not the one to discover them:

- 103 technical claims await a licensed civil engineer. They ship badged.
- The lift and escalator rate schedule is not included; the available scan
  could not be read reliably and nothing was shipped rather than something
  wrong. Request drafted in `docs/SOURCE-REQUESTS.md`.
- Labour and gang-size calculators are not built; they need coefficients the
  published schedule does not carry.
