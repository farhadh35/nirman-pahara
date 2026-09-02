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
| Bilingual content engine (JSON packs, review badges, citations) | Working |
| Guide — 11 modules, 42 cards, both tracks, Bangla + English, with painted labelled diagrams | Working |
| Calculators — rod, concrete, brickwork, plaster, road layers, unit cost | Working, unit-tested against hand-computed values |
| Price check — market bands with dates and sources | Working |
| Cross-country cost comparison, with mandatory caveats | Working |
| **PWD Schedule of Rates 2022 (2nd revised)** — all 1,749 priced items, four regional columns, parsed from the official PDF | Working |
| **Rate schedule check** — work-type profiles flag items that should be present and are not; — import a departmental rate schedule (.xlsx / .csv / .docx / .txt) and get the unscheduled items, quantity overruns, unexecuted work, arithmetic mismatches and inconsistent rates, each with the document to ask for | Working |
| Inspection — checklist run, findings, text report, saved and resumable | Working |
| Rights — separate complaint ladders per track, RTI / complaint / contractor-notice templates | Working |
| Photo evidence — camera capture, stored in the app's own directory, attached per finding, viewable full-screen | Working |
| **Sharing** — report text plus every photograph, to any app the user already has | Working |
| **Capture context** — every photograph carries its timestamp and, where the phone can get a fix, its coordinates; when it cannot, the report says why | Working |
| PDF layout placing photographs beside their findings | Not yet — next phase |
| Audio narration | Not yet — needs a voice artist |
| Ads | Not yet integrated; policy fixed in `docs/AD_POLICY.md` |
| Electrical (E/M) rate schedule | Working — 2,606 items, 19 subheads, four zones |

Project page: https://farhadh35.github.io/nirman-pahara/ · Privacy policy: https://farhadh35.github.io/nirman-pahara/privacy.html

## Run it

```bash
flutter pub get
flutter test
flutter run
```

Release build, split per ABI (15.6 MB armeabi-v7a, 18.1 MB arm64):

```bash
flutter build apk --release --split-per-abi
```

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
    rights/       complaint ladder, letter templates
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

**69 technical claims carry citations; 51 are still awaiting sign-off by a
licensed civil engineer.** The app shows an amber badge on every one of them. Do
not ship to Play until that number is zero for the structural modules.

## Testing

298 tests: the calculator engine against hand-computed values, the content packs
against their own schema and translation completeness, report generation for
phrasing that never accuses, and end-to-end widget flows in both languages.

```bash
flutter test
```
