# Store screenshots

Captured from the **release** build (`flutter build apk --release`), in Bangla,
on Android 15 emulators. The debug banner is off in every build
(`debugShowCheckedModeBanner: false`), so nothing had to be edited out.

| Folder | Device | Size | Play field |
|---|---|---|---|
| `phone/` | 1080 × 2400, 420 dpi | 7 shots | Phone screenshots |
| `tablet-7/` | 1200 × 1920, 320 dpi (600 dp wide) | 7 shots | 7-inch tablet |
| `tablet-10/` | 1600 × 2560, 320 dpi (800 dp wide) | 7 shots | 10-inch tablet |

All three sets show the same seven screens in the same order, so the listing
reads consistently whichever device a visitor is browsing from:

1. **home** — the ten doors and the track chips
2. **learn** — the guide index
3. **calculate** — the calculators, grouped by the moment on site they are used
4. **plot-rules** — FAR read off the 2025 gazette, showing a worked answer and
   the caution that it is a ceiling and not an approval
5. **measure** — land units converted every way at once, with the deed-style
   bigha/katha/remainder breakdown
6. **tables** — the reference tables, with the amber "engineer not yet checked"
   badge visible on the rows that carry it
7. **inspect** — the checklist packs

Shot 6 is deliberate: it shows an unverified row wearing its badge. A listing
that only showed signed-off content would misrepresent what a new user opens.

## Recapturing

Screens are laid out in a single scrolling column, so the capture is just
"start the app, tap a door, screenshot". Two things bite:

- Tap coordinates are per-device and have to be re-derived from a home-screen
  capture each time; a 10-inch emulator is slow enough that a tap five seconds
  after launch can land before the list has drawn, which silently leaves you
  with a second copy of the home screen. Check every shot.
- `adb shell am start -S` force-restarts the activity, so each capture begins
  from a known home screen rather than wherever the last one left off. Backing
  out with the back key walks off the app and into the launcher.
