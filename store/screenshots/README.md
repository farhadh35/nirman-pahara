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

- **Do not hard-code where the onboarding button is.** It has moved twice —
  once when the layout changed, once when the "both" track option was
  withdrawn — and each time every coordinate after it was wrong and the whole
  set came back as one screen repeated. Find it: it is the only wide block of
  the brand green on the page.
- **Diff the content column, not the whole screen.** On the ten-inch tablet the
  page is held to 600dp and centred, so a quarter of the width is identical
  painted margin on every screen. A whole-image comparison diluted a real
  navigation down to 7 or 8, below the threshold, and rejected three screens in
  a row — which looked like a stubborn emulator and was arithmetic. Compare the
  middle 70%.
- **Check every shot against every other shot, not just against home.** A set
  once passed with six of the seven being the same screen: each was
  legitimately "not home".
- **Scroll the home page to the top before every tap.** This is the one that
  actually matters, and it took three sessions of blaming timing to find. Android
  restores the list's scroll position across a restart, so `am start -S` gives
  you the home screen sitting wherever it was left — and every y coordinate then
  lands on the wrong door. It produced a screenshot of the engineer's reference
  filed as the inspection screen, and a calculators shot opening halfway down
  the list instead of on the first group. Three upward swipes, then verify.
- Verify every shot. Comparing file hashes does not work, because the status-bar
  clock makes two captures of the same screen differ. Compare the whole image
  against a known-good home capture: a different screen scores above 10, home at
  the same scroll position scores 0. A crop of the top strip alone is too weak —
  some screens share the app bar's colouring and score around 6.
- Tap coordinates are per-device and have to be re-derived from a home capture
  each time. On the 1600 x 2560 tablet the measuring-tools door is at y 1063.
- `adb shell am start -S` force-restarts the activity, so each capture begins
  from a known home screen rather than wherever the last one left off. Backing
  out with the back key walks off the app and into the launcher.
