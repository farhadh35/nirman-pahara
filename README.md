# নির্মাণ পাহারা · Nirman Pahara

A Bangla-first Android app that lets a non-engineer check whether a construction
work is being done properly — a Union Parishad road, a school building, or their
own house — and, when it is not, produce a report and know where to send it.

Bangla is the default language throughout; English is available from settings and
covers the interface **and** the content.

## Why

TIB estimates that 23–40% of the value of road and bridge works between FY2009-10
and FY2023-24 was lost, largely through substandard or short-supplied materials —
the class of problem someone standing at the site can actually catch, if anyone
tells them what to look at. The accountability plumbing already exists (BPPA's
citizen portal, the DIMAPPP citizen-monitoring model, GRS/333, the RTI Act) and is
invisible to the people it is for.

## What is built

| Area | State |
|---|---|
| Bilingual content engine (JSON packs, numbered references, citations) | Working |
| Guide — 22 modules, 97 cards, both tracks, Bangla + English, with painted labelled diagrams | Working |
| Calculators — 17 of them, grouped by the moment on site they are used: checking a delivery (brick stack, brick count, rod delivery), casting day (concrete, rod weight, hook length, shuttering, soling), walls and finishing (brickwork, plaster, tiles, paint), earth and road (earthwork with bulking and trips, road layers), inside the house (stairs, water and septic), and cost | Working, unit-tested against hand-computed values |
| Price check — market bands with dates and sources | Working |
| Cross-country cost comparison, with mandatory caveats | Working |
| **PWD Schedule of Rates 2022 (2nd revised)** — all 1,749 priced items, four regional columns, parsed from the official PDF | Working |
| **Rate schedule check** — work-type profiles flag items that should be present and are not; — import a departmental rate schedule (.xlsx / .csv / .docx / .txt) and get the unscheduled items, quantity overruns, unexecuted work, arithmetic mismatches and inconsistent rates, each with the document to ask for | Working |
| Inspection — checklist run, findings, text report, saved and resumable | Working |
| Rights — RTI application and contractor-notice letter templates | Working |
| Photo evidence — camera capture, stored in the app's own directory, attached per finding, viewable full-screen | Working |
| **Sharing** — report text plus every photograph, to any app the user already has | Working |
| **Capture context** — every photograph carries its timestamp and, where the phone can get a fix, its coordinates; when it cannot, the report says why | Working |
| PDF layout placing photographs beside their findings | Working — each photograph renders inside its own finding's block, with its time and place under it |
| Lift and escalator rate schedule | Not yet — the 2026 edition is a poor scan; per-cell OCR recovered 74 of ~530 rows and misread a price column, so nothing was shipped rather than something wrong. Needs a machine-readable copy from PWD |
| Labour and gang-size calculators | Not yet — needs PWD's *analysis of rates* labour coefficients. The shipped schedule carries rates only, and the 2019 wage tables were rejected as stale rather than shown |
| Audio narration | Not yet — needs a voice artist |
| Ads | Not yet integrated; policy fixed in `docs/AD_POLICY.md` |
| Electrical (E/M) rate schedule | Working — 2,606 items, 19 subheads, four zones |
| **Plot rules** — the road-width FAR table from the 2025 Dhaka building rules gazette, 51 rows across 39 occupancy classes and three housing zones, extracted and structurally checked rather than typed | Working — reports a ceiling, not an approval |
| **Measuring tools** — কাঠা/বিঘা/শতাংশ and the rest against the square foot, সুতা to the millimetre bar the trade actually sells, and areas and volumes for eight shapes | Working |
| **Reference tables** — mix ratios, curing, formwork striking times, sand fineness, cost share by element; 5 tables, 41 rows, each row carrying its source and its review status | Working |
| Engineer's reference tier — foundation classes, pile types and caps, tie and grade beams, bore-log reading | Working — reachable only by choosing it, never by scrolling |

Project page: https://farhadh35.github.io/nirman-pahara/ · Privacy policy: https://farhadh35.github.io/nirman-pahara/privacy.html

## Run it

```bash
flutter pub get
flutter test
flutter run
```

Release build, split per ABI (18.6 MB armeabi-v7a, 20.7 MB arm64):

```bash
flutter build apk --release --split-per-abi
```

The Play bundle:

```bash
flutter build appbundle --release
```

### Signing

Release signing lives in `android/key.properties` and `android/keystore/`, both
outside the repository. A release build refuses to run without them:

```
Refusing to build a debug-signed release: the keystore
'../keystore/nirman-upload.jks' named by android/key.properties is missing.
```

It used to fall back to debug signing silently, which is worse than it sounds:
the Gradle output is identical either way, Flutter filters warnings out of it,
and the first thing that tells you is the Play upload dialog rejecting the
signature. To build without the key on purpose — a contributor who only wants to
check that the release build compiles — say so:

```bash
flutter build apk --release -PallowDebugSigning=true
```

**The keystore has no second copy.** It is gitignored, it exists only on the
machine that made it, and losing it means the app can never be updated under
its current Play listing — a new one would have to be published from scratch,
with every install starting over. Back up `android/keystore/nirman-upload.jks`
and `android/key.properties` somewhere off this machine before the next release.

## Layout

```
lib/
  app/            theme, state, scope, shared widgets
  core/
    content/      content models + repository (guide, checklists, rights, prices)
    i18n/         AppLocale, L10nText, interface strings
    util/         Bangla numerals and lakh/crore formatting
  features/
    guide/        module list and card reader
    calculators/  pure-Dart calc engine + one declarative form screen
    prices/       market band comparison, cross-country benchmarks
    inspection/   checklist run and report generation
    rights/       letter templates
    home/         home and onboarding
    settings/     language, text size, track, disclosure
assets/content/   the content packs — this is the product's core IP
docs/             content rules, generated review sheet, ad policy
tool/             review-sheet generator
```

The calculator engine has no Flutter dependency at all and is tested on its own.
Content is bundled, so the app is fully usable with no network — which is the
normal condition for the audience.

## Content

`assets/content/` holds everything the app says. Anyone editing it must read
[`docs/CONTENT_RULES.md`](docs/CONTENT_RULES.md) first. The short version: every
number carries a source; no Indian standards; never assert wrongdoing; review
state is visible, not hidden.

`docs/CONTENT_REVIEW.md` is generated — regenerate after any content change:

```bash
dart run tool/review_sheet.dart
```

**159 technical claims carry citations; 129 are still awaiting sign-off by a
licensed civil engineer.** Review state lives in this sheet, not in the app; what
the app shows on each claim is a numbered reference to its source. Do not ship to
Play until that number is zero for the structural modules.

That count covers guide cards only. The reference tables carry their own review
status per row, and the FAR table is the gazette's own text — neither is in the
sheet, and neither is waiting on the same sign-off.

## Testing

365 tests: the calculator engine against hand-computed values, the content packs
against their own schema and translation completeness, report generation for
phrasing that never accuses, and end-to-end widget flows in both languages.

Two of them are worth knowing about. `test/nan_sweep_test.dart` pushes NaN and
both infinities into every numeric input on every calculator and fails if any of
them answers with a number that is not a number — a guard written as `x <= 0`
looks complete and is not, because every comparison against NaN is false.
`test/calc_spec_ui_test.dart` runs each calculator with the values its own form
seeds, because the screen shows its answer the moment it opens and a form that
greets the reader with an error reads as a broken app.

```bash
flutter test
```
