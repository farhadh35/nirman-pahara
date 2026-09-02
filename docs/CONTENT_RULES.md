# Content rules

These are binding on anyone writing or editing content for this app. They exist
because the app tells people whether a building they cannot inspect is safe, and
whether money they cannot audit was spent properly. Getting that wrong in either
direction — scaring people off sound work, or reassuring them about bad work —
does real damage.

## 1. No bare numbers

Every technical figure carries a `citations` entry naming the source (BNBC 2020
part and clause, PWD SoR item, LGED standard drawing, BDS standard). The app
shows it behind a **সূত্র** tap. A number with no source does not ship.

## 2. No Indian standards

BNBC 2020 Part 6 is ACI-318-aligned. Most "construction checklist" material in
circulation online is Indian and quotes IS 456 for cover, development length and
concrete grade. Those numbers are wrong here. Check the BNBC gazette, not a blog.

## 3. Never assert wrongdoing

Phrase every check as: **the standard requires X; what you observed is Y; that
gap is what you report.** Never "the contractor stole", never "this is
corruption". Three reasons, in order of importance:

1. It is usually not knowable from what a citizen can see.
2. A description can be verified by an inspecting officer; an accusation just
   starts a fight and gets the file closed.
3. It keeps the person filing the complaint out of a defamation argument.

There are tests enforcing this in `test/inspection_test.dart` and
`test/prices_test.dart`.

## 4. Review state is visible, not hidden

Content is `status: "review"` until a licensed civil engineer has checked it
against the cited source. Anything in review shows an amber
**ইঞ্জিনিয়ার যাচাই বাকি** badge. Never mark something `verified` to make the badge
go away. `docs/CONTENT_REVIEW.md` is generated from the packs — regenerate it
with `dart run tool/review_sheet.dart` after any content change.

## 5. Prices are bands with dates, never single numbers

Material prices in Bangladesh move week to week and by district. Ship a low–high
band, an `as_of` date the app displays, and a note on what moves it. The user can
always type today's local rate over the top.

## 6. Cross-country comparisons carry their caveats inline

Every benchmark needs a `comparability` field explaining why two countries'
figures may not mean the same thing. `year` is nullable on purpose: when the year
behind a published figure has not been confirmed, leave it null so the app says
"সাল নিশ্চিত নয়" rather than implying the figures are contemporaneous. The caveats
render next to the numbers, never behind a tap.

## 7. Bangla is the authoring language

Write Bangla first; English is a translation of it. In the Bangla:

- Open with a hook the reader recognises, not a definition.
- Address the reader directly (আপনি / আপনার).
- Prefer colloquial verbs (মেপে দেখুন, গুনে নিন, ঠুকে দেখুন).
- Keep technical English nouns transliterated: কংক্রিট, স্ল্যাব, কিউরিং, কভার ব্লক,
  ল্যাপ, সাব-বেজ.
- Every "কী দেখবেন" bullet gets one concrete sentence with a real number or a
  real action in it.

`test/content_test.dart` fails the build if any string is missing its English.

## 8. Claim edit-pass before anything is published

Applies to the Play listing, the landing page and any campaign copy:

- Never sell on the word free. Use **কোনো পেওয়াল নেই**, not "১০০% ফ্রি".
- No superlatives: নিখুঁত, সেরা, সবচেয়ে.
- Never say a check "works". Say what it detects and what it cannot.
- Never call a descriptive figure a rating.
