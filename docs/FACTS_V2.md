# FACTS_V2 — the extraction sheet v2 content is written from

**Generated 2026-09-02.** Phase 1 of the plan at
`~/.claude/plans/i-want-to-create-starry-firefly.md`. Nothing in v2 gets written until the number
it rests on appears here with a verdict.

## Why this file exists

The app's whole claim is that a number it shows can be checked. That only holds if somebody
checked it first. Two sources feed v2 — a 2019 Bangla construction book and a Directorate General
of Food type design — and neither is an authority the app can cite. This sheet is where each of
their numbers is set against something that *is*: the published PWD Schedule of Rates that ships
in this repo, the app's own existing content, or plain arithmetic.

**659 facts extracted. Every one judged.**

<sub>670 were pulled in total; 11 were the same fact read twice, because two readers both covered the services chapter. Every duplicate pair agreed on the value — the only differences were formatting ("15-16" against "15 to 16") — so they are merged rather than dropped.</sub>

| Verdict | Count | What it means for a card |
|---|---:|---|
| ✅ verified | 187 | Corroborated against a source named in the row. Ships with that citation. |
| 🟠 review | 288 | Plausible and worth shipping, but nothing in this repo corroborates it. Ships with the amber "an engineer has not checked this" badge. This is the honest default, not a failure. |
| 📐 rule of thumb | 102 | An estimator's shortcut. Ships only inside a card that says on its face it is for checking a number someone quoted you, never for deciding one. |
| ⛔ rejected | 82 | Does not ship. Reasons in §C. |

### What "verified" actually rested on

| Checked against | Count |
|---|---:|
| Plain arithmetic — unit conversions and geometry, which either come out or do not | 133 |
| The PWD Schedule of Rates shipped in this repo, quoting the item code | 51 |
| Other named source | 3 |

**No row is verified against BNBC 2020**, because the code is not in this repo and could not be
opened. Anything resting on it is `review` and carries the amber badge — which is the point of
having the badge. When a reviewer with the code signs a row off, it moves.

**Scope** is separate from verdict. A godown gangway width read off a real drawing is *verified* —
it was checked — but its scope is one type design, not the country. The সূত্র tap prints both.

## The copyright line, restated

Facts only. No sentence of the book's prose is translated, paraphrased or carried across. Cards
are written from this sheet with the book closed. No scan and no drawing sheet is reproduced;
every diagram is redrawn from the verified value in this sheet.

---

## Summary — what the checking actually turned up

**89 facts contradict either the shipped PWD schedule or content the app already ships.**
Those are in §D and each needs a decision before the matching card is written. The most consequential
group is sand fineness: the book assigns F.M. 1.05 to plaster and 1.50 to masonry mortar, where every
plaster and mortar item in the shipped schedule specifies **F.M. 1.2**. Publishing the book's figures
would have taught readers to reject the sand the schedule actually requires.

**34 facts are places the book contradicts itself** — the same quantity given twice with different
values. Those are listed in §E. None of them ship until one value is settled against a real source.

The app currently ships **no** sand fineness values and **no** brick dimensions, so both of the
above were caught before anything reached a reader. That is what this phase is for.

---

## A. Facts from the book, by topic

### curing (32)

<sub>🟠 review 30 · 📐 rule of thumb 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Hours after casting before curing starts for mass concrete foundation (1:3:6) | **20 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | The shipped PWD schedule prices curing compound but contains no curing-timing table at all, so the 20-hour start cannot be corr… |
| Days of curing for mass concrete foundation (1:3:6) | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫]; মান: BNBC 2020 পার্ট ৭ (কিউরিং) — প্রকৌশলী যাচাই করেননি | Seven days is the commonly quoted minimum wet-curing period, but nothing in the shipped SoR or app content states it, so it shi… |
| Hours after work before curing starts for all brick masonry | **20 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | No corroborating source in the repo; masonry curing timing appears nowhere in the SoR or the shipped guide. |
| Days of curing for all brick masonry | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] ও প্রশ্নোত্তর ৪৯ — প্রকৌশলী যাচাই করেননি | The Q&A section (Q49) independently gives 7 days for brick walls, so this is corroborated. |
| Hours after casting before curing starts for damp-proof course concrete | **20 hours** | 🟠 review | PWD SoR 2022 item 03.6.1 — damp proof course (1:1.5:3) | The row labels DPC as (1:2:4) here, while the mix table [১২-৪] gives DPC as 1:1.5:3. |
| Days of curing for damp-proof course concrete | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Seven days for DPC concrete is plausible and consistent with the table's other 1:x:y rows, but no source in the repo confirms it. |
| Hours after casting before curing starts for lintels and sunshades | **20 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | No corroborating source here; the 20-hour figure is internally consistent with the rest of the table but otherwise unchecked. |
| Days of curing for lintels and sunshades | **28 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫]; মান: BNBC 2020 পার্ট ৭ — প্রকৌশলী যাচাই করেননি | Twenty-eight days for reinforced members is on the conservative side, so it is safe to show, but I could not corroborate it fro… |
| Hours after casting before curing starts for roof slab casting | **20 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] (২০ ঘণ্টা) — অন্যত্র বইটি ২৪ ঘণ্টা বলে; প্রকৌশলী যাচাই করেননি | Other passages in the book say curing begins 24 hours after casting; the table says 20. Unresolved conflict. |
| Days of curing for roof slab casting | **28 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] ও প্রশ্নোত্তর ৪৯; মান: BNBC 2020 পার্ট ৭ — প্রকৌশলী যাচাই … | The Q&A section (Q49) gives at least 28 days for RCC work generally, which agrees. |
| Hours after casting before curing starts for floor concrete casting (1:3:6) | **20 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] (২০ ঘণ্টা) — অধ্যায় ১৩-এ ১৮ ঘণ্টা; প্রকৌশলী যাচাই করেননি | The chapter 13 floor method text instead says 18 hours; and the duplicate curing table in chapter 2 labels this row (1:2:4) rat… |
| Days of curing for floor concrete casting (1:3:6) | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] ও অধ্যায় ১৩ — প্রকৌশলী যাচাই করেননি | The chapter 13 floor text says 1 week, which is the same duration. |
| Hours after casting before curing starts for 1-inch patent stone concrete (1:2:4) | **15 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | The shortest start delay in the table apart from mosaic work; 15 is legible and repeated in the duplicate chapter 2 table. |
| Days of curing for 1-inch patent stone concrete (1:2:4) | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] ও অধ্যায় ১৩ — প্রকৌশলী যাচাই করেননি | The chapter 13 patent-stone method text also says 7 days. |
| Hours after work before curing starts for all plaster work | **20 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | No source in the repo gives a plaster curing start time; the app's existing plaster card deliberately says to check the departm… |
| Days of curing for all plaster work | **7 days** | 🟠 review | Shipped assets/content/checklists/building.json item b14 requires post-plaster watering, without a duration | The Q&A section (Q49) also gives 7 days for plastering. |
| Hours after work before curing starts for mosaic floor | **12 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Book-only figure; the shipped SoR mosaic chapter says nothing about curing timing. |
| Days of curing for mosaic floor | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Seven days is consistent with the rest of the table's non-RCC rows but is uncorroborated outside the book. |
| Hours after work before curing starts for mosaic skirting | **12 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Printed "স্কাটিং" (OCR of skirting). |
| Days of curing for mosaic skirting | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Uncorroborated outside the book, though consistent with every other skirting and finish row in the same table. |
| Hours after work before curing starts for neat-cement skirting | **12 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Book-only figure with no external corroboration available in this repo. |
| Days of curing for neat-cement skirting | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Uncorroborated outside the book; low consequence if wrong, since skirting is a finish, not structure. |
| Hours after work before curing starts for jolchhad (lime terracing) | **24 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Book-only figure; PWD's lime-terracing item gives thickness and materials but no curing regime. |
| Days of curing for jolchhad (lime terracing) | **16 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | The longest curing period in the table after the 28-day RCC items; 16 is legible and repeated in the duplicate chapter 2 table. |
| Minimum curing period recommended for RCC work | **28 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, প্রশ্নোত্তর ৪৯; মান: BNBC 2020 পার্ট ৭ — প্রকৌশলী যাচাই করেননি | Stated as a minimum for good results; agrees with the 28-day roof and lintel rows of [১২-৫]. |
| Curing period for brick walls | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, প্রশ্নোত্তর ৪৯ — প্রকৌশলী যাচাই করেননি | Printed with Western digits in the source. |
| Curing period for plastering | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, প্রশ্নোত্তর ৪৯ — প্রকৌশলী যাচাই করেননি | Printed with Western digits in the source. |
| Hours after floor casting before ponded curing starts | **18 hours** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ (মেঝে ঢালাই) — সারণি [১২-৫] বলে ২০ ঘণ্টা; প্রকৌশলী যাচাই করেননি | Conflicts with the 20 hours given for floor casting in [১২-৫]. Method described is ponding water within a temporary kerb. |
| Curing duration for floor casting stated in the floor method text | **7 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ ও সারণি [১২-৫] — প্রকৌশলী যাচাই করেননি | Printed as 1 week; equals the 7 days in [১২-৫]. |
| Time after casting before water curing may begin | **24 hours** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০]। ইঞ্জিনিয়ার যাচাই করেননি — ২৪ ঘণ্টা মানে পানি জমানো শু… | Plausible as the point at which ponding water can be put on without damaging the surface, but read as "do nothing for 24 hours"… |
| Times per day water should be applied during curing | **3-4 times per day** | 📐 rule of thumb | Shipped guide.json card m4c5 already teaches the correct test — the surface or hessian must stay wet — rath… | A practice guideline, not a specification; no duration or weather qualification is given. |
| Hours after casting before curing starts, stated generally for concrete casting | **24 hours** | 📐 rule of thumb | Book's own table [১২-৫] gives 12/15/20 hours by item; shipped guide.json card m4c4 already says curing star… | This general 24-hour figure conflicts with the 12/15/20-hour item-specific values in the curing table [১২-৫]. The table is the … |

### reservoir design (26)

<sub>🟠 review 21 · ✅ verified 5</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Fraction of wall height (from the base up) that must be cast in the same pour as the base | **0.333 fraction of wall height** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০]। বেসের সঙ্গে দেয়ালের নীচের এক-তৃতীয়াংশ একদিনে ঢাললে জ… | One third of the wall height. |
| Wall thickness for a 6ft x 4ft x 4ft reservoir | **4 inches** | 🟠 review | arithmetic (4 in = 101.6 mm; two 9.5 mm bar layers = 19 mm, leaving about 41 mm to split between two faces … | A 4 in (102 mm) wall is tight for a water-retaining structure with bars on both faces — two 3/8 in layers plus binders leaves o… |
| Vertical reinforcement (both faces) for a 6ft x 4ft x 4ft reservoir | **0.375 @ 4 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। নকশার সঙ্গে মিলিয়ে দেখার জন্য — নকশার বদলে নয়। ইঞ… | 3/8 inch bar at 4 inch centre-to-centre spacing. |
| Binder reinforcement for a 6ft x 4ft x 4ft reservoir | **0.375 @ 9 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible binder spacing, but uncorroborated structural detailing. |
| Diagonal reinforcement for a 6ft x 4ft x 4ft reservoir | **0.375 @ 8 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Wall thickness for an 8ft x 4ft x 5ft reservoir | **5 inches** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | 5 in gives more room for cover than the 4 in row and is plausible for this size, but it is uncorroborated design output. |
| Vertical reinforcement (both faces) for an 8ft x 4ft x 5ft reservoir | **0.5 @ 6 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। নকশার সঙ্গে মিলিয়ে দেখার জন্য। ইঞ্জিনিয়ার যাচাই ক… | Readable and consistent with the table's progression (heavier bar as the tank grows), but uncorroborated structural detailing. |
| Binder reinforcement for an 8ft x 4ft x 5ft reservoir | **0.375 @ 9 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Diagonal reinforcement for an 8ft x 4ft x 5ft reservoir | **0.5 @ 12 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Wall thickness for an 8ft x 6ft x 5ft reservoir | **5 inches** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Plausible for the size and consistent with the table, but uncorroborated design output. |
| Vertical reinforcement (both faces) for an 8ft x 6ft x 5ft reservoir | **0.5 @ 5 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and consistent with the table's progression, but uncorroborated structural detailing. |
| Binder reinforcement for an 8ft x 6ft x 5ft reservoir | **0.375 @ 7 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Diagonal reinforcement for an 8ft x 6ft x 5ft reservoir | **0.5 @ 10 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Wall thickness for a 10ft x 6ft x 5ft reservoir | **6 inches** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | 6 in for the largest tanks in the table is a sensible progression, but uncorroborated design output. |
| Vertical reinforcement (both faces) for a 10ft x 6ft x 5ft reservoir | **0.5 @ 4 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and consistent with the table, but uncorroborated structural detailing. |
| Binder reinforcement for a 10ft x 6ft x 5ft reservoir | **0.375 @ 7 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Diagonal reinforcement for a 10ft x 6ft x 5ft reservoir | **0.5 @ 8 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Wall thickness for a 10ft x 6ft x 6ft reservoir | **6 inches** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Consistent with the row above it and plausible for the size, but uncorroborated design output. |
| Vertical reinforcement (both faces) for a 10ft x 6ft x 6ft reservoir | **0.5 @ 4 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and consistent with the table, but uncorroborated structural detailing. |
| Binder reinforcement for a 10ft x 6ft x 6ft reservoir | **0.375 @ 6 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, and it tightens with depth as expected, but uncorroborated structural detailing. |
| Diagonal reinforcement for a 10ft x 6ft x 6ft reservoir | **0.5 @ 8 inch bar @ inch centres** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০](৮)। ইঞ্জিনিয়ার যাচাই করেননি। | Readable and plausible, but uncorroborated structural detailing. |
| Capacity of a 6ft x 4ft x 4ft reservoir | **600 gallons** | ✅ verified | arithmetic (96 cft / 0.16054 cft per imperial gallon = 598 gallons) | The geometry checks out exactly: 6 x 4 x 4 ft is 96 cft, which is 598 imperial gallons, so the printed 600 is right to within r… |
| Capacity of an 8ft x 4ft x 5ft reservoir | **1000 gallons** | ✅ verified | arithmetic (160 cft = 997 imperial gallons) | 8 x 4 x 5 ft is 160 cft, which is 997 imperial gallons, so the printed 1,000 is correct. |
| Capacity of an 8ft x 6ft x 5ft reservoir | **1500 gallons** | ✅ verified | arithmetic (240 cft = 1,495 imperial gallons) | 8 x 6 x 5 ft is 240 cft, which is 1,495 imperial gallons, matching the printed 1,500. |
| Capacity of a 10ft x 6ft x 5ft reservoir | **1900 gallons** | ✅ verified | arithmetic (300 cft = 1,869 imperial gallons, rounded to 1,900) | 10 x 6 x 5 ft is 300 cft, which is 1,869 imperial gallons; the printed 1,900 is that rounded up, so the row is consistent. |
| Capacity of a 10ft x 6ft x 6ft reservoir | **2250 gallons** | ✅ verified | arithmetic (360 cft = 2,242 imperial gallons) | 10 x 6 x 6 ft is 360 cft, which is 2,242 imperial gallons, matching the printed 2,250. |

### concrete mix ratio (19)

<sub>✅ verified 7 · 🟠 review 6 · 📐 rule of thumb 4 · ⛔ rejected 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| DPC casting ratio quoted in the thumb-rule section | **1:2:4** | ⛔ rejected | PWD SoR 2022 items 03.6.1 and 03.6.2 — damp proof course (1:1.5:3) | Conflicts with [১২-৪], which gives DPC as 1:1.5:3; agrees with the DPC label in the curing table [১২-৫]. |
| Casting ratio restated in the chapter 13 casting caution, with the component order printed as cement : khoa :  | **1:2:4** | ⛔ rejected | PWD SoR 2022 items 03.5.1, 04.26 and 03.4.1 all state the order cement : sand : chips | The component order here (cement : khoa : sand) contradicts every mix table in the book, which uses cement : sand : khoa. Almos… |
| Cement : sand : khoa ratio for the concrete base under mosaic flooring | **1:2:4** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-৪] — প্রকৌশলী যাচাই করেননি | The shipped SoR mosaic rows do not describe the base concrete under the mosaic, so 1:2:4 is plausible but uncorroborated here. |
| Cement : sand : khoa ratio for the mix fixing grille frames | **1:2:4** | 🟠 review | Nearest analogue only: PWD SoR 2022 item 32.68 — "F.I. Clamp in CC (1:2:4)" | None of PWD's window/verandah grille items state a bedding mix; the only nearby figure is the generic F.I. clamp item at 1:2:4,… |
| Cement : sand : khoa ratio for concrete around sanitary pipes | **1:3:6** | 🟠 review | Nearest reference only: PWD SoR 2022 item 27.3.8 — "sanitary seal of 1:2:4 (Cement: 1.2 FM sand: 20 [mm chi… | The shipped sanitary chapter never states a surround-concrete ratio, and the one nearby PWD figure — the tube-well sanitary sea… |
| Cement : sand : khoa ratio for the concrete base of a drain pit | **1:3:6** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-৪] — প্রকৌশলী যাচাই করেননি | No PWD drain-pit item in the shipped schedule states a base concrete ratio, so 1:3:6 rests on the book. |
| Cement : sand : khoa ratio for septic tank concrete | **1:2:4** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-৪] — প্রকৌশলী যাচাই করেননি | PWD's septic-tank items in the shipped schedule cover brickwork, plaster and cleaning but never a concrete mix, so 1:2:4 is pla… |
| Cement : sand : khoa ratio for the septic tank roof slab | **1:2:4** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-৪] — প্রকৌশলী যাচাই করেননি | A septic-tank cover slab is a reinforced structural element whose concrete should be specified by strength, and no shipped PWD … |
| Cement : sand : khoa ratio for RCC concrete of 2600 psi strength | **1:2:4** | 📐 rule of thumb | PWD SoR 2022 items 07.7.1 and 07.8.1 — RCC works priced by "minimum cement content relates to" an approved … | A nominal volumetric mix presented as delivering the stated strength; it is not a designed mix and no cylinder-test basis is gi… |
| Cement : sand : khoa ratio for RCC concrete of 2900 psi strength | **1:1.5:3** | 📐 rule of thumb | PWD SoR 2022 items 07.7.1–07.7.4 and 07.8.1–07.8.4 — RCC priced by approved strength class with minimum cem… | Nominal volumetric mix, not a designed mix. |
| RCC casting ratio quoted in the thumb-rule section (lower-strength option) | **1:2:4** | 📐 rule of thumb | PWD SoR 2022 items 07.7.1 / 07.8.1 (RCC priced by strength class and minimum cement content); shipped guide… | Corresponds to the 2600 psi row of [১২-৪]. |
| RCC casting ratio quoted in the thumb-rule section (higher-strength option) | **1:1.5:3** | 📐 rule of thumb | PWD SoR 2022 items 07.7.x / 07.8.x (strength class and minimum cement content, no volumetric ratio) | Corresponds to the 2900 psi row of [১২-৪]. |
| Cement : sand : khoa ratio for mass concrete under the foundation | **1:3:6** | ✅ verified | PWD SoR 2022 item 03.4.1 — "Lean/ blinding concrete in foundation (1:3:6) with cement, brick chips and sand… | PWD prices 1:3:6 concrete in the foundation, but calls it lean/blinding concrete and reserves the name "mass concrete" for a ri… |
| Cement : sand : khoa ratio for damp-proof course (DPC) | **1:1.5:3** | ✅ verified | PWD SoR 2022 items 03.6.1 ("75 mm thick damp proof course (1:1.5:3) with cement, Sylhet sand (F.M. 2.2) and… | Conflicts with the book itself: the curing table [১২-৫] and the chapter 3 thumb rule both describe DPC as 1:2:4. Unresolved — f… |
| Cement : sand : khoa ratio for house ground-floor concrete | **1:3:6** | ✅ verified | PWD SoR 2022 items 04.25 ("75 mm thick cement concrete (1:3:6) flooring ... 19 mm downgraded [chips]") and … | Matches the chapter 13 floor description of 3-inch thick 1:3:6 floor casting. |
| Cement : sand : khoa ratio for patent stone floor finish | **1:2:4** | ✅ verified | PWD SoR 2022 items 04.26, 04.27, 04.28, 04.29 — "25/38 mm thick artificial patent stone (1:2:4) flooring" | Four PWD patent-stone flooring items use 1:2:4, exactly as the book states. |
| Cement : sand : khoa ratio for the mix fixing door and window frames into walls | **1:2:4** | ✅ verified | PWD SoR 2022 items 32.68 and 32.69 — "Renewing, supplying and fitting-fixing of 300 mm / 150 mm long F.I. C… | PWD embeds the flat-iron clamps that anchor door and window frames into walls in exactly this 1:2:4 concrete. |
| Cement concrete (CC) casting ratio quoted in the thumb-rule section | **1:3:6** | ✅ verified | PWD SoR 2022 items 03.4.1, 03.4.2 (lean/blinding concrete 1:3:6) and 04.25 (75 mm floor concrete 1:3:6) | Consistent with the mass concrete and ground floor rows of [১২-৪]. |
| Patent stone floor ratio quoted in the thumb-rule section | **1:2:4** | ✅ verified | PWD SoR 2022 items 04.26–04.29 — "artificial patent stone (1:2:4) flooring" | Consistent with [১২-৪]. |

### room size (19)

<sub>🟠 review 17 · ⛔ rejected 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| dining room, standard size | **11 × 12 ft** | ⛔ rejected | arithmetic (11' = 3.35 m, not the 3.08 m printed; 10' = 3.048 m, which the book prints as 3.08 elsewhere) | 11 ft is 3.35 m, but 3.08 m is printed; the two unit columns disagree for this row. |
| bathroom, normal size | **5.83 × 4 ft** | ⛔ rejected | arithmetic (2.13 m = 7.0 ft and 1.52 m = 5.0 ft, against the printed 5'-10" × 4'-0") | Odd that the 'normal' bathroom is longer in one direction than the 'standard' one; the two rows are not a simple size ordering. |
| drawing room, standard size | **13.5 × 13 ft** | 🟠 review | arithmetic (13'-6" = 4.115 m against 4.2 m printed) | Metric equivalent printed as 4.2 × 4.0 m. The table gives the same figures for this room's standard and normal size. |
| drawing room, normal size | **13.5 × 13 ft** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [৬-৪] ষষ্ঠ অধ্যায় — টেবিলে স্ট্যান্ডার্ড ও সাধারণ মাপ একই ছাপা। | Identical to the standard size in the printed table — possibly a printing repetition rather than two distinct values. |
| combined drawing-dining room, standard size | **17 × 15.5 ft** | 🟠 review | arithmetic (17' = 5.18 m, 15'-6" = 4.72 m against 5.2 × 4.8 printed) | Book recommendation with the foot and metre columns agreeing within an inch, but no code or repo source behind it. |
| combined drawing-dining room, normal size | **13.5 × 13 ft** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [৬-৪] ষষ্ঠ অধ্যায় — বইয়ের পরামর্শ, বাধ্যতামূলক মাপ নয়। | Book recommendation only; note it is the same 13'-6" × 13'-0" the table gives for a drawing room alone, so a combined room at t… |
| bedroom, standard size | **13 × 15.5 ft** | 🟠 review | arithmetic (13'-0" = 3.96 m against 4.2 m printed) | 13 ft is 3.96 m, but the table prints 4.2 m; the foot and metre columns do not agree exactly for this row. |
| bedroom, normal size | **10 × 13.5 ft** | 🟠 review | arithmetic (10' = 3.048 m, 13'-6" = 4.115 m against 3.04 × 4.2 printed) | Foot and metre columns agree to within an inch here (10' = 3.048 m against 3.04 printed), but it remains the book's recommendat… |
| dining room, normal size | **10 × 10 ft** | 🟠 review | arithmetic (10' = 3.048 m against 3.08 / 3.05 printed) | Both columns agree (10' = 3.048 m against 3.08 and 3.05 printed), but it is a book recommendation with no code behind it. |
| kitchen, standard size | **9.83 × 9.83 ft** | 🟠 review | arithmetic (9'-10" = 2.997 m against 3.0 m printed) | The columns match closely (9'-10" = 2.997 m against 3.0 printed) but the size is the book's recommendation, not a ventilation o… |
| kitchen, normal size | **8 × 9.83 ft** | 🟠 review | arithmetic (8'-0" = 2.44 m against 2.5 m printed) | 8'-0" is 2.44 m against the 2.5 m printed, close enough to read confidently, but it remains an uncorroborated recommendation. |
| study room, standard size | **10 × 11.75 ft** | 🟠 review | arithmetic (10' = 3.048 m, 11'-9" = 3.58 m against 3.0 × 3.6 printed) | The table prints the same figures for standard and normal size. |
| guest room, standard size | **10 × 11.75 ft** | 🟠 review | arithmetic (10' = 3.048 m, 11'-9" = 3.58 m against 3.0 × 3.6 printed) | No normal size given for this room. |
| dressing room, standard size | **8 × 7 ft** | 🟠 review | arithmetic (1.8 m = 5.9 ft, 2.5 m = 8.2 ft against the printed 8' × 7') | The metric pair 1.8 × 2.5 m is the reverse order of the foot pair (8 ft ≈ 2.5 m, 7 ft ≈ 2.1 m), so the metric column is roughly… |
| store / pantry room, standard size | **8 × 9.83 ft** | 🟠 review | arithmetic (8' = 2.44 m, 9'-10" = 3.0 m against 2.5 × 3.0 printed) | Columns agree within an inch and the size is readable, but it is the book's recommendation rather than any standard. |
| bathroom, standard size | **5 × 7 ft** | 🟠 review | arithmetic (1.8 m = 5.9 ft, 2.5 m = 8.2 ft against the printed 5' × 7') | 5' × 7' is a normal small bathroom and the metric pair (1.8 × 2.5 m = 5.9' × 8.2') is roughly consistent, but nothing in the re… |
| veranda width, standard | **8 ft** | 🟠 review | arithmetic (8' = 2.44 m against 2.5 m printed) | Width only; no length given. |
| veranda width, normal | **5 ft** | 🟠 review | arithmetic (5' = 1.52 m against 1.8 m printed) | 5' = 1.52 m against the 1.8 m printed, a quarter-metre apart, so show the foot figure and treat the metric column as loose. |
| stair enclosure / roof stair room, standard size | **7 × 16 ft** | 🟠 review | arithmetic (7' = 2.134 m, 16' = 4.877 m against 2.13 × 4.9 printed) | Columns agree (7' = 2.13 m, 16' = 4.88 m against 2.13 × 4.9 printed), but stair-enclosure size is driven by the flight geometry… |

### geometry formula (17)

<sub>✅ verified 15 · ⛔ rejected 1 · 📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| area of a semi-parabolic curve/cone | **(2/3) × base × height** | ⛔ rejected | সূত্রটি বইয়ে ব্যাখ্যা করা নেই — বাদ দেওয়া হয়েছে | Printed with the same expression as the parabola item; the distinction between the two items is not explained in the source. |
| approximate length of a circular arc (b = chord of half the arc, 2a = span) | **(8b - 2a) / 3** | 📐 rule of thumb | arithmetic (Huygens' arc-length approximation) | This is Huygens' approximation for arc length, not an exact formula; the book presents it without stating it is approximate. |
| area of a rectangle | **length × width** | ✅ verified | arithmetic (elementary geometry); used in lib/features/calculators/logic/plaster.dart and brickwork.dart | Standard Euclidean result, and it is the formula behind every area input in the app's own calculators. |
| area of a triangle | **1/2 × base × height** | ✅ verified | arithmetic (elementary geometry) | Standard Euclidean result; half the base times the perpendicular height. |
| area of a square | **side × side** | ✅ verified | arithmetic (elementary geometry) | Standard Euclidean result; a square is a rectangle with equal sides. |
| area of a rhombus from its two diagonals d1 and d2 | **1/2 × d1 × d2** | ✅ verified | arithmetic (elementary geometry) | Standard result for a quadrilateral with perpendicular diagonals: half the product of the diagonals. |
| area of a trapezium | **1/2 × (sum of the two parallel sides) × perpendicular distance between them** | ✅ verified | arithmetic (elementary geometry) | Standard Euclidean result; the book's bracketing is loose but the quantity is right — half the sum of the parallel sides times … |
| area of a circle (D = diameter, r = radius) | **(pi/4) × D^2 = pi × r^2** | ✅ verified | arithmetic (elementary geometry); the same πd²/4 term drives lib/features/calculators/logic/rebar.dart | πD²/4 and πr² are the same quantity since D = 2r; both forms are correct and the πD²/4 form is the one used for rod and pipe se… |
| circumference of a circle (D = diameter) | **pi × D** | ✅ verified | arithmetic (elementary geometry) | Standard result; circumference is π times the diameter. |
| volume of a rectangular solid | **length × width × height** | ✅ verified | arithmetic (elementary geometry); lib/features/calculators/logic/brickwork.dart | Standard result, and the exact method the app's concrete and brickwork calculators use to turn dimensions into cft. |
| volume of a cylinder (r = radius, h = height) | **pi × r^2 × h** | ✅ verified | arithmetic (elementary geometry) | The book's gloss of the symbols is garbled: it defines h as 'বৃত্তের ব্যাসার্ধ' (radius of the circle). h is the height; the it… |
| volume of a cone (r = radius, h = height) | **(1/3) × pi × r^2 × h** | ✅ verified | arithmetic (elementary geometry) | Standard result; a cone is one third of the cylinder on the same base and height. |
| volume of a sphere (r = radius) | **(4/3) × pi × r^3** | ✅ verified | arithmetic (elementary geometry) | Standard result for the volume of a sphere. |
| volume of a pyramid | **(1/3) × base area × height** | ✅ verified | arithmetic (elementary geometry) | Standard result; one third of base area times height, valid for any base shape. |
| curved surface area of a cylinder (r = radius, h = height) | **2 × pi × r × h** | ✅ verified | arithmetic (elementary geometry) | 2πrh is the correct lateral surface area — the figure you need for plastering or painting a round column. |
| area of a parabolic segment | **(2/3) × base × height** | ✅ verified | arithmetic (Archimedes, quadrature of the parabola) | Archimedes' result: a parabolic segment is exactly two thirds of the enclosing rectangle on the same base and height. |
| area of an ellipse (a = half the major axis, b = half the minor axis) | **pi × a × b** | ✅ verified | arithmetic (elementary geometry) | πab is correct where a and b are the semi-major and semi-minor axes, exactly as the book glosses them. |

### land and area units (15)

<sub>✅ verified 15</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one square foot in square inches | **144 sq inch** | ✅ verified | arithmetic | 12 × 12 = 144 square inches in a square foot, exactly as printed. |
| one square yard in square feet | **9 sq ft** | ✅ verified | arithmetic | 3 × 3 = 9 square feet in a square yard, exactly as printed. |
| one chatak (ছটাক) in square feet | **45 sq ft** | ✅ verified | arithmetic (720 ÷ 16 = 45; cross-checks against area-katha-to-sqft and area-acre-to-katha) | The illustrative square 7'x7' is 49 sq ft, not 45; the book's side lengths in this table are rounded illustrations, not exact e… |
| one decimal / shotangsho in square feet | **435.6 sq ft** | ✅ verified | arithmetic (43,560 ÷ 100 = 435.6) | Exact (43,560 / 100). The illustrative 21'x21' = 441 sq ft is approximate. |
| one katha in square feet | **720 sq ft** | ✅ verified | arithmetic (60.5 × 720 = 43,560 = 1 acre) | Illustrative 27'x27' = 729 sq ft is approximate. |
| one bigha in square feet | **14400 sq ft** | ✅ verified | arithmetic (20 × 720 = 14,400 = 120 × 120) | Exactly 20 katha; the illustrative 120'x120' is exact here. |
| one acre in square yards | **4840 sq yard** | ✅ verified | arithmetic | An acre is 4840 square yards by definition (43,560 ÷ 9). |
| one acre in bighas | **3.025 bigha** | ✅ verified | arithmetic (43,560 ÷ 14,400 = 3.025; 0.025 × 20 katha × 16 = 8 chatak) | Also written in the same cell as '৩ বিঘা ৮ ছটাক' (3 bigha 8 chatak). |
| one acre in kathas | **60.5 katha** | ✅ verified | arithmetic | Consistent: 60.5 x 720 = 43,560 sq ft. |
| one acre in decimals (shotangsho) | **100 decimal** | ✅ verified | arithmetic (definition) | The decimal (shotangsho) is defined as one hundredth of an acre, so 100 per acre is exact. |
| one square mile in square feet | **27878400 sq ft** | ✅ verified | arithmetic | 5280² = 27,878,400 square feet in a square mile, exactly as printed. |
| one square mile in square yards | **3097600 sq yard** | ✅ verified | arithmetic | 27,878,400 ÷ 9 = 3,097,600 square yards, exactly as printed. |
| one square kilometre in square metres | **1000000 sq m** | ✅ verified | arithmetic | 1000 m × 1000 m = 1,000,000 square metres by definition. |
| one square kilometre in square feet (rounded) | **10764000 sq ft** | ✅ verified | arithmetic (1,000,000 × 10.76391) | Rounded version of the 10,763,867.36 sq ft printed in [৩-২]. |
| one square kilometre in hectares | **100 hectare** | ✅ verified | arithmetic | 1,000,000 m² ÷ 10,000 = 100 hectares exactly. |

### septic tank (15)

<sub>🟠 review 10 · ⛔ rejected 5</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Septic tank size (L x W x depth) for 100 users, as given in the thumb-rules appendix | **11x?x4.5 ft** | ⛔ rejected |  | OCR damaged and it CONFLICTS with the book's own Table (১১-১), which gives 100 users as 11'-0" x 6'-0" x 5'-10". The width "৪-২… |
| Septic tank size (L x W x depth) for 250 users, as given in the thumb-rules appendix | **21x6x7.17 ft** | ⛔ rejected | PWD SoR 2022 items 32.87.1-32.87.6 give brackets of 10, 20, 30, 50, 100 and 200 users — there is no 250-use… | Uncertain and CONFLICTING. The depth "৭-২'" is almost certainly 7 ft 2 in. Chapter 11 Table (১১-১) has no 250-user row; it has … |
| septic tank length, width and depth for 100 users | **11 × 6 × 5.83 ft** | ⛔ rejected | arithmetic (11 × 6 × 5.83 = 385 cft against the appendix's 11 × 4.17 × 4.5 = 206 cft); PWD SoR 2022 item 32… | Conflicts with the appendix, which gives 11' × 4'-2" × 4.5' for 100 users. The two figures cannot both be right; the book does … |
| septic tank size for 100 users as given in the appendix | **11 × 4.17 × 4.5 ft (L × W × D)** | ⛔ rejected | arithmetic (11 × 4.17 × 4.5 = 206 cft against টেবিল ১১-১'s 11 × 6 × 5.83 = 385 cft); PWD SoR 2022 item 32.8… | Width printed as '৪-২'', read as 4 ft 2 in. This contradicts টেবিল (১১-১), which gives 11' × 6' × 5'-10" for the same 100 users… |
| septic tank size for 250 users as given in the appendix | **21 × 6 × 7.17 ft (L × W × D)** | ⛔ rejected | PWD SoR 2022 items 32.87.1 to 32.87.6 — '10 / 20 / 30 / 50 / 100 / 200 user septic tank'; arithmetic 21 × 6… | Depth printed as '৭-২'', read as 7 ft 2 in. টেবিল (১১-১) gives nearly the same tank (22' × 6' × 7'-2") but for 200 users, not 2… |
| Septic tank size (L x W x depth) for 10 users | **6x2x3.5 ft** | 🟠 review | PWD SoR 2022 item 32.87.1 "10 user septic tank" (confirms the bracket, not the size); arithmetic: 6 x 2 x 3… | Matches Table (১১-১) in chapter 11, where it is printed as 6'-0" x 2'-0" x 3'-6". |
| Septic tank size (L x W x depth) for 30 users | **9x2x4.5 ft** | 🟠 review | arithmetic (9 x 2 x 4.5 = 81 cft = 2.29 cum, 0.076 cum per user, versus 0.109-0.134 for the other rows); PW… | Matches Table (১১-১): 9'-0" x 2'-0" x 4'-6". |
| Septic tank size (L x W x depth) for 10 users, chapter 11 table | **6x2x3.5 ft** | 🟠 review | PWD SoR 2022 item 32.87.1 "10 user septic tank" (bracket only); arithmetic: 42 cft = 1.19 cum, 0.119 cum pe… | OCR mangles the inch marks ("০৪" for 0"); read as 6'-0", 2'-0", 3'-6". Agrees with the thumb-rules appendix. |
| Septic tank size (L x W x depth) for 30 users, chapter 11 table | **9x2x4.5 ft** | 🟠 review | arithmetic (9 x 2 x 4.5 = 81 cft = 2.29 cum, 0.076 cum per user) | Agrees with the thumb-rules appendix. |
| Septic tank size (L x W x depth) for 100 users, chapter 11 table | **11x6x5.83 ft** | 🟠 review | arithmetic (11 x 6 x 5.83 = 385 cft = 10.9 cum, 0.109 cum per user, in line with the 10-user and 200-user r… | Depth is 5 ft 10 in. This CONFLICTS with the thumb-rules appendix entry for 100 users (depth 4.5 ft, width unreadable). Prefer … |
| Septic tank size (L x W x depth) for 200 users, chapter 11 table | **22x6x7.17 ft** | 🟠 review | PWD SoR 2022 item 32.87.6 "200 user septic tank" (bracket only); arithmetic: 22 x 6 x 7.17 = 946 cft = 26.8… | Depth is 7 ft 2 in. The appendix instead lists a 250-user tank at 21' x 6' x 7'-2" — the user count and length differ between t… |
| Number of chambers a septic tank is normally built with | **2-3 chambers** | 🟠 review | PWD SoR 2022 items 32.87.1-32.87.6 (septic tanks by user bracket) confirm the unit but not the chamber count | The book adds that a vent pipe connects to the first chamber. |
| septic tank length, width and depth for 10 users | **6 × 2 × 3.5 ft** | 🟠 review | PWD SoR 2022 item 32.87.1 — '10 user septic tank' | OCR damage: the first two cells read '৬'-০৪' and '২'-০৪', almost certainly 6'-0" and 2'-0" (the appendix repeats this row as 6 … |
| septic tank length, width and depth for 30 users | **9 × 2 × 4.5 ft** | 🟠 review | PWD SoR 2022 item 32.87.3 — '30 user septic tank' | Matches the appendix figure for 30 users. |
| septic tank length, width and depth for 200 users | **22 × 6 × 7.17 ft** | 🟠 review | PWD SoR 2022 item 32.87.6 — '200 user septic tank' | Opening bracket missing on the length cell (OCR). The appendix instead gives a 250-user row of 21' × 6' × 7'-2" — similar dimen… |

### labour rate (14)

<sub>⛔ rejected 14</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| daily rate for a head mason/tradesman (head rod, carpenter, painter, bitumen, plumber) | **600 BDT per day** | ⛔ rejected | ২০১৯ সালের মজুরি — বাদ দেওয়া হয়েছে; স্থানীয় বর্তমান হার জেনে নিন | STALE: a January 2019 daily wage in Bangladeshi taka. Construction wages in Bangladesh have risen substantially since; treat th… |
| daily rate for a tradesman (rod mason, carpenter, painter, bitumen mason, plumber) | **500 BDT per day** | ⛔ rejected | ২০১৯ সালের মজুরি — বাদ দেওয়া হয়েছে; স্থানীয় বর্তমান হার জেনে নিন | STALE: January 2019 taka wage. Re-check against current local rates before use. |
| daily rate for a skilled helper | **400 BDT per day** | ⛔ rejected | ২০১৯ সালের মজুরি — বাদ দেওয়া হয়েছে; স্থানীয় বর্তমান হার জেনে নিন | STALE: January 2019 taka wage. |
| daily rate for a skilled labourer | **300 BDT per day** | ⛔ rejected | ২০১৯ সালের মজুরি — বাদ দেওয়া হয়েছে; স্থানীয় বর্তমান হার জেনে নিন | STALE: January 2019 taka wage. The book gives skilled labour, ordinary labour and skilled technician all the same 300 taka, whi… |
| daily rate for a general labourer | **300 BDT per day** | ⛔ rejected | ২০১৯ সালের মজুরি — বাদ দেওয়া হয়েছে; স্থানীয় বর্তমান হার জেনে নিন | STALE: January 2019 taka wage. |
| daily rate for a skilled technician | **300 BDT per day** | ⛔ rejected | ২০১৯ সালের মজুরি এবং সারণিতে সম্ভাব্য ভুল — বাদ দেওয়া হয়েছে | STALE: January 2019 taka wage. Suspicious that a skilled technician is priced the same as a general labourer and below a helper… |
| daily rate for a foreman | **600 BDT per day** | ⛔ rejected | ২০১৯ সালের মজুরি — বাদ দেওয়া হয়েছে; স্থানীয় বর্তমান হার জেনে নিন | STALE: January 2019 taka wage; equal to the head tradesman rate. |
| Daily rate for a head mason-grade tradesman (head rod-fixer, head carpenter, head painter, head bitumen worker | **600 BDT per day** | ⛔ rejected |  | STALE: January 2019 daily wage. Bangladesh construction wages have risen well beyond this; do not show as current. |
| Daily rate for a tradesman (rod-fixer, carpenter, painter, bitumen worker, plumber) | **500 BDT per day** | ⛔ rejected |  | STALE: January 2019 daily wage. |
| Daily rate for a skilled helper | **400 BDT per day** | ⛔ rejected |  | STALE: January 2019 daily wage. |
| Daily rate for a skilled labourer | **300 BDT per day** | ⛔ rejected |  | STALE: January 2019 daily wage. |
| Daily rate for a general labourer | **300 BDT per day** | ⛔ rejected |  | STALE: January 2019 daily wage. |
| Daily rate for a skilled technician | **300 BDT per day** | ⛔ rejected |  | STALE: January 2019 daily wage. Note the book prices a skilled technician the same as a general labourer, which looks like a ta… |
| Daily rate for a foreman | **600 BDT per day** | ⛔ rejected |  | STALE: January 2019 daily wage. |

### unit conversion - area (13)

<sub>✅ verified 12 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one hectare stated in square metres in the land-measure row | **1000 sq m** | ⛔ rejected | arithmetic (100 m × 100 m = 10,000 m²) | PRINT/OCR ERROR — contradicts the correct 10,000 sq m given in the same table. Recorded only so the discrepancy is visible; do … |
| one acre expressed in square metres | **4046.86 sq m** | ✅ verified | arithmetic | 4840 sq yd × 0.83612736 m²/sq yd = 4046.856 m²; 4046.86 is a correct rounding. |
| one acre expressed in hectares | **0.4047 hectare** | ✅ verified | arithmetic | Printed twice in the table (area row and land-measure row). |
| one square metre expressed in square feet | **10.764 sq ft** | ✅ verified | arithmetic | 1 ÷ 0.3048² = 10.7639 sq ft; 10.764 is a correct rounding. |
| one hectare expressed in square metres | **10000 sq m** | ✅ verified | arithmetic (100 m × 100 m) | The book's later land-measure row prints '১ হেক্টর = ২.৪৭১ একর = ১০০০ বর্গমিটার', which contradicts this and is wrong by a fact… |
| one hectare expressed in square feet | **107638.7 sq ft** | ✅ verified | arithmetic | Table (৩-১) prints a slightly different rounding, ১,০৭,৬৩৬ বর্গফুট, for the same quantity. |
| one hectare expressed in acres | **2.471 acre** | ✅ verified | arithmetic | Printed three times (area row, land row, Table ৩-১). |
| one square mile expressed in hectares | **259 hectare** | ✅ verified | arithmetic | 640 acres × 0.4046856 ha = 258.999 ha; 259 is correct. |
| one square mile expressed in square kilometres | **2.590 sq km** | ✅ verified | arithmetic | 1.609344² = 2.58999 sq km; 2.590 is a correct rounding. |
| one square mile expressed in acres | **640 acre** | ✅ verified | arithmetic | Repeated in Table (৩-১). |
| one square kilometre expressed in square feet | **10763867.36 sq ft** | ✅ verified | arithmetic | Table (৩-১) gives the rounder ১,০৭,৬৪,০০০ বর্গ ফুট for the same quantity. |
| one square kilometre expressed in acres | **247.1045 acre** | ✅ verified | arithmetic | 100 hectares × 2.471054 = 247.1054 acre; the book's 247.1045 matches to four significant decimals. |
| one square kilometre expressed in square miles | **0.3861 sq mile** | ✅ verified | arithmetic | 1 ÷ 2.58999 = 0.386102 sq mile; 0.3861 is a correct rounding. |

### unit conversion - length (13)

<sub>✅ verified 12 · 📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one foot taken as a rounded site figure in millimetres | **300 mm** | 📐 rule of thumb | arithmetic; app ships the exact factor in lib/features/calculators/logic/units.dart (mPerFoot = 0.3048) | Printed in the same row as the exact 304.80 mm. This is a rounded working approximation, not an exact conversion (1.6% short); … |
| one inch expressed in millimetres | **25.4 mm** | ✅ verified | arithmetic + /Users/farhadh/Civil constraction minitoring /lib/features/calculators/logic/units.dart (mmPer… | Exact by the 1959 international definition of the inch, and it is the constant the app already ships (Units.mmPerInch = 25.4). |
| one inch expressed in centimetres | **2.54 cm** | ✅ verified | arithmetic | 25.4 mm is 2.54 cm exactly; simple arithmetic from the defined inch. |
| one foot expressed in millimetres | **304.80 mm** | ✅ verified | arithmetic | 12 × 25.4 = 304.8 mm exactly. |
| one foot expressed in centimetres | **30.48 cm** | ✅ verified | arithmetic | 304.8 mm is 30.48 cm exactly. |
| one mile expressed in metres | **1609.34 m** | ✅ verified | arithmetic | A mile is 1609.344 m by definition; 1609.34 is a correct two-decimal rounding. |
| one mile expressed in kilometres | **1.6093 km** | ✅ verified | arithmetic | 1609.344 m is 1.609344 km; 1.6093 is a correct rounding. |
| one metre expressed in inches | **39.37 inch** | ✅ verified | arithmetic | 1000 ÷ 25.4 = 39.3701 inches; 39.37 is the standard rounding. |
| one metre expressed in feet | **3.28 ft** | ✅ verified | arithmetic | A second, more precise value 3.281 ft/m is printed later in the same table under 'height measure'. |
| one kilometre expressed in feet | **3280.83 ft** | ✅ verified | arithmetic | 1000 ÷ 0.3048 = 3280.84 ft; the book's 3280.83 differs only in the last digit. |
| one kilometre expressed in miles | **0.621 mile** | ✅ verified | arithmetic | Printed twice in the same table. |
| one foot expressed in metres (height measure) | **0.305 m** | ✅ verified | arithmetic + lib/features/calculators/logic/units.dart (mPerFoot = 0.3048) | 0.3048 m rounds to 0.305 m at three decimals, which is the app's own foot-to-metre constant. |
| one metre expressed in feet (height measure) | **3.281 ft** | ✅ verified | arithmetic | 1 ÷ 0.3048 = 3.2808, which rounds to 3.281 — the more precise of the book's two figures, and the one to prefer. |

### mix ratio (12)

<sub>✅ verified 5 · 📐 rule of thumb 3 · 🟠 review 3 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| colouring to marble ratio in floor mosaic | **8:1** | ⛔ rejected | বইয়ের বর্ণনা অস্পষ্ট — বাদ দেওয়া হয়েছে | The book's gloss is terse; it reads as the colouring-to-marble proportion but does not state the two components separately. |
| cement:sand:aggregate ratio for DPC casting | **1:2:4** | 🟠 review | PWD SoR 2022 items 03.6.1 and 03.6.2 — damp proof course (1:1.5:3) with cement, Sylhet sand (F.M. 2.2) and … | PWD specifies a richer 1:1.5:3 for damp proof course, so the book's 1:2:4 is leaner than the public standard for a layer whose … |
| white cement to grey cement ratio in floor mosaic | **10:1** | 🟠 review | PWD SoR 2022 items 05.1.1 ('using 100% white cement') and 05.1.2 ('using 100% grey cement') | A 10:1 white-to-grey blend is common trade practice and matches the book's own 2.15 and 0.20 bag figures, but PWD writes its ca… |
| Cement:sand ratio for mortar in a brick foundation | **1:4** | 🟠 review | PWD SoR 2022 item 04.1 — "Brick works with first class bricks with cement sand (F.M. 1.2) mortar (1:6) in f… | I checked the PWD schedule and it disagrees: brickwork in foundation and plinth is specified 1:6, with 1:4 reserved for exterio… |
| cement:sand:aggregate ratio for RCC casting (item 6) | **1:2:4** | 📐 rule of thumb | PWD SoR 2022 item 03.5.1 'Mass concrete in foundation (1:2:4)' versus items 07.7.x 'Reinforced cement concr… | 1:2:4 is a nominal volumetric mix only: BNBC 2020 Part 6 and PWD's own RCC items specify structural concrete by characteristic … |
| cement:sand:aggregate ratio for RCC casting (item 7) | **1:1.5:3** | 📐 rule of thumb | PWD SoR 2022 items 03.6.1 and 04.30 use (1:1.5:3) for DPC and flooring, while RCC items 07.7.x are specifie… | 1:1.5:3 is the traditional nominal RCC mix and PWD still uses it for DPC and patent stone, but for a slab, beam or column BNBC … |
| Cement:sand:aggregate ratio for RCC work (column, lintel, beam, slab) in an ordinary building | **1:2:4** | 📐 rule of thumb | PWD SoR 2022 item 03.5.1 "Mass concrete in foundation (1:2:4)" (non-structural) versus items 07.7.1-07.7.4 … | 1:2:4 is a nominal-mix shortcut; the PWD schedule reserves 1:2:4 for mass concrete and non-structural work and specifies struct… |
| cement:sand mortar ratio for 5 inch brick wall masonry | **1:4** | ✅ verified | PWD SoR 2022 items 04.16 and 04.19 — '125 mm brick works with first class bricks with cement sand (F.M. 1.2… | PWD's own 125 mm (5 inch) brickwork items specify exactly a 1:4 cement-sand mortar, so the ratio is right for a partition wall … |
| cement:sand mortar ratio for 10 inch brick wall masonry | **1:6** | ✅ verified | PWD SoR 2022 item 04.1 'Brick works with first class bricks with cement sand (F.M. 1.2) mortar (1:6) in fou… | PWD specifies 1:6 cement-sand mortar for full-thickness (250 mm and above) brickwork in foundation, plinth and walls, matching … |
| cement:sand:aggregate ratio for cement concrete (CC) casting | **1:3:6** | ✅ verified | PWD SoR 2022 items 03.4.1 and 03.4.2 — 'Lean/ blinding concrete in foundation (1:3:6) with cement, brick ch… | PWD specifies 1:3:6 for lean/blinding concrete in foundation and floor, which is exactly the non-structural CC use the book is … |
| cement:sand:aggregate ratio for patent stone flooring | **1:2:4** | ✅ verified | PWD SoR 2022 item 04.26 — '25 mm thick artificial patent stone (1:2:4) flooring with cement, best quality c… | PWD's 25 mm patent stone flooring item specifies exactly 1:2:4, matching the book. |
| cement:sand ratio for cement plaster | **1:4** | ✅ verified | PWD SoR 2022 items 15.1.1 and 15.5 — 'cement sand (F.M. 1.2) plaster (1:4) with fresh cement' | PWD specifies 1:4 cement-sand for both wall and ceiling plaster, matching the book exactly. |

### mortar mix ratio (12)

<sub>🟠 review 8 · ✅ verified 4</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Cement-to-sand mortar ratio for 10-inch brick wall masonry | **1:6** | 🟠 review | PWD SoR 2022 item 04.2 (description truncated before the ratio) and item 04.3 — "...mortar (1:4) in exterio… | PWD's 250 mm wall item has its mortar ratio cut off in the shipped JSON, and PWD's exterior-wall brickwork item uses a richer 1… |
| Cement-to-sand mortar ratio for wall pointing | **1:4** | 🟠 review | PWD SoR 2022 items 15.7, 15.8, 15.9 — flush / rule / raised pointing to brick wall with cement sand mortar … | Printed as "পয়েন্টং" (OCR of পয়েন্টিং / pointing). |
| Cement-to-sand mortar ratio for fixing glazed tiles on walls | **1:3** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-১] — প্রকৌশলী যাচাই করেননি | The shipped SoR tile chapter (ch. 6) states tile sizes and quality but never a bedding mortar ratio, so 1:3 is plausible site p… |
| Cement-to-sand mortar ratio for laying floor tiles | **1:2** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-১] — প্রকৌশলী যাচাই করেননি | No PWD floor-tile item in the shipped schedule names a bedding mortar ratio, so the 1:2 stands only on the book. |
| Cement-to-sand mortar ratio for drain (nardoma) masonry | **1:6** | 🟠 review | Nearest analogue only: PWD SoR 2022 item 32.101 — "250mm and above thick brick work (1:6) in old/unservicea… | The shipped schedule has no drain-masonry construction item stating a mortar ratio, though PWD does use 1:6 for comparable sub-… |
| Cement-to-sand mortar ratio for soak-pit masonry | **1:6** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-১] — প্রকৌশলী যাচাই করেননি | There is no soak-pit masonry item in the shipped schedule; 1:6 is consistent with PWD's septic-tank brickwork but I cannot cite… |
| Cement-to-sand mortar ratio for ceramic jali (screen block) joints | **1:3** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-১] — প্রকৌশলী যাচাই করেননি | The PWD screen-block items (04.20.x) list block sizes only — the parent row carrying the mortar ratio is truncated in the shipp… |
| Mortar ratio quoted for 10-inch brick wall masonry in the thumb-rule section | **1:6** | 🟠 review | PWD SoR 2022 item 04.3 — "...mortar (1:4) in exterior walls" | Consistent with [১২-১]. |
| Cement-to-sand mortar ratio for foundation brick masonry | **1:6** | ✅ verified | PWD SoR 2022 item 04.1 — "Brick works with first class bricks with cement sand (F.M. 1.2) mortar (1:6) in f… | Cement : sand, by volume. |
| Cement-to-sand mortar ratio for 5-inch brick wall masonry | **1:4** | ✅ verified | PWD SoR 2022 items 04.16 and 04.19 — "125 mm brick works ... cement sand (F.M. 1.2) mortar (1:4)"; cf. 04.1… | 125 mm (≈5 inch) brickwork at 1:4 is a live PWD item, though PWD also prices a 1:6 version of the same wall, so 1:4 is the rich… |
| Cement-to-sand mortar ratio for septic tank walls | **1:6** | ✅ verified | PWD SoR 2022 items 32.101 ("250mm and above thick brick work (1:6) in old/unserviceable septic tank") and 3… | PWD prices septic-tank brickwork at 1:6 for both wall thicknesses, matching the book exactly. |
| Mortar ratio quoted for 5-inch brick wall masonry in the thumb-rule section | **1:4** | ✅ verified | PWD SoR 2022 items 04.16 and 04.19 — "125 mm brick works ... mortar (1:4)" | Consistent with [১২-১]. This is an estimator entry, not a design method. |

### unit conversion - weight (12)

<sub>✅ verified 9 · 🟠 review 2 · 📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one hundredweight (হন্দর) expressed in quintals | **0.504 quintal** | 🟠 review | arithmetic (112 × 0.45359237 = 50.802 kg) | 112 lb is 50.802 kg, i.e. 0.508 quintal, so the printed 0.504 is 0.8% low and is not a correct rounding of either the long (112… |
| one quintal expressed in hundredweight | **1.98 cwt** | 🟠 review | arithmetic (100 ÷ 50.802 = 1.968) | 100 kg ÷ 50.802 kg = 1.968 long cwt, so 1.98 is 0.6% high — it follows from the same slightly wrong hundredweight the book used… |
| one hundredweight (হন্দর) expressed in kilograms | **50 kg** | 📐 rule of thumb | arithmetic (112 × 0.45359237 = 50.802 kg) | Rounded: 112 lb is 50.8 kg, so the book's own two figures in this row are inconsistent by about 1.6%. Treat 50 kg as the trade … |
| one maund (মন) expressed in kilograms | **37.324 kg** | ✅ verified | arithmetic (40 ser × 0.9331 kg, the standardised ser) | The Bangladesh maund is 40 ser of 0.93310 kg = 37.3242 kg, matching the printed 37.324. |
| one pound expressed in kilograms | **0.4536 kg** | ✅ verified | arithmetic | The pound is 0.45359237 kg by definition; 0.4536 is a correct rounding. |
| one (long) ton expressed in metric tonnes | **1.016 metric ton** | ✅ verified | arithmetic (2240 × 0.45359237 = 1016.05 kg) | A long ton is 2240 lb = 1016.05 kg = 1.016 metric tonnes. |
| one quintal expressed in kilograms | **100 kg** | ✅ verified | arithmetic (definition) | The quintal is defined as 100 kg in the metric system. |
| one hundredweight (হন্দর) expressed in pounds | **112 lb** | ✅ verified | arithmetic (definition of the long cwt) | The imperial (long) hundredweight is 112 lb by definition — 8 stone of 14 lb. |
| one kilogram expressed in pounds | **2.204 lb** | ✅ verified | arithmetic | 1 ÷ 0.45359237 = 2.20462 lb; 2.204 is 0.03% low, within normal printing rounding. |
| one UK (long) ton expressed in pounds | **2240 lb** | ✅ verified | arithmetic (definition) | The UK long ton is 20 cwt × 112 lb = 2240 lb by definition. |
| one US (short) ton expressed in pounds | **2000 lb** | ✅ verified | arithmetic (definition) | The US short ton is 2000 lb by definition. |
| one metric tonne expressed in kilograms | **1000 kg** | ✅ verified | arithmetic (definition) | The tonne is 1000 kg by definition. |

### bearing capacity (11)

<sub>🟠 review 11</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| safe bearing capacity of gravel and sand (cohesionless) | **45 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান; ডিজাইনের মান মাটি পরীক্ষা থেকেই আ… | The table's first column is headed as clay classification (কাদামাটির শ্রেণী ভাগ) even though it lists cohesionless soils too — … |
| safe bearing capacity of coarse sand | **45 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Plausible as a presumptive value (45 T/m² is about 440 kPa) but not corroborated by anything in the repo, so it ships indicativ… |
| safe bearing capacity of medium sand | **25 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Plausible presumptive value (about 245 kPa) with no corroborating source in the repo. |
| safe bearing capacity of fine sand and silt | **15 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Plausible presumptive value (about 147 kPa) with no corroborating source in the repo. |
| safe bearing capacity of loose gravel | **25 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Listed as 25 while dense gravel/sand above is 45; plausible but unverified against a code. |
| safe bearing capacity of soft shale | **45 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Rock-class presumptive value with no corroborating source here, and shale is rare under most Bangladeshi plots, so it is backgr… |
| safe bearing capacity of medium clay | **25 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Plausible presumptive value (about 245 kPa) with no corroborating source in the repo. |
| safe bearing capacity of moist clay | **15 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Plausible presumptive value (about 147 kPa) with no corroborating source in the repo. |
| safe bearing capacity of soft clay | **10 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান; নরম মাটিতে পরীক্ষা ছাড়া ডিজাইন নয়। | Plausible presumptive value (about 98 kPa) with no corroborating source, and soft clay is exactly the case where a real test ma… |
| safe bearing capacity of very soft clay | **5 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান; খুব নরম মাটিতে পরীক্ষা বাধ্যতামূল… | 5 T/m² is about 49 kPa, at the optimistic end of what is normally assumed for very soft clay, so it must carry the amber badge … |
| safe bearing capacity of black cotton soil | **15 T/m²** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, টেবিল (১-৬) পঞ্চম অধ্যায় — আনুমানিক মান, মাটি পরীক্ষার বিকল্প নয়। | Black cotton soil swells and shrinks with moisture, so a single bearing number is a weak guide, and nothing in the repo corrobo… |

### formwork striking (11)

<sub>🟠 review 11</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Days after casting before side formwork of columns and beams may be struck | **3 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৬]; মান: BNBC 2020 পার্ট ৭ (ফর্মওয়ার্ক অপসারণ) — প্রকৌশলী যা… | The shipped PWD schedule prices shuttering by area and never states a striking period, so this is a book-only figure — it errs … |
| Days after casting before beam soffit (bottom) formwork may be struck | **21 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৬]; মান: BNBC 2020 পার্ট ৭ — প্রকৌশলী যাচাই করেননি | Twenty-one days before removing the beam bottom is a conservative period that is safe to publish, but no source in this repo co… |
| Days after casting before roof slab soffit (bottom) formwork may be struck | **21 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, সারণি [১২-৬], অধ্যায় ১৩ ও অধ্যায় ২; মান: BNBC 2020 পার্ট ৭ — প্রকৌশলী… | Corroborated twice elsewhere: a shuttering caution note says roof shuttering must be kept at least 21 days, and the chapter 13 … |
| Days after casting before slab side formwork may be struck | **2 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ (শাটারিং খোলার সময়সূচি) — প্রকৌশলী যাচাই করেননি | This second striking table in the book is more detailed than [১২-৬] and gives 2 days for slab sides, where [১২-৬] lists no slab… |
| Days after casting before slab soffit formwork may be struck (chapter 13 table) | **21 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ ও সারণি [১২-৬] — প্রকৌশলী যাচাই করেননি | Agrees with [১২-৬]. |
| Days after casting before lintel side formwork may be struck | **3 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ — প্রকৌশলী যাচাই করেননি | Book-only figure, consistent with the 3 days given for all other vertical faces in the same table. |
| Days after casting before lintel soffit formwork may be struck | **12 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ — বইয়ে একবারই আছে; প্রকৌশলী যাচাই করেননি | Lintels are the only item given a soffit period shorter than 21 days; [১২-৬] has no lintel row. |
| Days after casting before beam side formwork may be struck (chapter 13 table) | **3 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ ও সারণি [১২-৬] — প্রকৌশলী যাচাই করেননি | Agrees with [১২-৬]. |
| Days after casting before beam soffit formwork may be struck (chapter 13 table) | **21 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ ও সারণি [১২-৬] — প্রকৌশলী যাচাই করেননি | Agrees with [১২-৬]. |
| Days after casting before column side formwork may be struck (chapter 13 table) | **3 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ১৩ — প্রকৌশলী যাচাই করেননি | The same table marks a column soffit as not applicable (প্রয়োজন নয়). |
| Minimum days roof shuttering must be left in place | **21 days** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন, অধ্যায় ২ (শাটারিং সতর্কতা); মান: BNBC 2020 পার্ট ৭ — প্রকৌশলী যাচাই কর… | Stated as a minimum, consistent with the 21-day slab soffit rows. |

### plaster (11)

<sub>✅ verified 8 · 🟠 review 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| cement needed for 100 sft of 6 mm 1:4 cement plaster | **0.5 bags** | 🟠 review | arithmetic via PlasterCalculator, lib/features/calculators/logic/plaster.dart (2.08 cft wet × 1.30 ÷ 5 ÷ 1.… | The app's plaster calculator gives 0.43 bags for 100 sft at 6 mm and 1:4, so the book's 0.5 is 16% higher — a purchase rounding… |
| masons needed for 100 sft of cement plaster | **1 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | One mason-day per 100 sft of plaster is a plausible estimator figure with nothing in the repo to confirm it. |
| labourers needed for 100 sft of cement plaster | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | Two labour-days per 100 sft of plaster is plausible but uncorroborated here. |
| cement plaster thickness in inches | **0.25 inch** | ✅ verified | PWD SoR 2022 item 15.5 — 'Minimum 6 mm thick cement sand (F.M. 1.2) plaster (1:4) with fresh cement to ceil… | Printed as the fraction ১/৪ ইঞ্চি. |
| cement plaster thickness in millimetres | **6 mm** | ✅ verified | PWD SoR 2022 item 15.5 (minimum 6 mm plaster to ceiling, RCC columns and beams); arithmetic (0.25 in = 6.35… | 6 mm is exactly PWD's minimum ceiling plaster thickness and is a fair rounding of the book's 1/4 inch (6.35 mm); it is not the … |
| sand needed for 100 sft of 6 mm 1:4 cement plaster | **2 cft** | ✅ verified | arithmetic via PlasterCalculator, lib/features/calculators/logic/plaster.dart (2.08 cft wet × 1.30 × 4/5 = … | The app's plaster calculator gives 2.17 cft of sand for 100 sft at 6 mm and 1:4, so the book's 2 cft matches within 8%. |
| Wall plaster thickness | **0.5 inches** | ✅ verified | PWD SoR 2022 items 15.1.1 and 15.4 — "Minimum 12 mm thick cement sand (F.M. 1.2) plaster ... to both inner … | The PWD schedule specifies wall plaster at minimum 12 mm, and 12 mm is 0.47 in, so the book's 1/2 in is the same thickness in s… |
| Cement:sand ratio for wall plaster | **1:6** | ✅ verified | PWD SoR 2022 item 15.4 — "Minimum 12 mm thick cement sand (F.M. 1.2) plaster (1:6) having with fresh cement… | The PWD schedule's wall-plaster item names exactly this mix. |
| Plaster thickness for ceiling, column, beam, stair and sunshade | **0.25 inches** | ✅ verified | PWD SoR 2022 item 15.5 — "Minimum 6 mm thick cement sand (F.M. 1.2) plaster (1:4) with fresh cement to ceil… | The PWD schedule specifies ceiling, column and beam plaster at minimum 6 mm, and 6 mm is 0.236 in, which is the book's 1/4 in. |
| Cement:sand ratio for ceiling, column, beam, stair and sunshade plaster | **1:4** | ✅ verified | PWD SoR 2022 item 15.5 — "Minimum 6 mm thick cement sand (F.M. 1.2) plaster (1:4) ... to ceiling, R.C.C. co… | The same PWD item names the 1:4 mix for ceiling, column and beam surfaces. |
| Cement:sand ratio for mortar used in pointing | **1:2** | ✅ verified | PWD SoR 2022 items 15.7 (flush pointing), 15.8 (rule pointing), 15.9 (raised/tack pointing) — each "with ce… | All three pointing items in the PWD schedule specify 1:2 cement-sand mortar. |

### cost model of a complete house (10)

<sub>📐 rule of thumb 10</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| consultant design fee as a share of building cost | **6 percent** | 📐 rule of thumb | ২০১৯ সালের প্রচলিত হার — দর কষাকষির আন্দাজ হিসেবে দেখুন, নির্ধারিত ফি নয় | 2019 professional-fee norm; verify against current market practice. |
| construction supervision fee as a share of building cost | **1 percent** | 📐 rule of thumb | ২০১৯ সালের প্রচলিত হার — ভিজিটের সংখ্যার উপর নির্ভর করে | 2019 figure. |
| total consultant fee (design plus supervision) | **7 percent** | 📐 rule of thumb | arithmetic (6 + 1 = 7; and 100 + 7 = 107% of 'building cost') | Sums correctly from the 6% and 1% lines above it. |
| construction materials as a share of building cost | **60 percent** | 📐 rule of thumb | arithmetic (the [৮-৪] table's material lines total 70% against 60% here) | This 60/20 material-to-labour split contradicts the [৮-৪] table on the same pair of pages, where materials come to about 70% an… |
| masons and labourers as a share of building cost | **20 percent** | 📐 rule of thumb | arithmetic; contradicts costshare-labour (31%) in [৮-৪] | Contradicts the 31% labour share in [৮-৪]. 2019 figure. |
| plant and equipment as a share of building cost | **3 percent** | 📐 rule of thumb | ২০১৯ সালের আন্দাজি ভাগ — মিক্সার/পাম্প ব্যবহারের উপর নির্ভর করে | 3% for plant and equipment is a 2019 planning figure that swings entirely with whether the job uses a mixer, a pump or hand lab… |
| contractor profit as a share of building cost | **10 percent** | 📐 rule of thumb | ২০১৯ সালের প্রচলিত হার — দর কষাকষির মাপকাঠি হিসেবে দেখুন, নির্ধারিত সীমা নয় | Useful as a negotiating benchmark, but it is a 2019 norm, not a rule. |
| contractor overhead as a share of building cost | **4.5 percent** | 📐 rule of thumb | ২০১৯ সালের আন্দাজি ভাগ — প্রতিষ্ঠানের আকারভেদে বদলায় | 4.5% overhead is a 2019 planning figure that varies with the size of the contracting firm. |
| miscellaneous costs as a share of building cost | **2.5 percent** | 📐 rule of thumb | ২০১৯ সালের আন্দাজি ভাগ — বাকি খাতগুলোর জন্য রাখা সংস্থান | 2.5% miscellaneous is a residual planning allowance, not a measured quantity. |
| stated total of the construction cost breakdown | **100 percent** | 📐 rule of thumb | arithmetic (60+20+3+10+4.5+2.5 = 100; plus the separate 7% consultant block = 107%) | This one does add up: 60+20+3+10+4.5+2.5 = 100%. Note the 7% consultant fee is shown as a separate block, so total outlay on th… |

### cost share of building (10)

<sub>📐 rule of thumb 9 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| stated total of the building cost breakdown | **100 percent** | ⛔ rejected | arithmetic (22+12+11+10+15+31+7 = 108) | ARITHMETIC ERROR IN THE BOOK: the seven listed shares (22+12+11+10+15+31+7) total 108%, not 100%. Do not present this table as … |
| share of total building cost spent on bricks | **22 percent** | 📐 rule of thumb | arithmetic (22+12+11+10+15+31+7 = 108, not the 100 the book states) | A budgeting rule of thumb from a January 2019 book; material cost shares move with market prices and should be re-checked befor… |
| share of total building cost spent on cement | **12 percent** | 📐 rule of thumb | arithmetic (the table's seven shares total 108%) | 2019 figure; price-sensitive and likely stale. |
| share of total building cost spent on steel | **11 percent** | 📐 rule of thumb | arithmetic (the table's seven shares total 108%) | 2019 figure; steel prices in Bangladesh have moved sharply since, so this share is likely understated now. |
| share of total building cost spent on timber | **10 percent** | 📐 rule of thumb | arithmetic (the table's seven shares total 108%) | 2019 figure; price-sensitive and likely stale. |
| share of total building cost spent on other construction materials | **15 percent** | 📐 rule of thumb | arithmetic (the table's seven shares total 108%) | 2019 figure. |
| share of total building cost spent on labour and masons | **31 percent** | 📐 rule of thumb | arithmetic (the table's seven shares total 108%); contradicts costmodel-mason-labour (20%) in [৮-৫] | 2019 figure; wage-sensitive. Note this table's seven listed items sum to 108%, not the '= ১০০%' total the book prints beneath t… |
| share of total building cost spent on plaster work | **7 percent** | 📐 rule of thumb | arithmetic (22+12+11+10+15+31+7 = 108) | 2019 figure. This item overlaps with the material and labour lines above it, which may explain why the column sums to 108% rath… |
| share of building cost for sanitary and water supply work | **8 percent** | 📐 rule of thumb | ২০১৯ সালের আন্দাজি ভাগ — মূল সারণির বাইরে অতিরিক্ত খাত হিসেবে ছাপা | Printed as a footnote, i.e. additional to (not inside) the main table. 2019 figure. |
| share of building cost for electrical installation | **7 percent** | 📐 rule of thumb | ২০১৯ সালের আন্দাজি ভাগ — মূল সারণির বাইরে অতিরিক্ত খাত হিসেবে ছাপা | Printed as a footnote, i.e. additional to the main table. 2019 figure. |

### element cost share (10)

<sub>📐 rule of thumb 10</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Earthwork share of building structure cost | **1.5 percent** | 📐 rule of thumb | arithmetic (the ten shares 1.5+6+0.5+30+20+6+16+10+5+5 sum to exactly 100%) | This 10-item list sums to 100%. |
| Foundation share of building structure cost | **6 percent** | 📐 rule of thumb | arithmetic (this list sums to 100%, but conflicts with [৮-৩] 10%, [৮-১] 15% and [৮-২] 20%) | Conflicts with chapter 8's tables, which put foundation at 10% ([৮-৩]), 15% ([৮-১]) and 20% ([৮-২]). The book gives four differ… |
| DPC (damp proof course) share of building structure cost | **0.5 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | A cost-split estimator shortcut from a list that sums to 100%; nothing to verify against and nothing a citizen measures. |
| Brickwork share of building structure cost | **30 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; [৮-৩](২) gives 34% for the same item) | An estimator's cost share from a coherent 100% list; note the book's other breakdown puts brickwork at 34%, so 30-34% is the ho… |
| Roof/slab share of building structure cost | **20 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; [৮-৩](৫) also gives 20%) | An estimator's cost share; it is the one item the book agrees with itself on, appearing as 20% in both breakdowns. |
| Floor share of building structure cost | **6 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; [৮-৩](৪) gives 5%) | An estimator's cost share from a coherent 100% list; the book's other breakdown gives 5%, so 5-6%. |
| Doors and windows share of building structure cost | **16 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; [৮-৩](৬) gives 15%) | An estimator's cost share; the book's other breakdown gives 15% for woodwork, so 15-16%. |
| Plaster and painting share of building structure cost | **10 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; [৮-৩](৭)+(৮) give 7+5 = 12% for the same scope) | An estimator's cost share; the other breakdown splits the same work as plaster 7% plus painting 5% (12% together), so the two a… |
| Finishing share of building structure cost | **5 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | An estimator's cost share from a coherent 100% list; finishing scope is not defined, so the number is soft. |
| Miscellaneous share of building structure cost | **5 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | A residual estimator's share; useful only as the slack in a budget guess. |

### plot size (10)

<sub>✅ verified 7 · 🟠 review 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| upper limit of what the book calls a small plot | **4 katha** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [৪-৩] — বইয়ের নিজস্ব শ্রেণিবিভাগ, সরকারি সংজ্ঞা নয়। | A naming convention used in the book, not a regulatory classification. |
| lower limit of what the book calls a large plot | **5 katha** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [৪-৩] — বইয়ের নিজস্ব শ্রেণিবিভাগ। | Same as the small-plot row — a naming convention inside the book, with no regulatory backing found in the repo. |
| sample plot dimensions and area for a 1.75 katha plot | **25 × 50 = 1250 ft × ft = sqft** | 🟠 review | arithmetic (25 × 50 = 1250 sqft; 1.75 × 720 = 1260 sqft) | At the book's own 720 sqft/katha (implied by every other row), 1.75 katha is 1260 sqft, not 1250. The 25×50 rectangle does give… |
| sample plot dimensions and area for a 2 katha plot | **28.83 × 50 = 1440 ft × ft = sqft** | ✅ verified | arithmetic (28'-10" × 50' = 1441.7 sqft; 2 × 720 = 1440 sqft) | 28 ft 10 in × 50 ft = 1441 sqft; rounded to 1440 in the book. Consistent with 720 sqft per katha. |
| sample plot dimensions and area for a 2.5 katha plot | **30 × 60 = 1800 ft × ft = sqft** | ✅ verified | arithmetic (30 × 60 = 1800 sqft; 2.5 × 720 = 1800 sqft) | 30 × 60 = 1800 sqft and 2.5 × 720 = 1800 sqft — dimensions, area and katha all agree. |
| sample plot dimensions and area for a 3 katha plot | **36 × 60 = 2160 ft × ft = sqft** | ✅ verified | arithmetic (36 × 60 = 2160 sqft; 3 × 720 = 2160 sqft) | 36 × 60 = 2160 sqft and 3 × 720 = 2160 sqft — exact match. |
| sample plot dimensions and area for a 3.5 katha plot | **40 × 63 = 2520 ft × ft = sqft** | ✅ verified | arithmetic (40 × 63 = 2520 sqft; 3.5 × 720 = 2520 sqft) | 40 × 63 = 2520 sqft and 3.5 × 720 = 2520 sqft — exact match. |
| sample plot dimensions and area for a 4 katha plot | **45 × 64 = 2880 ft × ft = sqft** | ✅ verified | arithmetic (45 × 64 = 2880 sqft; 4 × 720 = 2880 sqft) | 45 × 64 = 2880 exactly; consistent. |
| sample plot dimensions and area for a 5 katha plot | **50 × 72 = 3600 ft × ft = sqft** | ✅ verified | arithmetic (50 × 72 = 3600 sqft; 5 × 720 = 3600 sqft) | 50 × 72 = 3600 sqft and 5 × 720 = 3600 sqft — exact match. |
| sample plot dimensions and area for a 7.5 katha plot | **60 × 90 = 5400 ft × ft = sqft** | ✅ verified | arithmetic (60 × 90 = 5400 sqft; 7.5 × 720 = 5400 sqft) | 60 × 90 = 5400 sqft and 7.5 × 720 = 5400 sqft — exact match. |

### rod hook length (10)

<sub>🟠 review 10</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| hook length as a multiple of rod diameter d | **12** | 🟠 review | arithmetic (the tabulated values are 12d rounded to convenient millimetres) | The tabulated values below are 12d rounded to convenient millimetres, so several do not equal 12d exactly. |
| hook length for a 6 mm diameter rod | **70 mm** | 🟠 review | arithmetic (12 × 6 = 72 mm, printed 70) | 12d would be 72 mm; the table rounds down to 70. |
| hook length for a 10 mm diameter rod | **120 mm** | 🟠 review | arithmetic (12 × 10 = 120 mm) | Exactly 12d. |
| hook length for a 12 mm diameter rod | **150 mm** | 🟠 review | arithmetic (12 × 12 = 144 mm, printed 150) | 12d would be 144 mm; the table rounds up to 150. |
| hook length for a 16 mm diameter rod | **200 mm** | 🟠 review | arithmetic (12 × 16 = 192 mm, printed 200) | 12d would be 192 mm; rounded up to 200. |
| hook length for a 19 mm diameter rod | **225 mm** | 🟠 review | arithmetic (12 × 19 = 228 mm, printed 225) | 12d would be 228 mm; rounded down to 225. |
| hook length for a 22 mm diameter rod | **265 mm** | 🟠 review | arithmetic (12 × 22 = 264 mm, printed 265) | 12d would be 264 mm. |
| hook length for a 25 mm diameter rod | **300 mm** | 🟠 review | arithmetic (12 × 25 = 300 mm) | Exactly 12d. |
| hook length for a 28 mm diameter rod | **340 mm** | 🟠 review | arithmetic (12 × 28 = 336 mm, printed 340) | 12d would be 336 mm; rounded up to 340. |
| hook length for a 32 mm diameter rod | **390 mm** | 🟠 review | arithmetic (12 × 32 = 384 mm, printed 390) | 12d would be 384 mm; rounded up to 390. |

### DPC (9)

<sub>🟠 review 5 · ✅ verified 3 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| waterproofing compound (paddlo) per bag of cement in DPC | **2.25 cft per bag** | ⛔ rejected | arithmetic (2.25 cft admixture against a 1.25 cft cement bag = 180% by volume) | UNIT DOUBTFUL: 2.25 cft of a waterproofing admixture per 1.25 cft bag of cement is implausible; the intended unit is likely kg … |
| damp proof course thickness in inches | **1.5 inch** | 🟠 review | PWD SoR 2022 item 03.6.1 — '75 mm thick damp proof course (1:1.5:3) with cement, Sylhet sand (F.M. 2.2) and… | PWD's own damp proof course item is 75 mm thick, nearly twice the book's 1.5 inch (38 mm), so shipping 1.5 inch as the norm wou… |
| damp proof course thickness in millimetres | **40 mm** | 🟠 review | arithmetic (1.5 × 25.4 = 38.1 mm); PWD SoR 2022 item 03.6.1 specifies 75 mm | 1.5 inch is 38.1 mm, so 40 mm is the book's rounding of its own inch figure. |
| bitumen needed for 100 sft of DPC | **15 kg** | 🟠 review | arithmetic (15 kg ÷ 9.29 sqm = 1.6 kg/sqm); compared against PWD SoR 2022 item 24.17 tack coat @ 7.50 kg pe… | 15 kg over 100 sft is 1.6 kg per square metre, a heavy but plausible sealing coat — for comparison PWD's road tack coat is 0.75… |
| masons needed for 100 sft of DPC | **1 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | One mason-day per 100 sft of DPC is a plausible estimator figure with no source in the repo to confirm it. |
| labourers needed for 100 sft of DPC | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | Two labour-days per 100 sft of DPC is plausible but uncorroborated here. |
| cement needed for 100 sft of 1.5 inch 1:2:4 DPC | **2.25 bags** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (12.5 × 1.54 ÷ 7 ÷ 1.25 = 2… | For 100 sft at 1.5 inch the wet volume is 12.5 cft, which by the app's 1.54 dry factor needs 2.2 bags at 1:2:4 — the book's 2.2… |
| sand needed for 100 sft of 1.5 inch 1:2:4 DPC | **6 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (12.5 × 1.54 × 2/7 = 5.5 cft) | The same calculation gives 5.5 cft of sand; the book's 6 cft is 9% higher, a normal wastage allowance, and keeps the row intern… |
| khoa/chips needed for 100 sft of 1.5 inch 1:2:4 DPC | **12 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (12.5 × 1.54 × 4/7 = 11 cft) | The same calculation gives 11 cft of aggregate; the book's 12 cft is 9% higher and consistent with its own sand figure. |

### electrical (9)

<sub>🟠 review 9</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| number of 15 A sockets for a drawing room, cited to the Bangladesh National Building Code | **1 sockets** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — 'SOCKET OUTLETS > 13 / 15 / 16 / 20 Amps.' confirms the socket class, no… | The book attributes the whole table to BNBC but gives no clause. BNBC was substantially revised in 2020, after this book, so re… |
| number of 15 A sockets for a living room | **1 sockets** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — socket outlet class 13/15/16/20 A | Same BNBC-attribution caveat as the drawing-room row. |
| number of 15 A sockets for a dining room | **1 sockets** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — socket outlet class 13/15/16/20 A | Plausible minimum from the book with the same uncited BNBC attribution, uncorroborated here. |
| number of 15 A sockets for a kitchen | **2 sockets** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — socket outlet class 13/15/16/20 A | The only room in the table given more than one. |
| number of 15 A sockets for the room holding the refrigerator | **1 sockets** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — socket outlet class 13/15/16/20 A | A dedicated socket for the fridge is sound practice, but the figure comes from an uncited 2019 reading of the code. |
| number of 15 A sockets for an air-conditioned room | **1 sockets per AC unit** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — socket outlet class 13/15/16/20 A | Stated as one per air conditioner, not one per room. |
| number of 15 A sockets for a bathroom | **0 sockets** | 🟠 review | assets/content/checklists/electrical.json item e7 — warns that a wet hand on a switch is the commonest shock | Printed as 'not needed' rather than as a digit. |
| number of 15 A sockets for a bedroom | **1 sockets** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — socket outlet class 13/15/16/20 A | One 15 A socket per bedroom is below what most households now run, so ship it as the book's 2019 minimum, never as a target. |
| number of 15 A sockets for a veranda | **1 sockets** | 🟠 review | PWD SoR (E&M) 2022 item 4.10.1.1 — socket outlet class 13/15/16/20 A | Plausible minimum, uncorroborated here, and the app should add that an outdoor-facing socket needs weather protection — the boo… |

### floor mosaic (9)

<sub>🟠 review 6 · ⛔ rejected 2 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| floor mosaic thickness in millimetres as printed | **10 mm** | ⛔ rejected | arithmetic (0.75 × 25.4 = 19.05 mm); PWD SoR 2022 item 05.10.1 (20 mm finished) | INCONSISTENT WITH THE INCH FIGURE IN THE SAME LINE: 3/4 inch is 19 mm, not 10 mm. One of the two is a misprint; do not publish … |
| marble chips needed for 100 sft of floor mosaic | **3.5 bags** | ⛔ rejected | বইয়ে ব্যাগের ওজন/আয়তন দেওয়া নেই — সংখ্যাটি ব্যবহারযোগ্য নয় | Measured in bags; the book does not state the weight or volume of a bag of marble chips, so this cannot be converted. |
| white cement needed for 100 sft of floor mosaic | **2.15 bags** | 🟠 review | এস্টিমেটরের হিসাব — পিডব্লিউডি ০৫.১.১ আইটেমে উপকরণের ভাগ আলাদা করে দেওয়া নেই; ইঞ্জিনিয়ার যাচাই করেননি | 2.15 bags per 100 sft is plausible for a 3/4 inch cast-in-situ mosaic topping and is internally consistent with the 0.20 bags o… |
| grey cement needed for 100 sft of floor mosaic | **0.20 bags** | 🟠 review | arithmetic (2.15 ÷ 0.20 = 10.75, close to the stated 10:1) | Consistent with the stated 10:1 white-to-grey ratio (2.15 : 0.20 is about 10.75:1). |
| dividing glass strip needed for 100 sft of floor mosaic | **120 rft** | 🟠 review | arithmetic (120 rft over 100 sft ≈ 2.5 ft panel grid); PWD SoR 2022 item 05.1.1 prices mosaic 'with glass s… | RFT = running feet. |
| acid needed for 100 sft of floor mosaic | **3 pounds** | 🟠 review | arithmetic (3 lb = 1.36 kg over 9.29 sqm) | 3 lb is about 1.36 kg. |
| masons needed for 100 sft of floor mosaic | **3 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 3 mason-days per 100 sft of cast-in-situ mosaic is plausible for skilled laying and polishing, but uncorroborated here. |
| labourers needed for 100 sft of floor mosaic | **10 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — মোজাইক সবচেয়ে শ্রমঘন কাজ; ইঞ্জিনিয়ার যাচাই করেননি | The highest labour count of any item in this section. |
| floor mosaic thickness in inches | **0.75 inch** | ✅ verified | PWD SoR 2022 item 05.10.1 — '200 mm x 200 mm x 20 mm (finished) mosaic terrazzo tiles flooring'; arithmetic… | Printed as the fraction ৩/৪ ইঞ্চি. |

### item cost share (9)

<sub>📐 rule of thumb 9</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Foundation up to plinth, including piling, as a share of building cost | **10 percent** | 📐 rule of thumb | arithmetic (10+34+1+5+20+15+7+5+3 = 100%) | The nine items of [৮-৩] sum to 100%. |
| Brickwork (including lime terracing) share of building cost | **34 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; [৭-০](৭)(খ)৪ gives 30%) | An estimator's share from a list that sums to 100%; brickwork is the largest single item in both of the book's breakdowns (30% … |
| DPC (damp proof course) share of building cost | **1 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | An estimator's share from a coherent 100% list; a fraction of a percent either way changes nothing in a household budget. |
| Floor share of building cost | **5 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; appendix gives 6%) | An estimator's share from a coherent 100% list, close to the appendix's 6%. |
| Roof, including stairs, share of building cost | **20 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; appendix also gives 20%) | An estimator's share, and the one item both of the book's breakdowns agree on at 20%. |
| Woodwork (doors and windows) share of building cost | **15 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; appendix gives 16%) | An estimator's share from a coherent 100% list, close to the appendix's 16% for doors and windows. |
| Plastering share of building cost | **7 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | An estimator's share from a coherent 100% list; the appendix bundles plaster with painting at 10%, against 7 plus 5 here. |
| Colouring and painting (whitewash, colour wash etc.) share of building cost | **5 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | An estimator's share from a coherent 100% list. |
| Miscellaneous share of building cost | **3 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | A residual estimator's share from a coherent 100% list; it is the slack, not a measurable item. |

### water storage (9)

<sub>🟠 review 5 · 📐 rule of thumb 2 · ✅ verified 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| minimum height of the overhead tank above the roof slab | **1.5 ft** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, পরিশিষ্ট [৫-০](৪)(গ) — ছাদ থেকে ট্যাংক উঁচুতে বসান যাতে ময়লা পানি না ঢোকে। | Chapter [১১-৪](গ) gives the same instruction in words (keep the tank raised above the roof so dirt and dirty water do not enter… |
| underground reservoir size for a one-storey residential building | **6 × 4 × 4 ft (L × W × D)** | 🟠 review | arithmetic (6 × 4 × 4 = 96 cft × 6.25 = 600 gallons) | 96 cft, about 600 gallons at the book's own conversion. |
| underground reservoir size for a two-storey residential building | **6 × 5 × 5 ft (L × W × D)** | 🟠 review | arithmetic (6 × 5 × 5 = 150 cft × 6.25 = 937.5 gallons) | 150 cubic feet works out to about 940 gallons, plausible but unanchored to any stated household size. |
| underground reservoir size for a three-storey residential building | **7 × 5 × 5 ft (L × W × D)** | 🟠 review | arithmetic (7 × 5 × 5 = 175 cft × 6.25 = 1093.75 gallons) | 175 cubic feet is about 1,094 gallons, a sensible step up from the two-storey size but still uncorroborated. |
| underground reservoir size for a four-storey residential building | **9 × 6 × 5 ft (L × W × D)** | 🟠 review | arithmetic (9 × 6 × 5 = 270 cft × 6.25 = 1687.5 gallons) | These four sizes assume a household size the book never states, so they cannot be checked against the 10 gallons/person/day fig… |
| days of stored water assumed when sizing the underground reservoir | **2 days** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, অতিরিক্ত অধ্যায়-৩, প্রশ্ন ৮৫ — মাপ বের করার ধরা হিসাব। | Printed with a Western digit '2' in the OCR text. |
| days of stored water assumed when sizing the overhead tank | **1 days** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, অতিরিক্ত অধ্যায়-৩, প্রশ্ন ৮৫ — মাপ বের করার ধরা হিসাব। | Same kind of sizing assumption as the reservoir days, with no code or test behind it. |
| gallons of water held by one cubic foot | **6.25 gallons per cft** | ✅ verified | arithmetic (28.3168 L ÷ 4.54609 L = 6.2288 imperial gallons per cft; 28.3168 ÷ 3.78541 = 7.48 US gallons) | This matches the imperial gallon (1 cft ≈ 6.23 imperial gallons), not the US gallon (≈7.48). The book's tank figures are intern… |
| overhead tank dimensions and the capacity the book assigns them | **4 × 4 × 4 = 400 ft = gallons** | ✅ verified | PWD SoR 2022 item 26.60 — 'Supply and installation of 400 gallon capacity ferro-cement water tank (HBRI mad… | Arithmetic checks out at 6.25 gallons per cft. Described as a GI/plastic tank. |

### material sampling for lab test (8)

<sub>🟠 review 8</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| number of cement bags in stock from which one bag is drawn as a lab test sample | **500 bags** | 🟠 review | PWD স্পেসিফিকেশন ও BNBC 2020, পার্ট ৫ — নির্মাণসামগ্রীর নমুনা ও ল্যাব পরীক্ষা | One sample per 500 bags is a plausible QC sampling rate, but the shipped SoR carries only test-fee items (09.9.x, priced per to… |
| number of cement bags taken as the sealed sample per 500-bag stock | **1 bags** | 🟠 review | PWD স্পেসিফিকেশন ও BNBC 2020, পার্ট ৫ — নির্মাণসামগ্রীর নমুনা ও ল্যাব পরীক্ষা | The '1 sealed bag per 500' pair is internally consistent with the stock figure but nothing in the repo states the sample size, … |
| number of bricks in stock from which one sample set is drawn | **50000 bricks** | 🟠 review | BDS 208 — পোড়ামাটির ইট; PWD স্পেসিফিকেশন — নমুনা গ্রহণ | 50,000 bricks per sample set is a citable sampling frequency but appears nowhere in the SoR or app content I searched. |
| bricks per sample set sent to the laboratory (1st class or jhama) | **5 bricks** | 🟠 review | BDS 208 — পোড়ামাটির ইট; PWD স্পেসিফিকেশন — নমুনা গ্রহণ | Five bricks per set matches the usual size of a brick test set, but I could not corroborate the number from the SoR (item 03.1.… |
| volume of medium/coarse sand stock from which one sample is drawn | **10000 cft** | 🟠 review | PWD স্পেসিফিকেশন — বালুর নমুনা ও এফ.এম. পরীক্ষা | 10,000 cft per sand sample is plausible for a site QC regime but is not stated in any repo source. |
| mass of the sand sample sent to the laboratory | **500 grams** | 🟠 review | PWD স্পেসিফিকেশন — বালুর নমুনা ও এফ.এম. পরীক্ষা | A 500 g laboratory sample is a workable quantity for a sieve/F.M. test, but nothing in the repo confirms the mass. |
| length of each steel rod piece taken as a lab sample | **1 metre** | 🟠 review | arithmetic (1 m = 3.281 ft) | OCR/print conflict: 1 metre is about 3.3 ft, not 6 ft. The parenthetical foot value is inconsistent with the metric value; do n… |
| number of rod pieces forming one sample set per rod batch | **3 pieces** | 🟠 review | BDS ISO 6935-2:2016 — রডের নমুনা ও প্রসার্য পরীক্ষা | Three pieces per set is the normal size of a rebar test set, but no repo source names it. |

### patent stone flooring (8)

<sub>✅ verified 4 · 🟠 review 3 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| waterproofing compound (paddlo) per bag of cement in patent stone flooring | **2.25 cft per bag** | ⛔ rejected | arithmetic (2.25 cft admixture against a 1.25 cft cement bag) | Same doubtful unit as the DPC item: 2.25 cft of admixture per bag of cement is implausible. Verify before publishing. |
| cement needed for 100 sft of 1 inch 1:2:4 patent stone flooring | **2 bags** | 🟠 review | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (8.33 × 1.54 ÷ 7 ÷ 1.25 = 1… | 100 sft at 1 inch is 8.33 cft wet, which at 1:2:4 needs about 1.5 bags by the app's method, so the book's 2 bags is 36% richer … |
| masons needed for 100 sft of patent stone flooring | **1 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | One mason-day per 100 sft of floor topping is a plausible estimator figure with nothing here to confirm it. |
| labourers needed for 100 sft of patent stone flooring | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | Two labour-days per 100 sft is plausible but uncorroborated here. |
| patent stone floor topping thickness in inches | **1 inch** | ✅ verified | PWD SoR 2022 item 04.26 — '25 mm thick artificial patent stone (1:2:4) flooring' | PWD's patent stone flooring item is 25 mm thick, which is one inch — the book's figure matches the public standard exactly. |
| patent stone floor topping thickness in millimetres | **25 mm** | ✅ verified | PWD SoR 2022 item 04.26 '25 mm thick artificial patent stone (1:2:4) flooring'; arithmetic (1 in = 25.4 mm) | 25 mm is the exact thickness PWD specifies for patent stone flooring and is one inch to within 0.4 mm. |
| sand needed for 100 sft of 1 inch patent stone flooring | **4 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (8.33 × 1.54 × 2/7 = 3.7 cft) | The app's method gives 3.7 cft of sand for a 1 inch 1:2:4 topping over 100 sft; the book's 4 cft is within 9%. |
| khoa/chips needed for 100 sft of 1 inch patent stone flooring | **8 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (8.33 × 1.54 × 4/7 = 7.3 cft) | The app's method gives 7.3 cft of chips; the book's 8 cft is within 9% and consistent with its own sand figure. |

### rod unit weight (metric) (8)

<sub>✅ verified 8</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight per metre of 6 mm diameter rod | **0.22 kg/m** | ✅ verified | arithmetic; reproduces exactly in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart (π/4… | The table's column header reads 'প্রতি ফুটে ওজন' (per foot) but every row states 'প্রতি মিটারের ওজন' (per metre); the per-metre… |
| weight per metre of 8 mm diameter rod | **0.40 kg/m** | ✅ verified | arithmetic; reproduces in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart | Column header says per foot; the row says per metre. Per metre is correct. |
| weight per metre of 10 mm diameter rod | **0.62 kg/m** | ✅ verified | arithmetic; reproduces in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart | 10² ÷ 162 = 0.617 kg/m, matching the printed 0.62. |
| weight per metre of 12 mm diameter rod | **0.89 kg/m** | ✅ verified | arithmetic; reproduces in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart | 12² ÷ 162 = 0.888 kg/m, matching the printed 0.89. |
| weight per metre of 16 mm diameter rod | **1.58 kg/m** | ✅ verified | arithmetic; reproduces in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart | 16² ÷ 162 = 1.578 kg/m, matching the printed value exactly. |
| weight per metre of 20 mm diameter rod | **2.47 kg/m** | ✅ verified | arithmetic; reproduces in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart | 20² ÷ 162 = 2.466 kg/m, matching the printed 2.47. |
| weight per metre of 22 mm diameter rod | **2.98 kg/m** | ✅ verified | arithmetic; reproduces in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart | 22² ÷ 162 = 2.984 kg/m, matching the printed 2.98. |
| weight per metre of 25 mm diameter rod | **3.85 kg/m** | ✅ verified | arithmetic; reproduces in the app's RebarCalculator, lib/features/calculators/logic/rebar.dart | 25² ÷ 162 = 3.853 kg/m, matching the printed 3.85. |

### CC 1:3:6 casting (7)

<sub>✅ verified 3 · 🟠 review 3 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| bricks needed instead, if khoa is made on site, for 100 cft of 1:3:6 cement concrete | **450 bricks** | ⛔ rejected | arithmetic against the book's own [৩-৫] item (২) figure of 850 bricks per 100 cft of khoa (which itself che… | INTERNALLY INCONSISTENT: this is an alternative to 90 cft of khoa, but [৩-৫] item (২) states 100 cft of khoa takes 850 bricks, … |
| sand needed for 100 cft of 1:3:6 cement concrete | **40 cft** | 🟠 review | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 × 3/10 = 46.2 cft) | Specified as casting sand. |
| masons needed for 100 cft of 1:3:6 cement concrete | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 2 mason-days per 100 cft of hand-mixed CC is a plausible estimator figure with no source in the repo to confirm it. |
| labourers needed for 100 cft of 1:3:6 cement concrete | **6 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 6 labour-days per 100 cft is plausible for hand mixing and placing but uncorroborated here. |
| khoa/chips needed for 100 cft of 1:3:6 cement concrete | **90 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (dry factor 1.54) | The app's concrete calculator (1.54 dry factor) gives 92.4 cft of aggregate per 100 cft of 1:3:6, so the book's 90 is within 3%. |
| cement needed for 100 cft of 1:3:6 cement concrete | **13 bags** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 cft dry ÷ 10 parts ÷ 1… | Repeated in [৩-৫] item (১৩). |
| water per bag of cement for 1:3:6 cement concrete | **20-25 litres per bag** | ✅ verified | arithmetic + lib/features/calculators/logic/concrete.dart (waterCementRatio default 0.45, kgPerCementBag 50) | A range, not a single value. 20-25 litres against a 50 kg bag is a water-cement ratio of 0.40-0.50. |

### RCC 1:1.5:3 casting (7)

<sub>✅ verified 4 · 🟠 review 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| bricks needed instead of khoa for 100 cft of 1:1.5:3 RCC | **850 bricks** | 🟠 review | arithmetic against rule-100cft-khoa-bricks (850 × 0.84 = 714 bricks) | Same brick count as the 1:2:4 item even though the khoa quantity is lower (84 vs 90 cft); the book does not reconcile this. |
| masons needed for 100 cft of 1:1.5:3 RCC | **2.5 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 2.5 mason-days per 100 cft of the richer mix is a plausible estimator figure with no source here to confirm it. |
| labourers needed for 100 cft of 1:1.5:3 RCC | **6 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 6 labour-days per 100 cft is plausible but uncorroborated here. |
| khoa/chips needed for 100 cft of 1:1.5:3 RCC | **84 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 × 3/5.5 = 84 cft) | The app's concrete calculator gives exactly 84 cft of aggregate per 100 cft of 1:1.5:3, matching the book to the digit. |
| cement needed for 100 cft of 1:1.5:3 RCC | **22 bags** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 ÷ 5.5 ÷ 1.25 = 22.4 bags) | Repeated in [৩-৫] item (১৫). |
| sand needed for 100 cft of 1:1.5:3 RCC | **42 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 × 1.5/5.5 = 42 cft) | Specified as casting sand. |
| water per bag of cement for 1:1.5:3 RCC | **20-25 litres per bag** | ✅ verified | arithmetic + lib/features/calculators/logic/concrete.dart (waterCementRatio default 0.45) | A range, not a single value. |

### RCC 1:2:4 casting (7)

<sub>✅ verified 5 · 🟠 review 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| masons needed for 100 cft of 1:2:4 RCC | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 2 mason-days per 100 cft of RCC is a plausible estimator figure with no source in the repo to confirm it. |
| labourers needed for 100 cft of 1:2:4 RCC | **6 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 6 labour-days per 100 cft is plausible for hand-placed RCC but uncorroborated here. |
| khoa needed for 100 cft of 1:2:4 RCC | **90 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 × 4/7 = 88 cft) | The app's concrete calculator gives 88 cft of aggregate per 100 cft of 1:2:4, so the book's 90 is within 2.3%. |
| bricks needed instead of khoa for 100 cft of 1:2:4 RCC | **850 bricks** | ✅ verified | arithmetic using the BDS brick size in lib/features/calculators/logic/brickwork.dart (850 × 0.068 cft = 57.… | Consistent with [৩-৫] item (২): 100 cft khoa = 850 bricks. |
| cement needed for 100 cft of 1:2:4 RCC | **18 bags** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 ÷ 7 ÷ 1.25 = 17.6 bags) | Repeated in [৩-৫] item (১৪). |
| sand needed for 100 cft of 1:2:4 RCC | **45 cft** | ✅ verified | arithmetic via ConcreteCalculator, lib/features/calculators/logic/concrete.dart (154 × 2/7 = 44 cft) | Specified as casting sand. |
| water per bag of cement for 1:2:4 RCC | **20-25 litres per bag** | ✅ verified | arithmetic + lib/features/calculators/logic/concrete.dart (waterCementRatio default 0.45) | A range, not a single value. |

### cost share (7)

<sub>📐 rule of thumb 6 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Foundation cost, given as a share within the civil-work line | **15 percent** | ⛔ rejected |  | Ambiguous: the book does not say whether this 15% is of the total building cost or of the 75% civil-work portion. Flag before use. |
| Civil work share of total building cost | **75 percent** | 📐 rule of thumb | arithmetic (75+15+9+1 = 100%; matches the [৭-০](৭)(খ) service list) | An estimator's split; the four lines of this table do sum to exactly 100%, and 75% for civil work also matches the appendix lis… |
| Water supply and sanitary share of total building cost | **15 percent** | 📐 rule of thumb | arithmetic (75+15+9+1 = 100%; matches the appendix service list) | Conflicts with [৮-৪]'s footnote, which gives 8% for the same item. |
| Electrical share of total building cost | **9 percent** | 📐 rule of thumb | arithmetic (table sums to 100%; matches the appendix service list) | Conflicts with [৮-৪]'s footnote, which gives 7%. |
| Gas share of total building cost | **1 percent** | 📐 rule of thumb | arithmetic (75+15+9+1 = 100%) | The four lines of [৮-১] total 100%. |
| Foundation cost up to plinth level, as a share of total building cost | **20 percent** | 📐 rule of thumb | arithmetic (20+80 = 100%) | One of four different foundation shares the book gives (6%, 10%, 15%, 20%). Present as a range or pick one and say so. |
| Superstructure (above foundation) share of total building cost | **80 percent** | 📐 rule of thumb | arithmetic (20+80 = 100%) | The complement of the foundation share in the same two-line split; it carries the same 6-20% uncertainty at the other end. |

### plaster mix ratio (7)

<sub>✅ verified 4 · 🟠 review 2 · 📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Cement-to-sand plaster ratio for drains | **1:3** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-২] — প্রকৌশলী যাচাই করেননি | The shipped schedule prices drain cleaning and re-excavation but no drain plastering item with a ratio, so 1:3 rests on the boo… |
| Cement-to-sand plaster ratio for septic tank | **1:3** | 🟠 review | PWD SoR 2022 item 32.103 — "12 mm plaster (1:4) with neat cement finishing in old/dilapitated septic tank" | PWD's septic-tank plaster item uses 1:4 with a neat cement finish, not the book's richer 1:3, so the two disagree and neither c… |
| Cement plaster ratio quoted in the thumb-rule section | **1:4** | 📐 rule of thumb | PWD SoR 2022 item 15.5 (6 mm, 1:4, on ceiling/columns/beams) versus items 15.1.1/15.4 (12 mm on walls) | Matches the RCC-member plaster ratio in [১২-২]; it does not match the 1:6 wall plaster ratio, and the thumb rule does not say w… |
| Cement-to-sand plaster ratio for all brick masonry walls | **1:6** | ✅ verified | PWD SoR 2022 item 15.4 — "Minimum 12 mm thick cement sand (F.M. 1.2) plaster (1:6) ... to both inner and ou… | PWD prices a 1:6 wall plaster for both inner and outer surfaces, so the book's figure is a real departmental option — though PW… |
| Cement-to-sand plaster ratio for RCC members (column, beam, ceiling, stair, sunshade, cornice, railing, drop w | **1:4** | ✅ verified | PWD SoR 2022 item 15.5 — "Minimum 6 mm thick cement sand (F.M. 1.2) plaster (1:4) ... to ceiling, R.C.C. co… | PWD's ceiling/column/beam plaster item uses exactly 1:4, matching the book's RCC-member ratio. |
| Cement-to-sand plaster ratio for plinth walls | **1:4** | ✅ verified | PWD SoR 2022 item 15.2 — "Minimum 12 mm thick cement sand plaster with neat cement finishing to plinth wall… | Printed "প্লিথ" (OCR of প্লিন্থ / plinth). |
| Cement-to-sand plaster ratio for sunshade, cornice and drip-course | **1:2** | ✅ verified | PWD SoR 2022 item 15.10 — "Providing drip course or nosing at the edge of sunshade or cornice with cement s… | No thickness printed for this row. Note the same book row [১২-২](২) gives 1:4 for sunshade/cornice as an RCC member — the two r… |

### rod unit weight (FPS) (7)

<sub>✅ verified 7</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight per foot of 1/4 inch (2 suta) diameter MS rod | **0.167 lb/ft** | ✅ verified | arithmetic using the 7850 kg/m³ steel density the app ships in lib/features/calculators/logic/rebar.dart | π/4 × 0.25² in² × 0.2836 lb/in³ × 12 = 0.167 lb/ft, matching the printed value exactly. |
| weight per foot of 3/8 inch (3 suta) diameter MS rod | **0.376 lb/ft** | ✅ verified | arithmetic using the steel density in lib/features/calculators/logic/rebar.dart (7850 kg/m³) | The same formula gives 0.376 lb/ft for a 3/8 inch bar, matching the printed value. |
| weight per foot of 1/2 inch (4 suta) diameter MS rod | **0.668 lb/ft** | ✅ verified | arithmetic using the steel density in lib/features/calculators/logic/rebar.dart (7850 kg/m³) | The same formula gives 0.668 lb/ft for a 1/2 inch bar, matching the printed value. |
| weight per foot of 5/8 inch (5 suta) diameter MS rod | **1.043 lb/ft** | ✅ verified | arithmetic using the steel density in lib/features/calculators/logic/rebar.dart (7850 kg/m³) | The same formula gives 1.044 lb/ft for a 5/8 inch bar; the printed 1.043 matches to the last digit. |
| weight per foot of 3/4 inch (6 suta) diameter MS rod | **1.502 lb/ft** | ✅ verified | arithmetic using the steel density in lib/features/calculators/logic/rebar.dart (7850 kg/m³) | The same formula gives 1.503 lb/ft for a 3/4 inch bar; the printed 1.502 is within 0.07%. |
| weight per foot of 7/8 inch (7 suta) diameter MS rod | **2.044 lb/ft** | ✅ verified | arithmetic using the steel density in lib/features/calculators/logic/rebar.dart (7850 kg/m³) | The same formula gives 2.046 lb/ft for a 7/8 inch bar; the printed 2.044 is within 0.1%. |
| weight per foot of 1 inch (8 suta) diameter MS rod | **2.670 lb/ft** | ✅ verified | arithmetic using the steel density in lib/features/calculators/logic/rebar.dart (7850 kg/m³) | The same formula gives 2.673 lb/ft for a 1 inch bar; the printed 2.670 is within 0.1%. |

### suta to diameter mapping (7)

<sub>✅ verified 7</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| rod diameter corresponding to 2 suta | **1/4 inches** | ✅ verified | arithmetic (2 × 1/8 in = 1/4 in) | The suta-to-inch mapping is printed in chapter 3, not chapter 9; chapter 9's table [৯-২] uses the same mapping. 1 suta = 1/8 inch. |
| rod diameter corresponding to 3 suta | **3/8 inches** | ✅ verified | arithmetic (3 × 1/8 in = 3/8 in = 9.53 mm; market bar 10 mm) | 3 × 1/8 inch is 3/8 inch exactly, though the bar actually sold for this size is 10 mm (0.394 in), a shade larger. |
| rod diameter corresponding to 4 suta | **1/2 inches** | ✅ verified | arithmetic (4 × 1/8 in = 1/2 in = 12.7 mm; market bar 12 mm) | 4 × 1/8 inch is 1/2 inch exactly; the bar sold for it is 12 mm. |
| rod diameter corresponding to 5 suta | **5/8 inches** | ✅ verified | arithmetic (5 × 1/8 in = 5/8 in = 15.9 mm; market bar 16 mm) | 5 × 1/8 inch is 5/8 inch exactly; the bar sold for it is 16 mm. |
| rod diameter corresponding to 6 suta | **3/4 inches** | ✅ verified | arithmetic (6 × 1/8 in = 3/4 in = 19.05 mm; market bar 20 mm) | 6 × 1/8 inch is 3/4 inch exactly; the bar sold for it is 20 mm. |
| rod diameter corresponding to 7 suta | **7/8 inches** | ✅ verified | arithmetic (7 × 1/8 in = 7/8 in = 22.2 mm; market bar 22 mm) | 7 × 1/8 inch is 7/8 inch exactly, though 22 mm is the nearest bar actually stocked. |
| rod diameter corresponding to 8 suta | **1 inches** | ✅ verified | arithmetic (8 × 1/8 in = 1 in = 25.4 mm; market bar 25 mm) | 8 × 1/8 inch is exactly 1 inch; the bar sold for it is 25 mm. |

### termite treatment (7)

<sub>⛔ rejected 7</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| DDT share of the termite-killing solution | **5 percent** | ⛔ rejected | PWD SoR 2022 item 29.1 — 'Supplying anti-termite chemicals named DURS BAN 20 EC / equivalent and mixing the… | SAFETY AND LEGAL: DDT, BHC/lindane, aldrin, heptachlor and chlordane are persistent organic pollutants banned or severely restr… |
| BHC share of the termite-killing solution | **0.5 percent** | ⛔ rejected | PWD SoR 2022 item 29.3 — anti-termite work specified with DURS BAN 20 EC / equivalent | Printed as 'বি.এইচ.এস' (BHS) — almost certainly BHC (benzene hexachloride); likely OCR or typesetting error. Banned substance; … |
| aldrin share of the termite-killing solution | **0.25 percent** | ⛔ rejected | PWD SoR 2022 item 29.1 — DURS BAN 20 EC specified for anti-termite chemicals | Banned substance; see the DDT row. |
| heptachlor share of the termite-killing solution | **0.25 percent** | ⛔ rejected | PWD SoR 2022 item 29.1 — DURS BAN 20 EC specified for anti-termite chemicals | Banned substance; see the DDT row. Chapter [১৫-৫] also names heptachlor and dieldrin for termite control without giving quantit… |
| chlordane share of the termite-killing solution | **0.5 percent** | ⛔ rejected | PWD SoR 2022 item 29.1 — DURS BAN 20 EC specified for anti-termite chemicals | Banned substance; see the DDT row. |
| water share of the termite-killing solution | **93.5 percent** | ⛔ rejected | arithmetic (5 + 0.5 + 0.25 + 0.25 + 0.5 + 93.5 = 100.0) | The six shares sum to exactly 100%, so the recipe is internally consistent as printed — but see the DDT row on legality. |
| volume of the termite solution applied per cubic metre of termite nest | **4 litres per m³** | ⛔ rejected | PWD SoR 2022 item 29.2 — anti-termite chemical mixed with water, priced per cum, using DURS BAN 20 EC | Dose for the banned mixture above; not usable as advice. Also note the source sentence calls the mixture a 'salt' (লবণ) where i… |

### material cost share (6)

<sub>⛔ rejected 6</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Brick cost as a share of building cost | **22 percent** | ⛔ rejected | arithmetic (22+12+11+10+15+31+7 = 108%) | The seven items of [৮-৪] sum to 108%, not 100%, although the table prints a 100% total. The table as OCR'd does not add up; fla… |
| Cement cost as a share of building cost | **12 percent** | ⛔ rejected | arithmetic (the table's seven items total 108%) | See the sum caveat on the brick row: this table's seven items total 108%. |
| Steel (iron) cost as a share of building cost | **11 percent** | ⛔ rejected | arithmetic (the table's seven items total 108%) | See the sum caveat: this table totals 108%. |
| Timber cost as a share of building cost | **10 percent** | ⛔ rejected | arithmetic (the table's seven items total 108%) | See the sum caveat: this table totals 108%. |
| Other construction materials as a share of building cost | **15 percent** | ⛔ rejected | arithmetic (the table's seven items total 108%) | See the sum caveat: this table totals 108%. |
| Plastering work as a share of building cost, in the material/labour table | **7 percent** | ⛔ rejected | arithmetic (the table's seven items total 108%) | See the sum caveat: this table totals 108%. |

### material weight (6)

<sub>📐 rule of thumb 3 · ⛔ rejected 2 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight of 225 cft of lime, sand or surki | **100 maund per 225 cft** | ⛔ rejected | arithmetic (100 × 37.324 kg ÷ 6.37 m³ = 586 kg/m³, against 1400-1600 kg/m³ for sand) | 100 maund is about 3,732 kg, so this implies a bulk density of roughly 16.6 kg/cft (586 kg/m3) applied to all three materials a… |
| length of 16 gauge barbed wire weighing one hundredweight | **950 ft per cwt** | ⛔ rejected | arithmetic (50.8 kg ÷ 289.6 m = 175 g/m; two strands of 1.65 mm steel = 33 g/m plus barbs) | One হন্দর (cwt) is given elsewhere in the book as 112 lb / 50 kg. |
| volume of lime weighing one maund | **2.25 cft per maund** | 📐 rule of thumb | arithmetic (37.324 kg ÷ 0.0637 m³ = 586 kg/m³, within the 500-600 kg/m³ range for loose lime) | Consistent with the 225 cft = 100 maund rule in the same list. |
| CI sheet bundles making one ton (24 gauge) | **10 bundles per ton** | 📐 rule of thumb | আন্দাজি হিসাব — কেবল ২৪ গেজের জন্য; বান্ডিলে কয়টি শিট তা বইয়ে বলা নেই | Gauge-specific (24 gauge); the book does not state how many sheets are in a bundle, so this cannot be reduced to a per-sheet we… |
| number of 2.5 inch nails weighing one ser | **200 nails per ser** | 📐 rule of thumb | arithmetic (1 ser = 0.9331 kg ÷ 200 = 4.67 g per nail) | A ser is about 0.93 kg; the book does not define it. Implies roughly 4.7 g per nail. |
| weight of 1000 bricks | **3.5 tons per 1000 bricks** | ✅ verified | arithmetic using the BDS brick size in lib/features/calculators/logic/brickwork.dart (0.001927 m³ × 1800 kg… | Implies about 3.5 kg per brick. |

### plaster thickness (6)

<sub>✅ verified 4 · 🟠 review 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Plaster thickness in drains | **0.5 inch** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-২] — প্রকৌশলী যাচাই করেননি | No PWD drain-plaster item exists in the shipped schedule to confirm the half-inch thickness. |
| Plaster thickness on septic tank | **0.75 inch** | 🟠 review | PWD SoR 2022 item 32.103 (12 mm plaster in septic tank); cf. item 15.15.2 — "Minimum 19mm thick ... water p… | PWD plasters septic tanks at 12 mm, half the book's 3/4 inch (19 mm), so the book's figure is unconfirmed even though 19 mm mat… |
| Plaster thickness on brick masonry walls | **0.5 inch** | ✅ verified | PWD SoR 2022 items 15.1.1 and 15.4 — "Minimum 12 mm thick cement sand plaster"; arithmetic: 12 mm = 0.472 i… | PWD's wall-plaster items specify a minimum 12 mm, and 12 mm is 0.47 inch, so the book's half inch is the same thickness within … |
| Plaster thickness on RCC members (column, beam, ceiling, stair, sunshade, cornice, railing, drop wall, louver) | **0.25 inch** | ✅ verified | PWD SoR 2022 item 15.5 — "Minimum 6 mm thick ... plaster (1:4) ... to ceiling, R.C.C. columns, beams"; arit… | PWD sets 6 mm minimum on the same RCC surfaces, and 1/4 inch is 6.35 mm, so the two agree. |
| Plaster thickness on plinth walls | **0.5 inch** | ✅ verified | PWD SoR 2022 item 15.2 — "Minimum 12 mm thick ... plaster ... to plinth wall"; arithmetic: 1/2 in = 12.7 mm | The same PWD plinth item sets 12 mm minimum, which is the book's half inch within rounding. |
| Plaster thickness used in the thumb-rule estimate | **0.25 inch** | ✅ verified | arithmetic (1/4 in = 6.35 mm) plus PWD SoR 2022 item 15.5 — "Minimum 6 mm thick ... plaster (1:4) ... to ce… | 1/4 inch = 6.35 mm, so 6 mm is a correct rounding. Matches the RCC plaster thickness in [১২-২]. |

### service cost share (6)

<sub>📐 rule of thumb 4 · ⛔ rejected 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Sanitary and water supply cost as a share of building cost (footnote) | **8 percent** | ⛔ rejected | arithmetic (its parent table totals 108%) | Conflicts with the 15% given in [৮-১] and in the appendix list. |
| Electrical installation cost as a share of building cost (footnote) | **7 percent** | ⛔ rejected | arithmetic (its parent table totals 108%) | Conflicts with the 9% given in [৮-১] and in the appendix list. |
| Sanitary work share of total building cost | **15 percent** | 📐 rule of thumb | arithmetic (this four-item list sums to 100%; the figure matches [৮-১]) | The appendix labels two consecutive lists both as (খ). This four-item list sums to 100% and matches chapter 8 table [৮-১]. But … |
| Electrical work share of total building cost | **9 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; matches [৮-১]) | Matches [৮-১]. [৮-৪]'s footnote instead gives electrical installation as 7%. |
| Gas work share of total building cost | **1 percent** | 📐 rule of thumb | arithmetic (list sums to 100%; matches [৮-১]) | Matches [৮-১]. |
| Structural (civil) work share of total building cost | **75 percent** | 📐 rule of thumb | arithmetic (75+15+9+1 = 100%; matches [৮-১]) | Matches [৮-১]. The four items are printed with an explicit 100% total. |

### tile size (6)

<sub>🟠 review 5 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| floor tile thickness range | **1/2 to 3 inches** | ⛔ rejected |  | OCR damage and implausible: a 3-inch-thick floor tile is not a real product; the upper figure is most likely 3/4" with the frac… |
| smallest listed flat tile size | **6 x 6 x 1/2 inches** | 🟠 review | PWD SoR 2022, অধ্যায় ৬ — টাইলসের মাপ (বর্তমান তালিকায় মিলিমিটারে) | A 6 × 6 × 1/2 inch flat tile is readable from the page and plausible for the older product, but no tile that small appears anyw… |
| largest listed flat tile size | **8 x 8 x 1/2 inches** | 🟠 review | PWD SoR 2022, অধ্যায় ৬ — টাইলসের মাপ (বর্তমান তালিকায় মিলিমিটারে) | OCR damage: the multiplication sign before 1/2" is missing in the source, so the thickness is inferred from the matching 6x6x1/… |
| smallest listed floor tile size | **6 x 6 inches** | 🟠 review | PWD SoR 2022 items 06.1.1 and 06.14.2 — smallest floor tile listed is 300 mm x 300 mm | A 6 × 6 inch (150 mm) floor tile is half the smallest floor tile the current schedule prices, so the book's lower bound describ… |
| largest listed floor tile size | **12 x 12 inches** | 🟠 review | PWD SoR 2022 items 06.1.6 (305 mm x 305 mm) and 06.4.5 (1200 mm x 1200 mm) | 12 × 12 inches is 305 mm, which is the smallest floor tile in the current schedule rather than the largest — the SoR runs up to… |
| wall tile size used in bathrooms and toilets | **6 x 6 x 1/2 inches** | 🟠 review | PWD SoR 2022 item 06.6.1 — wall tiles 'less than, equal or equivalent to 250 mm x 330 mm' | A 6 × 6 inch bathroom wall tile is readable and was once standard, but the smallest wall tile in the shipped SoR is 250 × 330 m… |

### water supply (6)

<sub>🟠 review 6</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Diameter of the GI pipe carrying water from the underground reservoir up to the roof tank | **0.75 inches** | 🟠 review | PWD SoR 2022 item 26.42.2 — "20 mm dia G.I. pipe with wall thickness 2.65 mm, outside diameter min 25.3 mm,… | 20 mm (3/4 in) is a standard GI size in the PWD schedule, so the pipe exists and is buyable, but the schedule does not say whic… |
| Diameter of the GI distribution pipe from the roof tank to bathrooms, toilets and kitchen | **0.5 inches** | 🟠 review | PWD SoR 2022 item 26.42.1 — "12.5 mm dia G.I. pipe with wall thickness 2.65 mm, outside diameter min 17.8 m… | 12.5 mm (1/2 in) is a standard GI size in the schedule, which corroborates the size but not the claim that every distribution r… |
| Diameter of the GI service pipe connecting the meter to the water main | **1 inches** | 🟠 review | PWD SoR 2022 item 26.42.3 — "25 mm dia G.I. pipe with wall thickness 3.35 mm, outside diameter min 31.7 mm,… | 25 mm (1 in) is a standard GI size in the schedule; the size is corroborated, the role is not — the service connection diameter… |
| diameter of the GI pipe that pumps water from the underground reservoir to the roof tank | **3/4 inches** | 🟠 review | PWD SoR 2022 item 26.42.2 — '20 mm dia G.I. pipe with wall thickness 2.65 mm, outside diameter min 25.3 mm,… | The book adds that pipe diameter is changed where needed, so this is a typical size, not a fixed rule. |
| diameter of the GI distribution pipe from the roof tank to bathrooms, toilets and kitchen | **1/2 inches** | 🟠 review | PWD SoR 2022 item 26.42.1 — '12.5 mm dia G.I. pipe with wall thickness 2.65 mm, outside diameter min 17.8 m… | 12.5 mm (1/2 in) is a standard G.I. size in the shipped SoR, but the book's assignment of it to all distribution runs is a simp… |
| diameter of the GI service pipe connecting the house to the metered mains supply | **1 inches** | 🟠 review | PWD SoR 2022 item 26.42.3 — '25 mm dia G.I. pipe with wall thickness 3.35 mm, outside diameter min 31.7 mm,… | 25 mm (1 in) is a standard G.I. size in the shipped SoR, but the service connection size is set by the water authority at the m… |

### 10 inch brick wall (5)

<sub>🟠 review 4 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| cement needed for 100 cft of 10 inch (1:6) brick wall | **4 bags** | 🟠 review | arithmetic via BrickworkCalculator (lib/features/calculators/logic/brickwork.dart), 1.30 mortar dry factor,… | Low relative to the 30 cft of sand quoted in the same item (4 bags is 5 cft of cement, giving roughly 1:6 by volume, so it is i… |
| sand needed for 100 cft of 10 inch (1:6) brick wall | **30 cft** | 🟠 review | arithmetic via BrickworkCalculator (lib/features/calculators/logic/brickwork.dart) | Specified as local masonry sand. |
| masons needed for 100 cft of 10 inch (1:6) brick wall | **4 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 4 mason-days per 100 cft of full-thickness wall is a plausible estimator figure with nothing in the repo to check it against. |
| labourers needed for 100 cft of 10 inch (1:6) brick wall | **6 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 6 labour-days per 100 cft is plausible against the 4 masons in the same item but uncorroborated here. |
| first-class bricks needed for 100 cft of 10 inch (1:6) brick wall | **1150 bricks** | ✅ verified | arithmetic via BrickworkCalculator, lib/features/calculators/logic/brickwork.dart (11.35 bricks per cft of … | Note the base unit is 100 CFT (volume) here, unlike the 5 inch wall item which is per 100 SFT. Repeated in [৩-৫] item (১২). |

### 5 inch brick wall (5)

<sub>🟠 review 4 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| cement needed for 100 sft of 5 inch (1:4) brick wall | **3 bags** | 🟠 review | arithmetic via BrickworkCalculator (lib/features/calculators/logic/brickwork.dart), 1.30 mortar dry factor,… | A bag is 50 kg / 1.25 cft per [৩-৫] item (৫). |
| sand needed for 100 sft of 5 inch (1:4) brick wall | **13 cft** | 🟠 review | arithmetic via BrickworkCalculator (lib/features/calculators/logic/brickwork.dart); PWD SoR 04.16 specifies… | The sand is described as 'bhiti' (filling) sand, which is unusual for a 1:4 masonry mortar; other masonry items in this section… |
| masons needed for 100 sft of 5 inch (1:4) brick wall | **2.5 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 2.5 mason-days per 100 sft of 5 inch wall is a plausible estimator figure but nothing in the repo carries labour coefficients t… |
| labourers needed for 100 sft of 5 inch (1:4) brick wall | **4 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | 4 labour-days per 100 sft is plausible against the 2.5 masons quoted in the same item, but uncorroborated here. |
| bricks needed for 100 sft of 5 inch (1:4) brick wall | **500 bricks** | ✅ verified | arithmetic via BrickworkCalculator, lib/features/calculators/logic/brickwork.dart (9.5×4.5×2.75 in brick, 1… | Repeated in [৩-৫] item (১১). |

### brick soling (5)

<sub>🟠 review 3 · ✅ verified 1 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| sand needed for 100 sft of brick soling | **5 cubic m** | ⛔ rejected | arithmetic (5 m³ ÷ 0.0283 = 177 cft over 100 sft = 1.77 ft depth) | UNIT ALMOST CERTAINLY WRONG IN THE BOOK. 5 cubic metres (about 177 cft) of sand for 100 sft of soling is physically implausible… |
| masons needed for 100 sft of brick soling | **0.5 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | Printed as the fraction ১/২ (half a mason-day per 100 sft). |
| labourers needed for 100 sft of brick soling | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | Two labour-days per 100 sft of soling is a plausible estimator figure but no source in the repo carries labour productivity coe… |
| Sand fill quantity for brick soling per 100 square feet | **5 cft per 100 sft** | 🟠 review | arithmetic (5 cft / 100 sft = 0.6 in layer); PWD SoR 2022 item 03.1.1 "One layer brick flat soling in found… | Arithmetically sensible — 5 cft spread over 100 sft is a 0.6 inch sand cushion, which is the right order for bedding and joint-… |
| bricks needed for 100 sft of brick soling | **300 bricks** | ✅ verified | arithmetic using the BDS brick size shipped in lib/features/calculators/logic/brickwork.dart (9.5×4.5×2.75 … | Repeated in [৩-৫] item (১০). |

### cost breakdown (5)

<sub>📐 rule of thumb 5</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Construction materials as a share of construction cost | **60 percent** | 📐 rule of thumb | arithmetic (60+20+3+10+4.5+2.5 = 100%) | The six items of [৮-৫](খ) sum to exactly 100%. Note this 100% is the construction-cost breakdown, separate from the 7% consulta… |
| Equipment and plant as a share of construction cost | **3 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | An estimator's share from the coherent 100% list; for an ordinary house with hired mixers it is a small line. |
| Contractor's profit as a share of construction cost | **10 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | An estimator's share from the coherent 100% list, and a genuinely useful one for a homeowner reading a quotation, though real m… |
| Overhead (contractor's own establishment cost) as a share of construction cost | **4.5 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | An estimator's share from the coherent 100% list. |
| Miscellaneous as a share of construction cost | **2.5 percent** | 📐 rule of thumb | arithmetic (list sums to 100%) | The residual line that closes the list to 100%; it is the slack, not a measurable item. |

### finishing (5)

<sub>🟠 review 3 · ⛔ rejected 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| lime needed per square metre of white wash | **3 kg per sq m** | ⛔ rejected | arithmetic (3 kg/sqm ÷ ~600 kg/m³ loose lime = 5 mm dry thickness); PWD SoR 2022 item 16.12 'White washing … | Unusually high for a wash coat; the book gives no number of coats. |
| area covered by one 40 kg tin of snowcem | **275 sq yards per 40 kg tin** | ⛔ rejected | arithmetic (275 sq yd = 230 sqm; 40 kg ÷ 230 = 0.17 kg/sqm, against 0.5 kg/sqm in finish-cement-paint) | 275 sq yd is about 2,475 sq ft. Product-specific and may not match current packaging. |
| cement paint needed per square metre | **0.5 kg per sq m** | 🟠 review | এস্টিমেটরের হিসাব — কোটের সংখ্যা বইয়ে বলা নেই; প্রস্তুতকারকের কভারেজের সঙ্গে মিলিয়ে নিন | 0.5 kg per square metre is in the normal range for cement paint and lets a homeowner sanity-check a painter's material bill, bu… |
| area covered by one gallon of distemper | **250 sq ft per gallon** | 🟠 review | arithmetic (250 sqft = 23.2 sqm ÷ 4.55 L = 5.1 sqm per litre) | The book does not say whether the gallon is imperial (4.55 L) or US (3.79 L), nor the number of coats. |
| area covered by one gallon of paint | **300 sq ft per gallon** | 🟠 review | arithmetic (300 sqft = 27.9 sqm ÷ 4.55 L = 6.1 sqm per litre) | Gallon type and coat count not stated. |

### sand F.M. (5)

<sub>🟠 review 4 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| fineness modulus of fine (soru/chikon) sand, used for plaster work | **1.05 F.M.** | 🟠 review | PWD SoR 2022 item 15.1.1 — plaster specified with cement sand of F.M. 1.2 | The list in [৯-৭](ক) names this type চিকন বালু while the description calls it সরু বালু — same sand, two names. |
| fineness modulus of medium-coarse sand, used for brick masonry mortar | **1.50 F.M.** | 🟠 review | PWD SoR 2022 items 04.1, 04.3, 04.15 — brickwork with 'cement sand (F.M. 1.2) mortar' | F.M. 1.50 as 'medium coarse' is plausible, but the shipped SoR specifies F.M. 1.2 sand for brick masonry mortar, so the pairing… |
| fineness modulus of coarse sand, used for concrete casting | **2.00 F.M.** | 🟠 review | PWD SoR 2022 items 03.5.1 (F.M. 1.2 local sand) and 03.6.1 (Sylhet sand F.M. 2.2) | F.M. 2.00 sits between the two sands the SoR actually names for concrete — F.M. 1.2 local sand for mass concrete and F.M. 2.2 S… |
| fineness modulus of Sylhet sand, the coarsest of the listed sands | **2.50 F.M.** | 🟠 review | PWD SoR 2022 items 03.6.1, 03.6.2 and 24.18.1 — 'Sylhet sand (F.M. 2.2)' | The shipped SoR names Sylhet sand at F.M. 2.2 in every item that uses it, not 2.50, so the book's figure is 0.3 high and a revi… |
| fineness modulus of viti sand, used only for site/land filling | **0.5 F.M.** | ✅ verified | PWD SoR 2022 item 02.10.1 — 'Sand filling in foundation trenches and plinth with sand having minimum F.M. 0.5' | Fineness modulus (F.M.) is a single number summarising how coarse a sand is — higher means coarser. |

### soil test (5)

<sub>⛔ rejected 2 · 📐 rule of thumb 2 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight of the falling hammer used in the Standard Penetration Test as the book states it | **650 newtons** | ⛔ rejected | arithmetic (650 N ÷ 9.80665 = 66.3 kg; 63.5 kg × 9.80665 = 622.7 N) | The internationally standard SPT hammer is 63.5 kg, about 623 N, not 650 N. Treat the book's figure as approximate; do not pres… |
| drop height of the SPT hammer as the book states it | **750 mm** | ⛔ rejected | arithmetic (30 in = 762 mm, the basis of the 760 mm drop) | The internationally standard SPT drop is 760 mm. The book's 750 mm is close but not the standard value; possible rounding or OC… |
| vertical spacing at which SPT (N) values are taken down a borehole | **5 ft** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-৪) ও (১-৭)(খ) পঞ্চম অধ্যায় — বোর লগে N মান নিয়মিত ব্যবধানে থাকার কথা। | Stated twice in the chapter, consistently. SPT = Standard Penetration Test, a field test where a weight is dropped on a rod and… |
| borehole depth the book suggests per storey of the planned building | **3 m per storey** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-৫) পঞ্চম অধ্যায় — আন্দাজের সূত্র; আসল গভীরতা মাটির স্তর দেখে প্রকৌশলী ঠ… | An estimator's shortcut only. Real borehole depth is set by the geotechnical engineer from the soil profile and foundation type… |
| depth to which soil-testing firms typically push the boring pipe | **40 to 50 ft** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, পঞ্চম অধ্যায় — প্রচলিত অভ্যাস, বাধ্যতামূলক নয়। | Described as common practice with 'deeper if needed', not a requirement. |

### stairs (5)

<sub>🟠 review 5</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Minimum stair step size (tread x riser) | **10x6 inches** | 🟠 review | arithmetic (2 x 6 + 10 = 22 in) | The book labels this a minimum; item (৬)(ক) restates it as riser 6 in and tread minimum 10 in. |
| Stair riser height | **6 inches** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০]। BNBC ২০২০ পার্ট ৩-এর সঙ্গে মিলিয়ে নিন — ইঞ্জিনিয়ার য… | A 6 in (152 mm) riser sits comfortably under the residential maximum riser heights codes normally set, but the repo holds no co… |
| Minimum stair tread depth | **10 inches** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০] — এটি ন্যূনতম মাপ। BNBC ২০২০-এর সঙ্গে মিলিয়ে নিন। | A 10 in (254 mm) minimum tread is at or just above the usual residential minimum, and it is stated as a minimum, but nothing in… |
| Minimum width of the stair flight (step width across) | **1175 mm** | 🟠 review | arithmetic (1175 mm = 46.26 in = 3 ft 10.3 in; 3 ft 9 in = 1143 mm — a 32 mm gap) | The book gives 1175 mm and 3 ft 9 in as equivalents; 3'-9" is actually 1143 mm, so the two figures are about 32 mm apart. Use o… |
| Stair handrail height | **815 mm** | 🟠 review | arithmetic (815 mm = 32.09 in = 2 ft 8.1 in — the printed pair is consistent) | 815 mm is 2 ft 8.1 in, so the paired figures are consistent. |

### unit conversion - pressure (5)

<sub>✅ verified 4 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one kilogram per square centimetre expressed in psi | **14.28 psi** | 🟠 review | arithmetic (1 ÷ 0.070307 = 14.2233) | Standard value is 14.223 psi; the book's 14.28 is 0.4% high. |
| one psi expressed in kilograms per square centimetre | **0.07 kg/cm2** | ✅ verified | arithmetic (0.45359237 kg ÷ 6.4516 cm²) | 1 psi = 0.070307 kg/cm², which rounds to the printed 0.07. |
| one pound per square foot expressed in kilograms per square metre | **4.882 kg/sq m** | ✅ verified | arithmetic | 0.45359237 ÷ 0.3048² = 4.88243 kg/m², matching the printed 4.882. |
| one megapascal expressed in psi | **145.038 psi** | ✅ verified | arithmetic (1 N/mm² ÷ 6894.757 Pa/psi) | 1 MPa = 145.0377 psi, matching the printed 145.038 — this is the conversion that turns a BNBC f′c value into the psi figure a s… |
| one kilogram per square metre expressed in pounds per square foot | **0.205 lb/sq ft** | ✅ verified | arithmetic | 1 ÷ 4.88243 = 0.204816, which rounds to the printed 0.205. |

### brick class test (4)

<sub>🟠 review 4</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| maximum water absorption of a 1st class brick when soaked | **15 percent** | 🟠 review | PWD SoR 2022 item 03.1.1 — 'first class/picked jhama bricks (BDS 208)' (names the standard, not the limit) | Stated as an upper limit for 1st class brick. |
| water absorption of a 2nd class brick | **15 percent** | 🟠 review | BDS 208 — পোড়ামাটির ইট: শ্রেণিভেদে পানি শোষণ | Stated as 'more than 15%' — a lower bound, i.e. absorption above this marks 2nd class. |
| water absorption of a 3rd class brick | **25 percent** | 🟠 review | BDS 208 — পোড়ামাটির ইট: শ্রেণিভেদে পানি শোষণ | Stated as 'more than 25%'. |
| water absorption of a 1st class brick over 24 hours | **15 percent** | 🟠 review | PWD SoR 2022 item 03.1.1 — names BDS 208 for first class brick | Gives the soak duration (24 hours) that the earlier 15% figure omits. |

### brick size (4)

<sub>🟠 review 3 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| standard Bangla brick size in millimetres (PWD schedule) | **238 x 113 x 70 mm** | 🟠 review | PWD SoR 2022 item 04.6 — 241 mm x 114 mm x 70 mm | 238 × 113 × 70 mm is not the conversion of the book's own inch figure (which gives 241 × 114 × 70) and is 3 mm short of the siz… |
| brick size including mortar joint, in inches | **10 x 5 x 3 inches** | 🟠 review | arithmetic (10×5×3 in = 150 in³; 100 cft ÷ 150 in³ = 1152 bricks) | This is the nominal (brick + mortar) module used for quantity take-off. |
| brick size including mortar joint, in millimetres | **250 x 125 x 75 mm** | 🟠 review | arithmetic (10 in = 254 mm, rounded to 250) | 250 × 125 × 75 mm is the rounded metric form of the same nominal module (10 inches is really 254 mm), usable for quantity take-… |
| standard Bangla brick size in inches (PWD schedule) | **9.5 x 4.5 x 2.75 inches** | ✅ verified | PWD SoR 2022 item 04.6 — 'machine made bricks of approved size (241 mm x 114 mm x 70 mm)'; also lib/feature… | Cited to the PWD schedule; PWD schedules are revised, so re-check against the current schedule. |

### drainage (4)

<sub>🟠 review 3 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Diameter of soil, waste-water and rainwater pipes | **4 inches** | 🟠 review | PWD SoR 2022 items 26.56.3 "100 mm dia uPVC Y or T - Y Cleanout" and 26.56.4 "100 mm dia uPVC 'P' or 'S' tr… | Cast iron or PVC. The OCR reads "কাঠ আয়রন", almost certainly a mis-scan of "কাষ্ট আয়রন" (cast iron). |
| Size of the pit built at ground level to receive toilet pipes from the upper floors | **2x2x2 ft** | 🟠 review | PWD SoR 2022 item 26.70.4 — "Master-pit of Size: Clear 600 mm x 500 mm and average 750 mm depth for Septic … | The unit is not printed; feet is the only plausible reading. The book says "approximately". Verify against the printed page. |
| size of the pit built at ground level where the toilet stacks from each floor come down | **2 × 2 × 2 unit not printed (probably feet)** | 🟠 review | PWD SoR 2022 item 26.70.4 — 'Master-pit of Size: Clear 600 mm x 500 mm and average 750 mm depth for Septic … | The unit is missing in the source — feet is the likely reading given the rest of the chapter, but this is not certain. Do not s… |
| diameter of the soil, waste-water and rainwater pipes | **4 inches** | ✅ verified | PWD SoR 2022 items 26.56.3 '100 mm dia uPVC Y or T - Y Cleanout' and 26.56.4 '100 mm dia uPVC P or S trap';… | Book says cast iron or PVC. It gives one diameter for all three pipe types, which is a simplification. |

### estimating (4)

<sub>⛔ rejected 2 · 🟠 review 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| number of estimate types the book distinguishes (project, building, road) | **3** | ⛔ rejected | বইয়ের শ্রেণিবিভাগ — নাগরিকের কাজে লাগে না বলে বাদ দেওয়া হয়েছে | A textbook taxonomy of estimate types with nothing a homeowner watching a site can check or act on. |
| number of things an estimator must understand before preparing an estimate | **6** | ⛔ rejected | এস্টিমেটরের প্রস্তুতির তালিকা — নাগরিকের কাজে লাগে না বলে বাদ দেওয়া হয়েছে | A checklist count, not a measurement. |
| number of building estimate methods listed (item rate, plinth area rate, lump-sum rate) | **3** | 🟠 review | বইয়ের তালিকা: আইটেম রেট, প্লিন্থ এরিয়া রেট, লাম-সাম রেট — বইয়ে 'ইত্যাদি' লেখা, তাই তালিকা সম্পূর্ণ নয় | The book ends the list with 'ইত্যাদি' (etc.), so it does not claim the list is exhaustive. |
| number of cost heads a full building estimate must cover | **8** | 🟠 review | বইয়ের তালিকা: ৮টি খাত (মালামাল, পরিবহন, শ্রম, ভারা, যন্ত্রপাতি, পানি ও কর, সুপারভিশন, বিবিধ) — কোটেশন মিলি… | The eight heads: materials, transport, labour, scaffolding, plant, water supply and taxes, supervision, and miscellaneous (over… |

### herring bone bond (4)

<sub>🟠 review 3 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| sand needed for 100 sft of herring bone bond brickwork | **10 cft** | 🟠 review | arithmetic only (10 cft ÷ 100 sft = 1.2 in depth); PWD SoR item 03.2.1 does not break out materials | Specified as 'bhiti' (filling) sand. |
| masons needed for 100 sft of herring bone bond brickwork | **1 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | One mason-day per 100 sft of herringbone (twice the flat-soling figure, consistent with the extra cutting) is plausible but unc… |
| labourers needed for 100 sft of herring bone bond brickwork | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — সাইটভেদে বদলায়; ইঞ্জিনিয়ার যাচাই করেননি | Two labour-days per 100 sft is a plausible estimator figure with no source in the repo to check it against. |
| bricks needed for 100 sft of herring bone bond brickwork | **500 bricks** | ✅ verified | arithmetic using the brick size in lib/features/calculators/logic/brickwork.dart; PWD SoR 2022 item 03.2.1 … | Laid on edge a 9.5" × 2.75" brick with a 10 mm joint covers 0.216 sft, giving 463 bricks per 100 sft; the book's 500 adds about… |

### material per sft (4)

<sub>⛔ rejected 4</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Bricks required per square foot of an ordinary building | **48 bricks per sft** | ⛔ rejected | arithmetic (48 bricks at 241 x 114 x 70 mm plus joints is about 4.2 cft of masonry per sft of floor area; P… | 48 bricks per square foot is out by roughly five times: 48 bricks is about 4 cft of masonry, and a whole ordinary house uses on… |
| Cement required per square foot of an ordinary building | **0.14 bags per sft** | ⛔ rejected | arithmetic (0.14 bag = 7 kg cement per sft; cross-checked against the same table's brick and sand rows, whi… | The four-item per-square-foot table it belongs to does not hold together — the brick row is out by fivefold and the steel row's… |
| Sand required per square foot of an ordinary building | **0.35 cft per sft** | ⛔ rejected | arithmetic (0.14 bag cement to 0.35 cft sand is a 1:2 mix by volume, which cannot be squared with the 48-br… | Same broken table: 0.35 cft/sft is far below the sand an ordinary building takes per square foot of floor area, and it does not… |
| Steel rod required per square foot of an ordinary building | **0.14 maund (hundredweight) per sft** | ⛔ rejected | arithmetic (0.14 x 50.8 kg = 7.11 kg/sft; 0.14 x 37.32 kg = 5.22 kg/sft) | UNIT UNCERTAIN. "হন্দর" is an OCR-damaged unit; it most likely renders "হন্দর/hundredweight" (112 lb) but could be a mis-set মণ… |

### plinth area rate (4)

<sub>⛔ rejected 4</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Plinth (floor) area construction rate for the ground floor | **1500-2000 BDT per sft** | ⛔ rejected |  | STALE: a January 2019 price. Bangladesh material and labour costs have risen substantially since; do not show this as a current… |
| Plinth (floor) area construction rate for the first floor | **2000-2200 BDT per sft** | ⛔ rejected |  | STALE: January 2019 price, superseded. |
| Plinth (floor) area construction rate for the second floor | **2200-2400 BDT per sft** | ⛔ rejected |  | STALE: January 2019 price, superseded. |
| Plinth (floor) area construction rate for the third floor | **2200-2500 BDT per sft** | ⛔ rejected |  | STALE: January 2019 price, superseded. |

### rod lapping (4)

<sub>📐 rule of thumb 3 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| rod length beyond which a lap (splice) is required | **6 metres** | ⛔ rejected | arithmetic (6 m = 19.7 ft, against the 40 ft bar commonly stocked) | This is really about stock rod length, not a strength rule; laps in practice are governed by design, not by a fixed 6 m trigger. |
| lap length for a 3 suta (3/8 inch) rod | **18 inches** | 📐 rule of thumb | arithmetic (18 in ÷ 0.375 in = 48d) | Printed in a later chapter, not chapter 9. About 48 times the bar diameter. A shortcut only — lap length is a design quantity t… |
| lap length for a 5 suta (5/8 inch) rod | **25 inches** | 📐 rule of thumb | arithmetic (25 in ÷ 0.625 in = 40d, against 48d for the 3 suta row) | About 40 times the bar diameter — a different multiple from the 3 suta and 6 suta entries, so the three rows are not on one con… |
| lap length for a 6 suta (3/4 inch) rod | **34 inches** | 📐 rule of thumb | arithmetic (34 in ÷ 0.75 in = 45.3d) | About 45 times the bar diameter. |

### soil investigation (4)

<sub>⛔ rejected 3 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight of the auger used for the test pit / shaft method | **45 kg** | ⛔ rejected | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-২) পঞ্চম অধ্যায় — যন্ত্রপাতির বিবরণ, অ্যাপে দেখানো হয় না। | The weight of a testing tool is not something a homeowner standing on site can check or act on, and it teaches nothing about wh… |
| diameter of the wooden auger used for auger boring | **5 cm** | ⛔ rejected | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-২)(ঘ) পঞ্চম অধ্যায় — যন্ত্রপাতির বিবরণ, অ্যাপে দেখানো হয় না। | Tool-dimension trivia a citizen cannot verify or use on site; it does not help anyone judge whether the soil investigation was … |
| diameter of the pipe used with the auger in auger boring | **2.5 cm** | ⛔ rejected | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-২)(ঘ) পঞ্চম অধ্যায় — যন্ত্রপাতির বিবরণ, অ্যাপে দেখানো হয় না। | Same as the auger diameter — equipment detail with no checkable action behind it. |
| depth the hand auger described can bore to | **1 m** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-২) পঞ্চম অধ্যায় — হাতে চালানো অগার অগভীর, পূর্ণ মাটি পরীক্ষার বিকল্প নয়। | Worth keeping because it tells a reader a hand auger reaches only about a metre and so cannot stand in for a real bore log, but… |

### underground reservoir (4)

<sub>🟠 review 4</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Underground water reservoir size (L x W x depth) for a single-storey residential building | **6x4x4 ft** | 🟠 review | arithmetic (6 x 4 x 4 = 96 cft = 598 imperial gallons, matching the book's own 600 gallon row) | The size is internally consistent with the book's own capacity table (6x4x4 ft is 96 cft, about 598 imperial gallons, printed a… |
| Underground water reservoir size (L x W x depth) for a two-storey residential building | **6x5x5 ft** | 🟠 review | arithmetic (6 x 5 x 5 = 150 cft = 934 imperial gallons) | 6x5x5 ft is 150 cft, about 934 imperial gallons, a sensible step up from the one-storey size, but the storey-to-size mapping is… |
| Underground water reservoir size (L x W x depth) for a three-storey residential building | **7x5x5 ft** | 🟠 review | arithmetic (7 x 5 x 5 = 175 cft = 1,090 imperial gallons) | 7x5x5 ft is 175 cft, about 1,090 imperial gallons, which continues the book's own progression sensibly; the storey mapping itse… |
| Underground water reservoir size (L x W x depth) for a four-storey residential building | **9x6x5 ft** | 🟠 review | arithmetic (9 x 6 x 5 = 270 cft = 1,682 imperial gallons) | 9x6x5 ft is 270 cft, about 1,682 imperial gallons, consistent with the book's own reservoir table scale; the storey mapping is … |

### brick quantities (3)

<sub>🟠 review 1 · 📐 rule of thumb 1 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| cement mortar needed per 100 cft of brick masonry | **15 cft per 100 cft** | ⛔ rejected | arithmetic ((150 − 117.56) ÷ 150 = 21.6% of masonry volume) and lib/features/calculators/logic/brickwork.da… | 15 cft of mortar per 100 cft of masonry is low against common practice (roughly 25-30 cft); verify against the printed page bef… |
| weight of brickwork per cubic foot | **120 pounds per cft** | 🟠 review | arithmetic (120 lb/ft³ = 1922 kg/m³ ≈ 19 kN/m³) | 120 lb per cft is 1922 kg/m³, which sits right on the usual 19 kN/m³ taken for brick masonry, but no source in this repo states… |
| bricks needed per 100 cft of brick masonry | **1200 bricks per 100 cft** | 📐 rule of thumb | lib/features/calculators/logic/brickwork.dart (9.5×4.5×2.75 in brick, 0.394 in joint, 5% wastage → 1192 per… | Printed as an approximation ('প্রায়'). An estimator shortcut, not a design figure. |

### cement bag (3)

<sub>✅ verified 2 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight of one bag of cement in pounds | **112 lb** | 🟠 review | arithmetic (50 kg = 110.23 lb; 112 lb = 50.80 kg) | 112 lb is the pre-metric hundredweight bag; a 50 kg bag is 110.2 lb, so the book's two figures for the same bag differ by 1.6% … |
| volume of one bag of cement | **1.25 cft** | ✅ verified | lib/features/calculators/logic/units.dart — 'cftPerCementBag = 1.25', documented there as the accepted Bang… | This is the conversion that makes every 'bags of cement' coefficient in [৩-৪] usable by volume. |
| weight of one bag of cement in kilograms | **50 kg** | ✅ verified | lib/features/calculators/logic/units.dart — 'kgPerCementBag = 50.0', used by the concrete, brickwork and pl… | 112 lb is strictly 50.8 kg; 50 kg is the trade standard bag. |

### cement quantities (3)

<sub>✅ verified 2 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight of one bag of cement in pounds | **112 pounds** | 🟠 review | arithmetic (50 kg = 110.23 lb; 112 lb = 50.80 kg) | 112 lb is about 50.8 kg, so this is a rounded equivalent of the 50 kg bag, not an exact conversion. |
| weight of one bag of cement | **50 kg** | ✅ verified | assets/content/rates/prices.json id cement_pcc_bag — unit 'per 50 kg bag'; lib/features/calculators/logic/u… | The app already ships cement priced 'per 50 kg bag', and its calculators convert bags at 1.25 cft per 50 kg bag, so the figure … |
| bags of cement in one ton | **20 bags per ton** | ✅ verified | arithmetic (1000 ÷ 50 = 20) | Consistent with a 50 kg bag and a 1000 kg metric ton. |

### cement setting (3)

<sub>🟠 review 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| initial setting time of cement | **45 minutes** | 🟠 review | BDS EN 197-1 / BNBC 2020, পার্ট ৫ — সিমেন্টের প্রাথমিক সেটিং সময় (সর্বনিম্ন সীমা) | Stated twice in the chapter with the same value. |
| final setting time of cement | **10 hours** | 🟠 review | BDS EN 197-1 / BNBC 2020, পার্ট ৫ — সিমেন্টের চূড়ান্ত সেটিং সময় (সর্বোচ্চ সীমা) | Stated twice in the chapter with the same value. |
| time cement needs in a wet/moist state to harden fully | **28 days** | 🟠 review | BNBC 2020, পার্ট ৫ ও ৬ — ২৮ দিনের শক্তি | Given as a minimum ('কমপক্ষে') and equated to 4 weeks. |

### consultant fee (3)

<sub>📐 rule of thumb 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Design fee as a share of building cost | **6 percent** | 📐 rule of thumb | arithmetic (6+1 = the 7% total the book prints) | 2019 fee convention; consultant fee practice may have changed. |
| Construction supervision fee as a share of building cost | **1 percent** | 📐 rule of thumb | arithmetic (6+1 = 7%, the printed total) | Design plus supervision is printed as a 7% total. |
| Total consultant fee (design plus supervision) | **7 percent** | 📐 rule of thumb | arithmetic (6+1 = 7%) | The sum of the two fee lines, and it checks out at 7%; still a 2019 convention, not a rate anyone is bound to. |

### damp proofing (3)

<sub>⛔ rejected 1 · ✅ verified 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| thickness of the damp-proof course (DPC) cast on the plinth wall | **1 or 1.5 inches** | ⛔ rejected | PWD SoR 2022 item 03.6.1 — '75 mm thick damp proof course (1:1.5:3) with cement, Sylhet sand (F.M. 2.2) and… | Outside chapters 4/5/6/11/15 (it is in chapter 14) but captured because damp-treatment figures were in scope. DPC is the moistu… |
| waterproofing compound (pudlo) added to the DPC concrete, as a share of cement | **5 percent** | 🟠 review | PWD SoR 2022 item 03.6.2 — '150 mm thick damp proof course (1:1.5:3) with cement, Sylhet sand (F.M. 2.2), s… | Printed 'পাডলু' = Pudlo, a brand-style name for an integral waterproofing admixture. The sentence is ambiguous about whether 5%… |
| concrete mix ratio (cement : sand : khoa) for the damp-proof course | **1:2:4 or 1:1.5:3** | ✅ verified | PWD SoR 2022 item 03.6.1 — '75 mm thick damp proof course (1:1.5:3) with cement, Sylhet sand (F.M. 2.2) and… | Elsewhere the book's mix tables give 1:1.5:3 for DPC and its curing table gives 1:2:4 — both ratios appear across the book, con… |

### electrical sockets (3)

<sub>🟠 review 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Number of 15-ampere sockets for a bedroom | **1 sockets** | 🟠 review | সূত্র: [১১-১](৪), BNBC-র বরাত দিয়ে। BNBC ২০২০-এ কোড বদলেছে — সর্বনিম্ন সংখ্যা, লক্ষ্য নয়। | Attributed to BNBC; the code was revised in 2020, after this book. |
| Number of 15-ampere sockets for a verandah | **1 sockets** | 🟠 review | সূত্র: [১১-১](৪), BNBC-র বরাত দিয়ে। বারান্দার সকেট আবহাওয়া-নিরোধক হতে হবে — BNBC ২০২০ দেখুন। | Attributed to BNBC; the code was revised in 2020, after this book. |
| Rating of the sockets in the room-by-room socket table | **15 amperes** | 🟠 review | PWD Electro-Mechanical SoR 2022 items 3.18.1 (aerial fuse up to 15 amps) and 4.32.1 (cut-out, 15 amps ratin… | 15 A is a standard socket rating in Bangladeshi practice and the rating that makes the room-count table readable, but the repo'… |

### labour cost (3)

<sub>⛔ rejected 2 · 📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Labour cost as a share of total building cost (thumb rule) | **15 percent** | ⛔ rejected |  | Conflicts with the book's own chapter 8 tables, which give labour as 31% ([৮-৪]) and mason+labour as 20% ([৮-৫]). Do not presen… |
| Labour (mason and worker) cost as a share of building cost | **31 percent** | ⛔ rejected | arithmetic (the table's seven items total 108%) | The book's single largest labour figure. It conflicts with the 15% thumb rule in the appendix and the 20% in [৮-৫]. If the app … |
| Mason and labour cost as a share of construction cost | **20 percent** | 📐 rule of thumb | arithmetic (the six items of [৮-৫](খ) sum to exactly 100%, unlike [৮-৪]'s 108%) | Third of the book's three labour figures (15% appendix, 31% in [৮-৪], 20% here). They are not reconcilable as printed. |

### mosaic mix ratio (3)

<sub>🟠 review 1 · 📐 rule of thumb 1 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Ratio stated for colouring marble in floor mosaic | **8:1** | ⛔ rejected | ব্যবহার করবেন না — বইয়ে ৮ ও ১ কীসের অনুপাত তা লেখা নেই | The book's note says only "the ratio of colouring marble" and does not name both components, so what the 8 and the 1 refer to i… |
| Cement-to-marble-chips ratio for grey mosaic | **1:1** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-৩] — প্রকৌশলী যাচাই করেননি | Cement : marble. |
| White cement to grey cement ratio for floor mosaic | **10:1** | 📐 rule of thumb | PWD SoR 2022 items 05.1.1 ("using 100% white cement") and 05.1.2 ("using 100% grey cement") | The book's own note defines 10:1 as white cement : grey cement. |

### rod usage by member (3)

<sub>🟠 review 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| rod size used for house/building slab reinforcement | **3 or 4 suta** | 🟠 review | arithmetic (3 suta = 3/8 in, 4 suta = 1/2 in at 1 suta = 1/8 in) | Sample table only; the book says the designer must approve. Never present as a substitute for a structural design. |
| rod size used for column, foundation footing and beam reinforcement | **5 or more suta** | 🟠 review | arithmetic (5 suta = 5/8 in) | Only the 5-suta (5/8") diameter is given, though the text says 5 suta or more. |
| rod size used for stirrups (binding rods) in beams and columns | **2 or 3 suta** | 🟠 review | arithmetic (2 suta = 1/4 in, 3 suta = 3/8 in) | 2 or 3 suta stirrups match common practice and the inch equivalents check out, but stirrup size and spacing are both design qua… |

### site selection (3)

<sub>⛔ rejected 1 · 📐 rule of thumb 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| minimum width of the road in front of a construction plot, stated as a RAJUK requirement | **15 ft** | ⛔ rejected | রাজউক ইমারত নির্মাণ বিধিমালার প্রযোজ্য ধারা নিজে যাচাই করুন — অ্যাপ কোনো নির্দিষ্ট সংখ্যা দেখাচ্ছে না, কারণ… | Book is Jan 2019 and cites RAJUK generally without naming a clause; RAJUK/BNBC access-road rules have been revised since, so ve… |
| lane/road width the book says a planned housing society keeps as standard | **15 ft** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [৬-৫](ক) ষষ্ঠ অধ্যায় — প্রচলিত অভ্যাস, আইনি ন্যূনতম নয়। | Matches the 15 ft front-road figure in chapter 4. |
| depth of earth fill on a filled plot up to which foundation cost stays reasonable | **7 ft** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [৪-২] বিঃদ্রঃ — খরচের আন্দাজ, ডিজাইনের নিয়ম নয়। | An estimator's rule of thumb about cost, not a design limit. The book says beyond this depth foundation cost rises; it gives no… |

### soil classification (3)

<sub>🟠 review 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| particle size above which the book calls the material a boulder | **20 cm** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-১) পঞ্চম অধ্যায় — বইয়ের নিজস্ব সরল শ্রেণিবিভাগ। | Nothing in the repo defines particle-size classes, and the book's 20 cm boulder threshold is well below the ~30 cm boundary sta… |
| particle size range the book calls gravel | **3 mm to 20 cm mm/cm** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-১) পঞ্চম অধ্যায় — বইয়ের নিজস্ব সরল শ্রেণিবিভাগ। | The 3 mm–20 cm gravel band is the book's own simplification of a range that standard practice splits into gravel and cobble, an… |
| particle size below which the book calls the material sand | **3 mm** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, (১-১) পঞ্চম অধ্যায় — সাধারণ প্রকৌশল হিসাবে সীমারেখা ৪.৭৫ মি.মি.। | Standard geotechnical practice puts the sand/gravel boundary near 4.75 mm; the book's 3 mm is its own simplification. |

### steel rod grade (3)

<sub>🟠 review 2 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| number of steel rod grades in common use | **2 grades** | ⛔ rejected | PWD SoR 2022 items 08.1.1, 08.1.2, 08.1.3 — Grade 300 (B300DWR), Grade 400 (B400DWR/B420DWR), Grade 500 (B5… | The shipped SoR prices three reinforcement grades, not two, so telling a reader there are only two would leave out Grade 500 — … |
| lower of the two commonly used steel rod grades | **40 grade** | 🟠 review | PWD SoR 2022 item 08.1.1 — 'Grade 300 (B300DWR: complying BDS ISO 6935-2:2016 / ASTM A615)' | Book from 2019; grade-40 mild steel is now largely displaced by grade 60 and above in Bangladesh practice. Verify against curre… |
| higher of the two commonly used steel rod grades | **60 grade** | 🟠 review | PWD SoR 2022 items 08.1.2 (Grade 400 / B420DWR) and 08.1.3 (Grade 500 / B500DWR) | Grades above 60 (e.g. 500W) are in market use since publication; the two-grade list may be incomplete today. |

### walls (3)

<sub>🟠 review 2 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Spacing of brick pillars along a 5-inch wall, and the pillar size | **10 ft spacing** | 🟠 review | PWD SoR 2022 items 04.15 / 04.16 (125 mm brick work "...and making bond with") confirm the wall type but no… | OCR prints "৫ ওয়ালে" without the inch mark; read as a 5-inch wall from context. Pillar cross-section is 10 in x 10 in. |
| Cross-section of the brick pillar built into a 5-inch wall | **10x10 inches** | 🟠 review | PWD SoR 2022 item 04.7 (brick size 241 mm x 114 mm x 70 mm) — 10 in (254 mm) is about one brick length square | 10 in x 10 in is close to one brick length square (SoR standard brick is 241 mm long, 10 in is 254 mm), so the size is buildabl… |
| Partition wall thickness that needs no separate foundation | **5 inches** | ✅ verified | PWD SoR 2022 item 04.19 — "Providing 125 mm thick brick work in superstructure (partition walls) with cemen… | The PWD schedule carries 125 mm (5 in) partition brickwork as a superstructure item, i.e. built off the slab with no separate f… |

### water demand (3)

<sub>📐 rule of thumb 3</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Minimum water requirement per person per day | **10 gallons per person per day** | 📐 rule of thumb | arithmetic (10 imperial gallons = 45.5 litres) | 10 imperial gallons is 45 litres per person per day — a survival floor, roughly a third of the 150-200 litres per head that urb… |
| average water a person uses in a day | **30 gallons per person per day** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, অতিরিক্ত অধ্যায়-৩, প্রশ্ন ৮৩ — গড় ব্যবহারের আন্দাজ। | Conflicts with the appendix figure of a 10 gallon per person per day minimum. These are different quantities — average use vers… |
| minimum water required per person per day for tank sizing | **10 gallons per person per day** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, পরিশিষ্ট [৫-০](৪)(খ) — ট্যাংকের মাপ বের করার সর্বনিম্ন ধরা। | See the 30-gallon row: the book gives both figures without reconciling them. Neither is tied to a code here. |

### beam (2)

<sub>📐 rule of thumb 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Minimum beam width | **10 inches** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০]। ইঞ্জিনিয়ার যাচাই করেননি — নকশার মাপই চূড়ান্ত। | A 10 in (250 mm) minimum beam width is consistent with fitting two layers of bar plus cover inside a 10 in wall, and is common … |
| Beam depth in inches equals the beam span in feet (14 ft span = 14 in deep) | **1 inch depth per ft of span** | 📐 rule of thumb | অনুমানের শর্টকাট — [৭-০] থাম্ব রুলস (১)(ঢ)। বিমের গভীরতা আসে স্পান, লোড ও রডের নকশা থেকে — শুধু স্পান থেকে … | Sizing shortcut only; actual beam depth must come from structural design. |

### brick field test (2)

<sub>🟠 review 1 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| drop height in the two-brick T-shaped field drop test onto level ground | **6 feet** | ⛔ rejected | BNBC 2020, পার্ট ৫ — ইটের শ্রেণি ও শক্তি | Conflicts with the 3 ft figure in [৯-৫](খ)(১). Also a safety concern: this is a field test the app would be telling a non-engin… |
| drop height from which a 1st class brick should not break easily (identification list) | **3 feet** | 🟠 review | BNBC 2020, পার্ট ৫ — ইটের শ্রেণি ও শক্তি | The book gives 3 ft here but 6 ft in the field-test list [৯-৫](গ)(২); the two passages disagree. Flag both to a reviewer before… |

### brick strength (2)

<sub>🟠 review 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| crushing strength of a 1st class brick | **200 kg per square cm** | 🟠 review | arithmetic (200 kg/cm² = 19.6 MPa) | 200 kg/cm² is 19.6 MPa, above the minimum usually required of first class brick, and it is a laboratory result a citizen cannot… |
| crushing strength of a picket brick | **210 kg per square cm** | 🟠 review | arithmetic (210 kg/cm² = 20.6 MPa) | 210 kg/cm² (20.6 MPa) is only 5% above the first class figure, which is oddly close for overburnt picket brick, and no repo sou… |

### ceramic brick (2)

<sub>🟠 review 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| hole counts of machine-made ceramic bricks used in better-quality walls | **3, 10, 13 holes** | 🟠 review | PWD SoR 2022 items 04.6 and 04.24 — '10 holes machine made bricks' / '10 hole machine made ceramic bricks' | The shipped SoR prices 10-hole machine made bricks, so that one is real, but nothing in the repo confirms the 3-hole and 13-hol… |
| size of red facing brick used decoratively on exposed brickwork | **8 x 4 x 2 inches** | 🟠 review | বাজারে প্রচলিত ফেসিং ইটের মাপ — যাচাই বাকি | An 8 × 4 × 2 inch facing brick is a real market product but does not appear anywhere in the shipped SoR, so it ships unconfirmed. |

### concrete strength (2)

<sub>📐 rule of thumb 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Compressive strength attributed to the 1:2:4 RCC mix | **2600 psi** | 📐 rule of thumb | PWD SoR 2022 item 07.7.1 (strength class tied to minimum cement content, not a ratio); shipped checklist bu… | Attaching a psi number to a volumetric mix with no cylinder-test basis is exactly the shortcut that lets a contractor claim str… |
| Compressive strength attributed to the 1:1.5:3 RCC mix | **2900 psi** | 📐 rule of thumb | PWD SoR 2022 item 07.8.1 (Ready-Mix RCC priced by approved strength class); guide.json card m4c2 already wa… | A ratio cannot deliver a guaranteed psi — cement quality, water content, aggregate and compaction all move it — so 2900 psi mus… |

### foundation (2)

<sub>📐 rule of thumb 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Foundation depth below ground, in feet, equals the number of storeys (4-storey building = 4 ft deep) | **1 ft per storey** | 📐 rule of thumb | অনুমানের শর্টকাট — বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০]। ভিত্তির গভীরতা মাটি পরীক্ষা ও ইঞ্জিনিয়ারে… | Estimator shortcut only, not a design method. Real foundation depth depends on soil bearing capacity and must come from a soil … |
| Foundation width in inches equals 10 inches per storey (3-storey = 30 in wide) | **10 inches per storey** | 📐 rule of thumb | অনুমানের শর্টকাট — [৭-০] থাম্ব রুলস (১)(খ)। প্রস্থ আসে মাটির ভারবহন ক্ষমতা ও নকশা থেকে। | The Bangla phrasing is awkward in the OCR but the worked example (3 storeys = 30 inches) confirms 10 in per storey. |

### jolchhad thickness (2)

<sub>✅ verified 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Usual thickness range of jolchhad, said to depend on roof area and rainfall | **3-4 inch** | 🟠 review | PWD SoR 2022 item 17.4 — "Average 100 mm thick finished lime terracing"; arithmetic: 3 in = 76 mm, 4 in = 1… | Given as an average range; an earlier passage states a flat 3 inches and [১২-৩] states 4 inches. |
| Thickness of jolchhad layer | **4 inch** | ✅ verified | PWD SoR 2022 item 17.4 — "Average 100 mm thick finished lime terracing"; arithmetic: 100 mm = 3.94 in | The book is inconsistent: elsewhere it states 3 inches, and section [১-১৪] gives an average range of 3 to 4 inches depending on… |

### khoa size (2)

<sub>✅ verified 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| minimum size of khoa for concrete work | **1/4 inches** | 🟠 review | BNBC 2020, পার্ট ৫ — মোটা দানার সামগ্রীর গ্রেডেশন | The SoR specifies khoa by its maximum ('downgraded') size only and states no lower bound, so the 1/4 inch minimum is uncorrobor… |
| maximum size of khoa (broken burnt picked jhama brick) for concrete work | **3/4 inches** | ✅ verified | PWD SoR 2022 items 04.25 ('19 mm downgraded' brick chips) and 17.4 ('20 mm downgraded first class brick chi… | 3/4 inch is 19.05 mm, and the current SoR prices concrete and terracing work with exactly 19 mm and 20 mm downgraded brick chip… |

### lift (2)

<sub>📐 rule of thumb 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| building height above which the book says a lift is installed | **6 storeys** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [১১-৩](ক) একাদশ অধ্যায় — প্রচলিত অভ্যাস; আইনি শর্ত ভবনের উচ্চতা ধরে হিসাব … | Phrased as common practice. The book's own chapter 7 states a different, regulatory trigger (buildings over 15 m). Where a rule… |
| building height at which the book calls lifts indispensable (high-rise) | **15 to 16 storeys** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [১১-৩](ক) একাদশ অধ্যায় — বর্ণনামূলক, বাধ্যতামূলক নয়। | A loose descriptive band for when lifts become unavoidable, with no code behind it. |

### maintenance (2)

<sub>📐 rule of thumb 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| how often whitewash, colour wash and normal repairs are done | **1 times per year** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [১৫-১](ক) পঞ্চদশ অধ্যায় — প্রচলিত অভ্যাস। | A maintenance habit, not a specification — the real interval depends on exposure, finish and how the last coat held. |
| interval for the larger repair round (wall and joinery painting, patching plaster cracks) | **4 years** | 📐 rule of thumb | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [১৫-১](খ) পঞ্চদশ অধ্যায় — প্রচলিত অভ্যাস। | Same as the annual cycle — a planning habit for budgeting repairs, with no engineering criterion behind the four years. |

### mosaic thickness (2)

<sub>🟠 review 1 · ⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Floor mosaic thickness used in the thumb-rule estimate | **0.75 inch** | ⛔ rejected | arithmetic (3/4 in = 19.05 mm; 10 mm ≈ 3/8 in); nearest PWD reference: item 05.10.1, 20 mm finished terrazz… | Unit mismatch in the source: 3/4 inch is 19 mm, not 10 mm. Either the inch or the mm figure is wrong (10 mm would be about 3/8 … |
| Thickness of grey mosaic layer | **0.5 inch** | 🟠 review | Nearest reference only: PWD SoR 2022 item 05.10.1 — "200 mm x 200 mm x 20 mm (finished) mosaic terrazzo til… | Conflicts with the chapter 3 thumb rule, which uses 3/4 inch floor mosaic. |

### overhead tank (2)

<sub>✅ verified 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Overhead water tank size | **4x4x4 ft** | ✅ verified | arithmetic (64 cft / 0.16054 cft per imperial gallon = 399 gallons; the book's 6x4x4 ft = 96 cft = 598 gall… | The book calls this a 400-gallon GI/plastic tank, but 4x4x4 ft is 64 cft, which is roughly 400 imperial gallons only if read lo… |
| Capacity of the recommended overhead GI/plastic tank | **400 gallons** | ✅ verified | arithmetic (4 x 4 x 4 = 64 cft = 399 imperial gallons) | The book names a brand of tank; capacity recorded, brand not carried over. See the size caveat above. |

### painting (2)

<sub>✅ verified 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| number of stages in the painting procedure (prime coat, under coat, finish coat) | **3 stages** | ✅ verified | PWD SoR 2022 items 16.14.1 ('02 coats ... as base coat & finishing coat over a single layer'), 16.9.1 ('thr… | The shipped SoR prices painting exactly this way — coats applied over a priming coat — for example self-levelling epoxy as a ba… |
| number of finish coats applied at the final stage | **1 to 2 coats** | ✅ verified | PWD SoR 2022 items 32.47.1 (interior acrylic emulsion: 1 coat) and 32.48.1 (same paint: 2 coat) | The shipped SoR prices one-coat and two-coat variants of the same finish side by side, so 'one or two finish coats' is exactly … |

### patent stone thickness (2)

<sub>✅ verified 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Thickness of patent stone layer | **1-1.5 inch** | ✅ verified | PWD SoR 2022 items 04.26/04.28 (25 mm) and 04.27/04.29 (38 mm); arithmetic: 25 mm = 0.98 in, 38 mm = 1.50 in | Elsewhere the book gives 1 inch (25 mm) in the chapter 3 thumb rule and 1/2 inch in the chapter 13 method text — three differen… |
| Patent stone floor thickness used in the thumb-rule estimate | **1 inch** | ✅ verified | arithmetic (1 in = 25.4 mm) plus PWD SoR 2022 item 04.26 — "25 mm thick artificial patent stone (1:2:4) flo… | 1 inch = 25 mm, correct. [১২-৪] gives a 1 to 1.5 inch range and the chapter 13 method text gives 1/2 inch. |

### rod binding wire (2)

<sub>⛔ rejected 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| G.I. wire gauge specified for tying reinforcement | **26 gauge** | ⛔ rejected | PWD SoR 2022 item 02.5 — '20 BWG G.I. wire' used for palisading; arithmetic (26 SWG = 0.46 mm, 22 SWG = 0.7… | Conflicts with the 22 gauge (22 SWG) given for tying slab, column and beam rods in the chapter 13 rod-laying list. Both figures… |
| wire gauge specified for tying slab, column and beam rods firmly in place | **22 gauge** | 🟠 review | PWD SoR 2022 item 02.5 — '20 BWG G.I. wire'; arithmetic (22 SWG = 0.71 mm, 20 BWG = 0.89 mm) | Conflicts with the 26 gauge given in [৯-৯] and in the note under table [৯-২]. Two different gauges for the same job in one book… |

### sand acceptance test (2)

<sub>🟠 review 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| lower end of the acceptable fineness modulus range for good sand | **1.50 F.M.** | 🟠 review | PWD SoR 2022 items 04.1 and 15.1.1 — F.M. 1.2 sand specified for mortar and plaster | Range is stated as 1.50 to 2.50 for good sand generally, not per work type. |
| upper end of the acceptable fineness modulus range for good sand | **2.50 F.M.** | 🟠 review | PWD SoR 2022 item 03.6.1 — Sylhet sand F.M. 2.2 | The 2.50 ceiling is above the F.M. 2.2 Sylhet sand the SoR names for concrete, so it is not contradicted, but nothing in the re… |

### sand blending (2)

<sub>📐 rule of thumb 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| share of Sylhet sand in the recommended concrete sand blend | **1/3** | 📐 rule of thumb | সাইটে প্রচলিত অভ্যাস — নকশায় নির্দিষ্ট এফ.এম. থাকলে সেটাই মানতে হবে | Blend is 1/3 Sylhet sand to 2/3 other coarse sand; stated as giving good results, not as a designed mix. |
| share of other coarse sand in the recommended concrete sand blend | **2/3** | 📐 rule of thumb | arithmetic (1/3 + 2/3 = 1) | The two-thirds share is only the complement of the Sylhet share and carries the same status: a mixing habit, not a specification. |

### shuttering (2)

<sub>📐 rule of thumb 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Minimum days before removing beam shuttering, regardless of span | **14 days** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০]। BNBC ২০২০ পার্ট ৬-এর সঙ্গে মিলিয়ে নিন — ইঞ্জিনিয়ার য… | 14 days as a floor for striking beam formwork matches the striking-time convention widely used for beam props, but the repo hol… |
| Days before removing beam shuttering equals the span in feet (1 day per foot of span) | **1 day per ft of span** | 📐 rule of thumb | arithmetic (14 ft span gives 14 days; 20 ft gives 20 days, close to the usual 21 days for beams spanning ov… | A striking-time shortcut: it happens to track the standard formwork table closely (a 20 ft / 6 m beam lands near 21 days), but … |

### stair (2)

<sub>🟠 review 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| stair riser height (the vertical face of one step) | **6 inches** | 🟠 review | arithmetic (2 × 6 + 10 = 22 in against the 24-25 in comfort rule; rise/tread angle = 31 degrees) | 6 in riser with a 10 in tread is a steeper stair than BNBC residential guidance generally allows; check the current code before… |
| stair tread depth (the horizontal part you step on) | **10 inches** | 🟠 review | arithmetic (10 in = 254 mm; 2R+T = 22 in) | See the riser note — the 6 in / 10 in pairing should be checked against the current code. |

### stone chips size (2)

<sub>✅ verified 1 · 🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| minimum size of stone chips / shingles used in pile foundation work | **1/4 inches** | 🟠 review | BNBC 2020, পার্ট ৫ — মোটা দানার সামগ্রীর গ্রেডেশন | No lower size bound for stone chips appears in the SoR, so the 1/4 inch minimum cannot be corroborated from this repo. |
| maximum size of stone chips / shingles used in pile foundation work | **3/4 inches** | ✅ verified | PWD SoR 2022 items 24.11, 24.12 and 24.14 — '20 mm downgraded stone-chips' | Same limits as khoa; use per design. |

### unit conversion - density (2)

<sub>🟠 review 1 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one pound per cubic foot expressed in kilograms per cubic metre | **16.08 kg/cubic m** | 🟠 review | arithmetic | Standard value is 16.018; the book's 16.08 is 0.4% high. |
| one kilogram per cubic metre expressed in pounds per cubic foot | **0.062 lb/cft** | ✅ verified | arithmetic | 1 ÷ 16.0185 = 0.062428, which rounds to the printed 0.062. |

### unit conversion - linear weight (2)

<sub>🟠 review 1 · ✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one pound per foot expressed in kilograms per metre | **1.48 kg/m** | 🟠 review | arithmetic | 0.45359237 ÷ 0.3048 = 1.4882 kg/m, so 1.48 is a truncation rather than a correct rounding (which would be 1.49) and runs 0.55% … |
| one kilogram per metre expressed in pounds per foot | **0.672 lb/ft** | ✅ verified | arithmetic | 1 ÷ 1.48816 = 0.67197, which rounds exactly to the printed 0.672. |

### unit conversion - volume (2)

<sub>✅ verified 2</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one cubic foot expressed in cubic metres | **0.0283 cubic m** | ✅ verified | arithmetic + lib/features/calculators/logic/units.dart (m3PerCft = 0.028316846592) | 0.3048³ = 0.0283168 m³, which rounds to 0.0283 and is the constant the app already ships. |
| one cubic metre expressed in cubic feet | **35.315 cft** | ✅ verified | arithmetic + lib/features/calculators/logic/units.dart | 1 ÷ 0.0283168 = 35.3147 cft; 35.315 is a correct rounding. |

### DPC thickness (1)

<sub>📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Thickness of damp-proof course | **1.5 inch** | 📐 rule of thumb | PWD SoR 2022 items 03.6.1 (75 mm) and 03.6.2 (150 mm); arithmetic: 1.5 in = 38.1 mm, so the book's "40 mm" … | The book equates 1.5 inch to 40 mm; the exact conversion is 38 mm, so 40 mm is a rounded site figure. |

### RCC casting (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| extra masons and extra labourers needed for making the reinforcement cage | **2 persons** | 🟠 review | এস্টিমেটরের প্রচলিত হিসাব — রডের খাঁচার জন্য বাড়তি ২ মিস্ত্রী ও ২ লেবার; ইঞ্জিনিয়ার যাচাই করেননি | The single figure 2 covers both trades (2 extra masons and 2 extra labourers). Printed as a footnote to the 1:1.5:3 RCC item; t… |

### aggregate size (1)

<sub>⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Khoa (brick chip) size used in patent stone floor concrete | **0.75 inch** | ⛔ rejected | PWD SoR 2022 item 04.25 ("75 mm thick cement concrete (1:3:6) ... 19 mm downgraded [chips]") versus items 0… | Same passage gives the patent stone layer as 1/2 inch thick, which conflicts with the 1 to 1.5 inch figures elsewhere — a 3/4 i… |

### cement handling (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| time after adding water within which cement mix must be placed, before strength starts to be lost | **30 minutes** | 🟠 review | BNBC 2020, পার্ট ৬ — মেশানোর পর ঢালাই দেওয়ার সময়সীমা | Note this is shorter than the 45-minute initial setting time also given in the same section; the book does not reconcile the two. |

### compaction (1)

<sub>📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Minimum compaction time for filled earth before casting the floor slab | **1.5 months** | 📐 rule of thumb | PWD SoR 2022 items 02.10.1-02.10.4 — "Sand filling in foundation trenches and plinth ... in 150 mm layers i… | Waiting is not compaction — filled earth is made stable by placing it in thin layers and compacting each one, and 1.5 months of… |

### concrete thickness (1)

<sub>✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Thickness of ground-floor concrete casting over brick soling | **3 inch** | ✅ verified | PWD SoR 2022 item 04.25 — "75 mm thick cement concrete (1:3:6) flooring with cement, best quality coarse sa… | Cast at 1:3:6, matching the ground-floor row of [১২-৪]. |

### cost comparison (1)

<sub>⛔ rejected 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Extra cost of an RCC frame structure over a 10-inch load-bearing brick wall structure | **15-20 percent** | ⛔ rejected |  | A 2019-era cost relationship; relative material and labour prices have moved since. |

### gas supply (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| diameters of the MS pipe used for the domestic gas supply line to burners | **1/2, 3/4, 1 inches** | 🟠 review | বাড়ি নির্মাণ ও সাইট সুপারভিশন, [১১-৫](ক) একাদশ অধ্যায় — গ্যাস লাইনের কাজ শুধু গ্যাস কোম্পানির অনুমোদিত ঠি… | Three sizes listed together without saying which goes where. Gas work must be done by the gas utility's approved contractor per… |

### jolchhad (lime terracing) mix ratio (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Lime : surki : khoa ratio for jolchhad (lime-terrace roof layer) | **2:2:7** | 🟠 review | PWD SoR 2022 item 17.4 — "Average 100 mm thick finished lime terracing with 20 mm downgraded first class br… | The same 2:2:7 is repeated in the Q&A section (Q67) and in section [১-১৪], so the value is well corroborated within the book. Q… |

### khoa (1)

<sub>✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| bricks required to produce 100 cft of khoa | **850 bricks per 100 cft** | ✅ verified | arithmetic using the BDS brick size in lib/features/calculators/logic/brickwork.dart (850 × 0.0681 cft = 57… | 850 standard bricks give 57.8 cft of solid clay, which broken into chips with the usual 35-40% voids fills about 93 cft — so 85… |

### khoa quantities (1)

<sub>📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| picket jhama bricks that must be broken to make 100 cft of khoa | **850 bricks per 100 cft** | 📐 rule of thumb | arithmetic (850 × 117.56 in³ = 57.8 cft solid; 57.8/100 implies 42% voids) | 850 bricks hold up as an ordering estimate — their solid volume is 57.8 cft, which fills 100 cft of loose khoa at about 42% voi… |

### labour engagement (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| number of ways labour is engaged (daily-rate work and measured work) | **2** | 🟠 review | বইয়ের শ্রেণিবিভাগ: রোজ (দিনমজুরি) ও মাপে কাজ (চুক্তি) — দুই ধরনের চুক্তিতে তাগিদ আলাদা | The two methods are daily-rate (রোজ) engagement and measured/piece-rate (মাপে কাজ) engagement. |

### masonry (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Maximum height of brick masonry that may be built in one go | **4.5 feet** | 🟠 review | PWD SoR 2022 item 04.11 mentions free wall height beyond 4 m only for pricing, not a daily lift limit | A limit on masonry lift height, related to mortar setting; no time window is stated beyond "at one time". |

### mixing water (1)

<sub>📐 rule of thumb 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Water added per bag of cement in concrete mixing | **20-25 litres per bag** | 📐 rule of thumb | arithmetic (20 ÷ 50 = 0.40, 25 ÷ 50 = 0.50 by weight, if the bag is 50 kg — which the book does not state);… | Given identically for 1:3:6 CC, 1:2:4 RCC and 1:1.5:3 RCC. It is a site estimator, not a water-cement ratio specification; a st… |

### mosaic base thickness (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Thickness of the concrete base under mosaic flooring | **1 inch** | 🟠 review | বই: বাড়ি নির্মাণ ও সাইট সুপারভিশন [১২-৪] — প্রকৌশলী যাচাই করেননি | No shipped PWD item states the thickness of the concrete base under mosaic flooring, so the 1 inch stands on the book alone. |

### plinth (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| Plinth level height above the existing road level | **1.5-2.0 ft** | 🟠 review | সূত্র: বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), [৭-০]। ইঞ্জিনিয়ার যাচাই করেননি — এলাকার বন্যার স্তর দেখে ঠিক… | Range: 1 ft 6 in to 2 ft 0 in. |

### steel rod quantities (1)

<sub>✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| kilograms of steel rod in one ton | **1000 kg per ton** | ✅ verified | arithmetic (1 tonne = 1000 kg); PWD SoR 2022 chapter 8 rates in kg and 09.9.x in tonne | Metric ton. |

### timber (1)

<sub>🟠 review 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| timber needed for 100 sft of panel door | **15 cft per 100 sft** | 🟠 review | arithmetic (15 cft ÷ 100 sft = 0.15 ft = 1.8 in average thickness) | 15 cft per 100 sft is an average 1.8 inch of solid timber across the door area, which only makes sense if the frame (chowkath) … |

### unit conversion - land area (1)

<sub>✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| one acre expressed in square feet | **43560 sq ft** | ✅ verified | arithmetic; consistent with the book's own Table (৩-১) land ladder (1 katha 720 sft × 60.5 = 43,560) | Repeated in Table (৩-১) as ৪৩,৫৬০ বর্গফুট. |

### water (1)

<sub>✅ verified 1</sub>

| Subject | Value | Verdict | Checked against / citation | Note |
|---|---|---|---|---|
| weight of 1 cubic foot of water | **62.4 pounds** | ✅ verified | arithmetic (1000 kg/m³ = 62.428 lb/ft³) | Water at 1000 kg per cubic metre works out to 62.428 lb per cubic foot, so 62.4 is the correct rounded value. |

---

## B. The 1000 MT godown type design (Directorate General of Food, Aug 2024)

**These are one type design's figures, not a national standard.** The set is a working drawing for
"Construction of New Food Godowns with ancillary facilities in Different Strategic Locations Across
The Country", so the same dimensions recur at many sites — but a reader must never be told that
4'-0" is *the* gangway width. The card that carries any of these teaches the method:

> আপনার সাইটের অনুমোদিত নকশাটা চান। তাতে মাপটা কত লেখা আছে দেখুন। তারপর ফিতে দিয়ে মিলিয়ে নিন।
> *(Ask for your site's approved drawing. Find the dimension on it. Then measure.)*

`ask for the approved drawing` is added to the rights module as an RTI target for exactly this.

Copyright: the sheets carry an instrument-of-service notice reserving them to the consultant.
Facts are used; no sheet is reproduced and every diagram is redrawn.

Verdict for this section is **verified** — each figure was read off a named sheet — with a scope of
**this type design**, which is a property of the fact, not a fifth status. The app keeps its four
statuses; scope is what the সূত্র tap prints alongside the source, so a reader always sees both
"where this came from" and "how far it reaches".

### B.1 Godown Shell (15)

| What a person measures | The drawing says | Why it matters |
|---|---|---|
| Measure column centre to column centre along the long side of the godown (grid A to B, B to C, and so on) | **10'-1½" per bay, and 10 such bays from A to K** | Wrong spacing or a missing column changes how the roof is carried, and a missing column is a large sum of money not spent. |
| Count the columns along the long wall from one corner to the other on grid line 1 | **11 columns (grid lines A to K)** | Anyone can count columns; a short count is proof the frame was not built as drawn. |
| Measure the inside length and the inside width of the godown floor | **100'-0" long and 82'-6" wide** | The whole 1000 metric ton storage capacity depends on this floor area; a short building stores less grain than paid for, forever. |
| Measure the clear gangway between two grain stacks, across the building | **4'-0"** | Below 4 feet a handcart and two carriers cannot pass, inspection of stacks becomes impossible, and stacks get pushed together which causes heating ... |
| Measure the wide central gangway running through the middle of the floor | **8'-11"** | This is the main movement route; if stacks encroach on it the godown cannot be worked or inspected properly. |
| Measure one marked stack block on the floor | **25'-0" x 13'-8"** | Stack sizes are what the storage tonnage is counted from; oversized stacks eat the gangways, undersized ones mean lost capacity. |
| Measure how far the roof edge overhangs beyond the outside face of the wall | **2'-3"** | A shorter overhang lets rain run down the wall face and dampen the store; it is visible from the ground with a tape and a plumb string. |
| Measure the internal wall height from floor level up to the roof | **22'-0"** | Godown height sets how many bags can be stacked; a shortfall in height is a permanent loss of storage capacity. |
| Measure the overall outside width of the godown across the short direction (grid 1 to grid 7) | **86'-8"** | A short building holds less grain than the 500/1000 MT it is being paid for, and the shortfall is easy to hide once the walls are up. |
| Measure floor to underside of the roof inside the godown | **22'-6" clear** | Height decides how many bag tiers can be stacked; a short building permanently cuts storage capacity. |
| Measure the roof overhang (eaves projection) beyond the wall face | **2'-3"** | A short overhang lets rain drive onto the wall and into the store through the ventilation openings. |
| Measure the outside width of the main block across its short side, at the top end and again at the bottom end | **12'-10" at both ends** | If the two ends do not measure the same, the building has been set out out-of-square and every later item — walls, roof slab, doors — will be off. ... |
| Measure the width of the narrow strip along the top bay of the layout | **6'-4"** | This is the width of the side space or verandah. If it is squeezed, the usable room behind it shrinks and the work is smaller than the contract. |
| Measure the small annexe block: its length along the main building and its two end widths | **10'-1" long; 3'-9" at one end and 6'-0" at the other** | Small attached blocks (toilet, stair) are the easiest part to under-build because nobody measures them. These three numbers pin the whole annexe. |
| Measure the height of the plinth (the finished floor line of the building) above the surrounding ground level | **2'-0" above GL, shown on SEC: A-A, SEC: B-B, SEC: C-C and the small unlabelled section** | This is what keeps rain and flood water out of the building. Two feet is what was designed and paid for; a plinth built at a foot and a half looks ... |

### B.2 Foundation (8)

| What a person measures | The drawing says | Why it matters |
|---|---|---|
| Count the column/pile-cap grid lines along the long side and measure the spacing between two neighbouring column centres | **11 grid lines (A to K), each bay 10'-1½"** | If bays are stretched to save one column line, the roof beams span further than they were designed for and the frame is weaker than paid for. |
| Measure the diameter of a pile head before the cap is cast | **18" diameter** | A narrower pile carries less load; this is the one foundation number that is briefly visible and then buried forever. |
| Measure each of the three bays along the long side of the main block, centre of one footing line to the centre of the next | **10'-10", 10'-10" and 10'-10" — three equal bays** | Shortened bays are the commonest quiet way to reduce the size of a building below what was paid for. Three bays short by even 6 inches each takes o... |
| Before the footing trench is backfilled, measure the width of the bottom concrete (the plain concrete layer the brick footing sits on) at an A-type footing | **35" wide (SEC: A-A)** | The bottom concrete spreads the building's weight onto the soil. A narrower base than drawn is invisible once buried and is a direct saving of conc... |
| Measure the width of the bottom concrete at a B-type footing | **30" wide (SEC: B-B)** | Same reason as above; B footings carry less load and are drawn narrower, so this is the number to check on the B lines rather than assuming all foo... |
| Count the stepped brick courses above the bottom concrete at an A footing and measure each step width from the bottom up | **Five steps: 30", then 25", 20", 15", 10" (SEC: A-A)** | Dropping one step or narrowing each step by an inch or two is a large brick saving spread across the whole building, and it thins the load path exa... |
| Count the stepped brick courses at a B footing and measure each step width from the bottom up | **Four steps: 25", 20", 15", 10" (SEC: B-B)** | Confirms the B footings were built to their own detail and not silently swapped for a cheaper section. |
| Measure the depth from the ground level down to the bottom of the footing concrete at an A footing, before backfilling | **The step string on SEC: A-A totals roughly 2'-9" below GL (6"+6"+6"+6"+6"+3")** | A shallow foundation is the single most expensive thing to fix later and the easiest to hide once the trench is filled. Insist on measuring the ope... |

### B.3 Reinforcement (16)

| What a person measures | The drawing says | Why it matters |
|---|---|---|
| Measure the width of a tie beam and its depth where it is exposed before plastering | **12" wide x 18" deep (TB1)** | The tie beam is what holds the columns together at plinth level; an undersized beam is a hidden saving by the contractor and shows up later as cracks. |
| Count the number of main bars in the top of the tie beam and in the bottom, before concreting | **3 bars of 20mm at the top and 3 bars of 20mm at the bottom** | Missing even one bar out of six is a direct, permanent loss of strength that can never be checked again once the concrete is poured. |
| Measure the gap between stirrups (the small ring bars) in the tie beam, near the ends and in the middle | **4 inches centre to centre near the ends, 6 inches centre to centre in the middle stretch (end zone 5'-0" long)** | Stirrups spread further apart than shown is the commonest way steel is quietly saved; it is easy to check with a tape while the cage is still open. |
| Measure the gap between the outer face of the steel cage and the edge of the formwork (cover) in the tie beam | **1½"** | Too little cover and the bars rust and burst the concrete within a few years; too much and the beam is weaker than designed. |
| Measure how far the porch slab projects from the wall and its height above the floor | **5'-0" projection, 10'-0" clear height from floor level** | The porch is what keeps rain off bags during loading; short projection or low headroom makes it useless for a loaded truck. |
| Measure the thickness of the RCC godown floor slab at an edge or opening before it is covered | **6" R.C.C floor, laid on 3" C.C. over compacted sand filling** | A thin floor cracks under stacked bags and forklift wheels, and the 3" C.C. below is the layer most often skipped. |
| Measure a tie beam (the beam at 10'-0" above plinth) width and depth where it is exposed | **12" wide x 18" deep (TB1)** | An undersized beam is the single cheapest place to steal concrete and steel, and it is what ties the columns together. |
| Before the tie beam is cast, count the long bars at the top and at the bottom of the cage, and measure the gap between the stirrup rings | **3 bars of 20mm at top and 3 of 20mm at bottom; stirrups (10mm rings) every 4 inches** | Fewer bars or stirrups spaced wider than 4" is a common saving that cannot be seen after casting and weakens the beam permanently. |
| Measure the gap between the outside of the reinforcement cage and the face of the formwork on tie beams and columns | **1½" clear cover** | Too little cover and the steel rusts within a few monsoons, cracking the concrete open. |
| Measure the porch/canopy projection over the loading area and its slab thickness | **5'-0" projection, 6" slab** | A shorter canopy leaves bags in the rain during loading. |
| Measure the thickness of the roof/floor slab at a cut edge or at the shuttering before concrete is poured | **4.5 inches** | Half an inch shaved off a slab across the whole building is a large volume of concrete saved by the contractor and a directly weaker roof. It is me... |
| Before the slab is poured, measure the gap between the main slab bars marked A, centre of one bar to the centre of the next | **5 inches centre to centre, using 10 mm bars** | Widening the spacing means fewer bars in the same slab. Anyone can count bars and measure the gap while the steel is still exposed; once the concre... |
| Measure the spacing of the slab bars marked B, centre to centre | **6 inches centre to centre, using 10 mm bars** | Same check in the other direction of the slab; the two directions have different spacings by design, so both must be measured separately. |
| At each support line marked C on the slab plan, count the extra top bars laid over the beam | **2 extra 10 mm top bars at each C mark, running a quarter of the span (L/4) either side** | These extra top bars stop the slab cracking over its supports. They are quick to leave out and impossible to verify after the pour, so count them o... |
| Count the bars in the small concrete member at section F-F before it is cast | **4 straight 16 mm bars plus 1 cranked (bent-up) 16 mm bar — 5 bars in total** | A five-bar member built with three or four bars is a defect nobody can see afterwards, and a plain bar count with your own eyes settles it. |
| Measure the slab overhang at the marked corners of the slab reinforcement plan | **2'-0"** | The overhang is what shades and protects the wall below from driving rain; a shortened one leaves the wall wet and stained within a season. |

### B.4 Loading Dock (2)

| What a person measures | The drawing says | Why it matters |
|---|---|---|
| Measure the loading dock: length along the wall and how far it sticks out from the wall | **22'-0" long x 6'-0" wide** | A short or narrow dock means bags have to be carried further in the open and the unloading area is cramped; it is also a straightforward way to see... |
| Measure the thickness of the concrete top of the loading dock, and the height of the brick part below it | **6" RCC on top, 2'-6" brick below** | A thinner concrete top cracks under loaded handcarts and truck wheels within a season or two. |

### B.5 Openings (7)

| What a person measures | The drawing says | Why it matters |
|---|---|---|
| Measure the clear width of a front entry door opening | **5'-0"** | A narrower door blocks trolley movement and slows every truck load in and out for the life of the building. |
| Measure the sliding godown gate: each leaf width and the gate height | **5'-6" per leaf (two leaves) and 10'-0" high** | A short gate will not clear a loaded truck or trolley, and the gate is a costly item that is easy to substitute with a smaller one. |
| Measure the outer frame tube of the godown gate and the inner panel tube with a tape across the flat | **2" x 3" MS box for the outer frame and the vertical members, 2" x 2" MS box for the inner panels** | Thinner or smaller tube sections are a very common substitution; the gate then sags and jams within a year or two. |
| Measure a godown window opening | **8'-10" wide x 3'-0" high, in three panels** | Window area is what ventilates the grain; short windows mean poor air movement and damp stock. |
| Measure the exhaust fan opening in the wall | **4'-0" x 4'-0"** | An undersized opening means a smaller fan than specified was installed, and the store does not get the designed air change. |
| Measure a window opening in the godown wall, width and height | **8'-10" wide x 3'-0" high** | Undersized ventilation openings mean hot, damp air inside and mouldy grain. |
| Measure each sliding gate leaf, width and height, and count the leaves | **2 leaves, each 5'-6" wide, 10'-0" high** | A narrower gate blocks loaded trucks from entering, and the gate is billed by size. |

### B.6 Site Road (13)

| What a person measures | The drawing says | Why it matters |
|---|---|---|
| Measure the height of the finished godown floor (plinth) above the road level at the loading dock face | **3'-0"** | If the floor is built lower than 3'-0" above the road, rain water and drain water can run into the godown and spoil stored grain, and trucks no lon... |
| Measure the width of the internal RCC road between the two guide walls | **20'-0"** | Two trucks cannot pass, or a truck cannot turn to the dock, on a narrower road; road width is easy to shrink and easy to check. |
| Measure the earth shoulder on each side of the road, and the thickness of the guide wall | **3'-0" shoulder on each side, 10" thick guide wall** | Without the full shoulder the road edge breaks away under truck wheels in the first monsoon. |
| Measure the thickness of the road concrete slab at the edge before it is covered, or at an open joint | **200mm (about 8 inches)** | Road slab thickness is the single biggest quantity of concrete in the yard, and a 25mm shortfall across the yard is a large, invisible saving for t... |
| Measure the gap between road reinforcement bars while the mesh is still exposed, and check the bar diameter | **12mm bars at 150mm centre to centre in the long direction, 10mm bars at 150mm centre to centre as binder** | Wider spacing than 150mm means fewer bars were used; once the concrete is poured this can never be verified again. |
| Measure the brick flat soling thickness and the sand layer thickness under the road before concreting | **75mm brick flat soling and 600mm compacted sand below it** | These hidden layers carry the road; skimping here is invisible after concreting and causes the yard to settle and crack. |
| Check that a polythene sheet is actually laid over the soling before the road concrete is poured | **a polythene sheet of 125 micron minimum, laid continuously** | Without it the fresh concrete loses water into the soling and the slab cures weak; it costs little and is often skipped. |
| Measure the height of the finished plinth (floor level) above the road level at the outside wall | **3'-0"** | A low plinth lets flood or monsoon water into the store and the stored grain is ruined. |
| Measure the loading dock: length along the wall, width out from the wall, and height above road | **22'-0" long x 6'-0" wide x 3'-0" high (6" RCC top on 2'-6" brickwork)** | A dock lower or narrower than this does not line up with truck beds, so bags get manhandled and torn on every delivery. |
| Measure the paved carriageway width of the site road between the two guide walls | **20'-0"** | A narrower yard road means trucks cannot pass or turn, and the missing width is pure saved money for the contractor. |
| Measure the thickness of the RCC road slab at a cut edge or expansion joint | **200mm** | A thin road slab breaks up under loaded trucks within one or two seasons. |
| Before the road slab is poured, measure the gap between the road reinforcement bars | **150mm centre to centre both ways (12mm main bars, 10mm binder bars)** | Widening bar spacing is invisible after the pour and is the usual reason a new yard cracks in its first year. |
| Measure the width of the shoulder each side of the road, and the width of the guide wall | **3'-0" shoulder each side; 10" guide wall** | No shoulder means the road edge crumbles under wheels. |

### B.7 Boundary Wall (14)

| What a person measures | The drawing says | Why it matters |
|---|---|---|
| Measure a boundary wall footing pit before casting: length and width | **4'-0" x 4'-0"** | A smaller footing than drawn is the cheapest place to save money and the first place a boundary wall starts leaning. |
| Measure the spacing of the reinforcement bars in the boundary wall footing, both directions, before concreting | **12mm bars at 6" centre to centre both ways** | Bars at 9" instead of 6" is a third of the steel gone and cannot be seen once concreted. |
| Count the vertical bars in a boundary wall column and measure the column size | **4 bars of 16mm, column 10" x 10" above ground (13" x 13" at the lower section)** | Counting four bars takes seconds and catches a substitution that would otherwise never be found. |
| Measure the boundary wall column ties (ring bars) spacing | **10mm ties at 6" centre to centre** | Wide ties let the column bars buckle; it is the most common corner cut in boundary wall work. |
| Measure the centre to centre distance between two boundary wall columns | **10'-0"** | Fewer columns over a length means a longer unsupported brick panel that will crack or fall; count columns along a measured 100 feet. |
| Measure the boundary wall thickness and its height above ground level | **5" thick brick wall, 7'-0" high above F.G.L plus 3" coping** | A wall built lower or thinner than drawn is both a security failure and an obvious quantity shortfall. |
| Measure the grade beam of the boundary wall | **10" x 12", with 4 bars of 16mm** | The grade beam ties all the boundary columns together at ground level; undersizing it is what makes long stretches of wall settle unevenly. |
| Measure the gap left at an expansion joint in the boundary wall, and the distance between two joints | **½" joint, joints at 32'-0" intervals** | Missing joints show up as long diagonal cracks in the wall in the first hot season; both the gap and the interval are directly measurable. |
| Measure a boundary wall footing pit, length x width, and its depth below existing ground | **4'-0" x 4'-0", 4'-0" deep** | A shallow or small footing lets the boundary wall lean or fall in the first storm. |
| Count the bars in a boundary wall column cage and measure the column size | **4 bars of 16mm; column 10" x 10" (13" x 13" at the lower section)** | Three bars instead of four, or a 9" column, is a routine substitution that halves the wall's resistance to wind. |
| Measure the spacing between boundary wall columns along the wall | **10'-0" centre to centre** | Stretching column spacing saves the contractor whole columns and footings, and the unsupported brick panel then cracks. |
| Measure the boundary wall height from finished ground level to the underside of the coping, and the thickness of the brickwork | **7'-0" high; 5" thick brick wall** | A short wall does not secure the food store; the height is billed per running foot. |
| Find the vertical expansion joints in the boundary wall and measure the distance between them | **½" wide joints at 32'-0" intervals** | Missing joints make the long wall crack in random places within a year. |
| Measure the boundary wall coping: width across the top and thickness | **10" wide, 3" thick, with 2-Ø10 bars inside** | A thin or unreinforced coping breaks and lets rain into the brickwork below. |


---

## C. Rejected — 82 facts that do not ship

| Subject | Value | Why it does not ship |
|---|---|---|
| bricks needed instead, if khoa is made on site, for 100 cft of 1:3:6 cement concrete | 450 | 90 cft of khoa needs about 765 bricks by the book's own rule of 850 bricks per 100 cft of khoa, so 450 would leave the pour a third short of aggregate |
| waterproofing compound (paddlo) per bag of cement in DPC | 2.25 | 2.25 cft of waterproofing compound per 1.25 cft bag of cement means nearly two parts admixture to one part cement, which would destroy the mix; the un |
| Khoa (brick chip) size used in patent stone floor concrete | 0.75 | A 19 mm chip cannot go into a patent-stone topping that PWD builds only 25 to 38 mm thick, and the same passage's 1/2 inch layer makes it physically i |
| drop height in the two-brick T-shaped field drop test onto level ground | 6 | Six feet is above head height for most people, it contradicts both the book's own 3 ft figure and the 'chest height' the app already teaches, and tell |
| cement mortar needed per 100 cft of brick masonry | 15 | Geometry makes 15 cft impossible: bricks of 9.5×4.5×2.75 in laid on a 10×5×3 in module leave 21.6 cft of voids per 100 cft even before the dry-volume  |
| sand needed for 100 sft of brick soling | 5 | 5 cubic metres is 177 cft of sand for 100 sft of soling — a 1.8 metre deep sand bed, which is physically impossible; the unit is wrong in the book and |
| DPC casting ratio quoted in the thumb-rule section | 1:2:4 | The app's own shipped PWD schedule builds every damp-proof course at 1:1.5:3, so publishing 1:2:4 would tell a homeowner to accept a leaner, more perm |
| Casting ratio restated in the chapter 13 casting caution, with the component order printed as cement | 1:2:4 | Read literally this line puts four parts sand and two parts aggregate into a structural mix, the reverse of every mix table in the book and in the PWD |
| Extra cost of an RCC frame structure over a 10-inch load-bearing brick wall structure | 15-20 | A 2019 relative-price claim: rod, cement and mason wages have all moved at different rates since, so a homeowner budgeting an RCC frame off a 15-20% p |
| Foundation cost, given as a share within the civil-work line | 15 | The base is not stated — 15% of the whole building or 15% of the 75% civil line are different numbers (15% versus 11.25%) — so the figure cannot be re |
| stated total of the building cost breakdown | 100 | The book prints '= 100%' under seven shares that add to 108%, so the stated total is simply false and publishing it would tell a homeowner the breakdo |
| thickness of the damp-proof course (DPC) cast on the plinth wall | 1 or 1.5 | The shipped PWD SoR specifies a damp proof course at 75 mm (about 3 in) minimum, so the book's 1 to 1.5 in is 25 to 38 mm — under half the standard th |
| number of estimate types the book distinguishes (project, building, road) | 3 | A textbook taxonomy of estimate types with nothing a homeowner watching a site can check or act on. |
| number of things an estimator must understand before preparing an estimate | 6 | A checklist of what the estimator should know before starting; it describes the professional's preparation, not anything the citizen using this app ca |
| lime needed per square metre of white wash | 3 | 3 kg of lime per square metre would lay down a 5 mm thick dry layer — that is a plaster, not a wash; PWD prices whitewash as three thin coats, and shi |
| area covered by one 40 kg tin of snowcem | 275 | 275 sq yd per 40 kg tin is 0.17 kg per square metre, three times thinner than the book's own cement paint figure of 0.5 kg/sqm on the same page, and i |
| floor mosaic thickness in millimetres as printed | 10 | 3/4 inch is 19 mm, not 10, and PWD's finished mosaic is 20 mm — this figure is half the real thickness and would let a floor be laid at half the speci |
| marble chips needed for 100 sft of floor mosaic | 3.5 | Marble chips are quoted in 'bags' but the book never says what a bag of chips weighs or holds, so 3.5 bags cannot be converted, checked, or ordered ag |
| area of a semi-parabolic curve/cone | (2/3) × base × height | The book gives no definition of a 'semi-parabolic cone' and simply repeats the parabola expression, so there is no shape a reader could apply it to —  |
| Labour cost as a share of total building cost (thumb rule) | 15 | The same book gives labour as 15%, 20% and 31% in three places; a bare 15% is not a fact, it is one of three irreconcilable numbers, and it is the low |
| Labour (mason and worker) cost as a share of building cost | 31 | It sits in the table that sums to 108%, and it is also the extreme of three irreconcilable labour figures (15%, 20%, 31%) in the same book, so shippin |
| daily rate for a head mason/tradesman (head rod, carpenter, painter, bitumen, plumber) | 600 | A January 2019 daily wage in taka; construction wages in Bangladesh have risen far above this since, and a homeowner budgeting or negotiating on 600 t |
| daily rate for a tradesman (rod mason, carpenter, painter, bitumen mason, plumber) | 500 | A January 2019 taka wage, stale by seven years and harmful as a budgeting or negotiating figure today. |
| daily rate for a skilled helper | 400 | A January 2019 taka wage; stale money and not something to quote on a site in 2026. |
| daily rate for a skilled labourer | 300 | A January 2019 taka wage, and the source table itself is suspect since it prices skilled labour, general labour and skilled technician all identically |
| daily rate for a general labourer | 300 | A January 2019 taka wage; meaningless as a rate today. |
| daily rate for a skilled technician | 300 | A January 2019 taka wage, and internally implausible: a skilled technician is priced the same as a general labourer and below a helper, which points t |
| daily rate for a foreman | 600 | A January 2019 taka wage; stale money that would misprice a supervision budget today. |
| Daily rate for a head mason-grade tradesman (head rod-fixer, head carpenter, head painter, head bitu | 600 | A January 2019 daily wage; construction wages in Bangladesh have moved far past this, and a homeowner or a citizen checking a muster roll against Tk 6 |
| Daily rate for a tradesman (rod-fixer, carpenter, painter, bitumen worker, plumber) | 500 | January 2019 daily wage, stale and misleading as a check figure in 2026. |
| Daily rate for a skilled helper | 400 | January 2019 daily wage, stale and misleading as a check figure in 2026. |
| Daily rate for a skilled labourer | 300 | January 2019 daily wage, stale and misleading as a check figure in 2026. |
| Daily rate for a general labourer | 300 | January 2019 daily wage, stale and misleading as a check figure in 2026. |
| Daily rate for a skilled technician | 300 | January 2019 daily wage, and the table prices a skilled technician the same as a general labourer, which reads as a typesetting error on top of being  |
| Daily rate for a foreman | 600 | January 2019 daily wage, stale and misleading as a check figure in 2026. |
| Brick cost as a share of building cost | 22 | I added the table up and its seven items come to 108%, not the 100% it prints, so no single row from it can be trusted — the OCR has either dropped or |
| Cement cost as a share of building cost | 12 | From the same table that sums to 108% instead of 100%; a row of a table that does not add up is not a fact. |
| Steel (iron) cost as a share of building cost | 11 | From the same 108% table; unusable until the printed page is re-read. |
| Timber cost as a share of building cost | 10 | From the same 108% table; unusable until the printed page is re-read. |
| Other construction materials as a share of building cost | 15 | From the same 108% table; unusable until the printed page is re-read. |
| Plastering work as a share of building cost, in the material/labour table | 7 | From the same 108% table; unusable until the printed page is re-read. |
| Bricks required per square foot of an ordinary building | 48 | 48 bricks per square foot is out by roughly five times: 48 bricks is about 4 cft of masonry, and a whole ordinary house uses on the order of 1 cft of  |
| Cement required per square foot of an ordinary building | 0.14 | The four-item per-square-foot table it belongs to does not hold together — the brick row is out by fivefold and the steel row's unit is unreadable — a |
| Sand required per square foot of an ordinary building | 0.35 | Same broken table: 0.35 cft/sft is far below the sand an ordinary building takes per square foot of floor area, and it does not reconcile with the tab |
| Steel rod required per square foot of an ordinary building | 0.14 | The unit is OCR-damaged beyond confident reading, and both candidate readings give impossible answers — 0.14 hundredweight is 7.1 kg/sft and 0.14 maun |
| weight of 225 cft of lime, sand or surki | 100 | 100 maund over 225 cft works out to 586 kg per cubic metre, which is right for loose lime but roughly a third of sand's real 1400-1600 kg/m³ — anyone  |
| length of 16 gauge barbed wire weighing one hundredweight | 950 | 950 ft weighing one hundredweight means 175 grams per metre, but 16 gauge barbed wire (two 1.65 mm strands plus barbs) weighs about 40 g/m — the figur |
| colouring to marble ratio in floor mosaic | 8:1 | The book states '8:1 colouring marble ratio' without naming what the two parts are, so there is nothing a reader could measure or check against — it c |
| Ratio stated for colouring marble in floor mosaic | 8:1 | The book does not name what the 8 and the 1 are, so the number cannot be acted on by anyone — an unlabelled ratio in a trust app is worse than no rati |
| Floor mosaic thickness used in the thumb-rule estimate | 0.75 | The printed pair is arithmetically impossible — 3/4 inch is 19 mm, not the 10 mm printed beside it — so the source cannot be read confidently, and it  |
| waterproofing compound (paddlo) per bag of cement in patent stone flooring | 2.25 | Same impossible dosing as the DPC item — 2.25 cft of admixture against a 1.25 cft bag of cement is 180% by volume; repeating it twice makes it a consi |
| Plinth (floor) area construction rate for the ground floor | 1500-2000 | A January 2019 money rate; a homeowner budgeting a build off Tk 1,500-2,000 per sft in 2026 would be short by a wide margin, which is exactly the harm |
| Plinth (floor) area construction rate for the first floor | 2000-2200 | January 2019 money rate, superseded and harmful as a budget input in 2026. |
| Plinth (floor) area construction rate for the second floor | 2200-2400 | January 2019 money rate, superseded and harmful as a budget input in 2026. |
| Plinth (floor) area construction rate for the third floor | 2200-2500 | January 2019 money rate, superseded and harmful as a budget input in 2026. |
| G.I. wire gauge specified for tying reinforcement | 26 | 26 gauge is about 0.46 mm — thinner than any wire used to tie reinforcement, contradicted by the book's own 22 gauge elsewhere, and well below the 20  |
| rod length beyond which a lap (splice) is required | 6 | This is a stock-length artefact dressed as a rule, and it is not even the right stock length — reinforcement in Bangladesh is sold in 40 ft (about 12  |
| dining room, standard size | 11 × 12 | The printed 3.08 m is 10'-1", and the book uses that same 3.08 m for the 10'-0" dining-normal row, so the '11 ফুট' is most likely an OCR misread of ১০ |
| bathroom, normal size | 5.83 × 4 | The metric pair 2.13 × 1.52 m is exactly 7' × 5' — the standard bathroom transposed — while the foot column says 5'-10" × 4'-0", so the row is corrupt |
| Septic tank size (L x W x depth) for 100 users, as given in the thumb-rules appendix | 11x?x4.5 | The width is unreadable in the OCR ("৪-২'") and the depth contradicts the book's own chapter 11 table for the same user count, so there is no confiden |
| Septic tank size (L x W x depth) for 250 users, as given in the thumb-rules appendix | 21x6x7.17 | Uncertain on two counts — the depth is OCR-damaged and there is no 250-user row anywhere else, while PWD's own bracket set jumps 100 to 200 with no 25 |
| septic tank length, width and depth for 100 users | 11 × 6 × 5.83 | The table gives 385 cubic feet for 100 users while the book's own appendix gives 206 for the same count — nearly double — and an undersized septic tan |
| septic tank size for 100 users as given in the appendix | 11 × 4.17 × 4.5 | This gives 206 cubic feet for 100 users against the main table's 385 for the same count, and an undersized septic tank backs up into the household, so |
| septic tank size for 250 users as given in the appendix | 21 × 6 × 7.17 | The shipped PWD SoR's septic-tank ladder runs 10, 20, 30, 50, 100, 200 users with no 250 class, and the book's own table assigns nearly this same tank |
| Sanitary and water supply cost as a share of building cost (footnote) | 8 | It is a footnote to the table that does not add up, and it is the minority reading — two other places in the book say 15% — so it is the one to drop,  |
| Electrical installation cost as a share of building cost (footnote) | 7 | Same footnote to the same broken table, and the minority reading against 9% in two other places. |
| minimum width of the road in front of a construction plot, stated as a RAJUK requirement | 15 | A flat 15 ft is presented as a RAJUK legal minimum with no clause named, from a Jan-2019 book, and nothing in the repo corroborates it — RAJUK's acces |
| weight of the auger used for the test pit / shaft method | 45 | The weight of a testing tool is not something a homeowner standing on site can check or act on, and it teaches nothing about whether the soil test was |
| diameter of the wooden auger used for auger boring | 5 | Tool-dimension trivia a citizen cannot verify or use on site; it does not help anyone judge whether the soil investigation was adequate. |
| diameter of the pipe used with the auger in auger boring | 2.5 | Same as the auger diameter — equipment detail with no checkable action behind it. |
| weight of the falling hammer used in the Standard Penetration Test as the book states it | 650 | 650 N works out to 66.3 kg, whereas the SPT hammer in normal use is 63.5 kg (622.7 N), so the book's figure is a wrong test specification and the app  |
| drop height of the SPT hammer as the book states it | 750 | The drop used in practice is 760 mm (30 in = 762 mm); 750 mm is either a rounding or an OCR reading of ৭৬০, and a test specification that may be a sca |
| number of steel rod grades in common use | 2 | The shipped SoR prices three reinforcement grades, not two, so telling a reader there are only two would leave out Grade 500 — the grade most new work |
| DDT share of the termite-killing solution | 5 | DDT is a persistent organic pollutant banned under the Stockholm Convention and Bangladesh pesticide rules, and the shipped PWD SoR specifies chlorpyr |
| BHC share of the termite-killing solution | 0.5 | BHC/lindane is banned under the same rules, and the printed 'বি.এইচ.এস' is itself a misprint, so the row is unusable on both legal and reading grounds |
| aldrin share of the termite-killing solution | 0.25 | Aldrin is a banned persistent organic pollutant; printing a dose for it would be handing a homeowner an illegal and toxic recipe. |
| heptachlor share of the termite-killing solution | 0.25 | Heptachlor is banned, and chapter 15-5 of the same book naming heptachlor and dieldrin again only widens the problem rather than supporting it. |
| chlordane share of the termite-killing solution | 0.5 | Chlordane is banned under the Stockholm Convention and Bangladesh pesticide rules, so the dose cannot ship as advice. |
| water share of the termite-killing solution | 93.5 | The six shares do sum to exactly 100, but the water fraction only has meaning as part of a banned mixture, so publishing it would make the recipe look |
| volume of the termite solution applied per cubic metre of termite nest | 4 | It is the application rate for the banned mixture above, and the source sentence even switches from 'solution' to 'salt', so there is nothing safe or  |
| floor tile thickness range | 1/2 to 3 | The upper bound is OCR-damaged past confident reading and the surviving figure is not a real product — a 3 inch thick floor tile does not exist — so n |
| one hectare stated in square metres in the land-measure row | 1000 | A hectare is 10,000 m², not 1,000 — this row is wrong by a factor of ten and would misstate a land area tenfold if it ever reached a screen. |

---

## D. Contradictions — 89 facts that disagree with the schedule or the app

Each needs a decision before the card that would carry it is written.

| Fact | Book says | Verdict | What it disagrees with |
|---|---|---|---|
| DPC casting ratio quoted in the thumb-rule section | 1:2:4 | ⛔ rejected | Directly contradicts shipped assets/content/rates/pwd_sor_2022.json items 03.6.1/03.6.2, which give DPC as 1:1.5:3. |
| drop height in the two-brick T-shaped field drop test onto level ground | 6 | ⛔ rejected | guide.json card m3c3 (Brick) ships 'Dropped from chest height a good brick does not break' — publishing 6 ft would put two different drop heights in one app. |
| cement mortar needed per 100 cft of brick masonry | 15 | ⛔ rejected | The shipped brickwork calculator in lib/features/calculators/logic/brickwork.dart computes mortar from geometry and yields ~23 cft wet / ~30 cft dry per 100 cft of masonry, against the book' |
| number of steel rod grades in common use | 2 | ⛔ rejected | assets/content/rates/pwd_sor_2022.json chapter 8 lists three grades where this fact says two. |
| G.I. wire gauge specified for tying reinforcement | 26 | ⛔ rejected | The same book gives 22 gauge for the same job in the chapter 13 rod-laying list (fact binding-wire-gauge-22), so shipping both would put two gauges in one app. |
| rod length beyond which a lap (splice) is required | 6 | ⛔ rejected | guide.json card m5c3 already tells the reader that how long a lap must be, and where laps are allowed, is set by rule and not by eye — a fixed 6 m trigger cuts against that. |
| one hectare stated in square metres in the land-measure row | 1000 | ⛔ rejected | Directly contradicts unit-hectare-to-sqm, extracted from the correct row of the same table. |
| area of a semi-parabolic curve/cone | (2/3) × base × height | ⛔ rejected | Prints the identical expression as formula-area-parabola with no stated difference between the two items. |
| bricks needed instead, if khoa is made on site, for 100 cft of 1:3:6 cement conc | 450 | ⛔ rejected | Contradicts rule-100cft-khoa-bricks and the 850-brick figures in the 1:2:4 and 1:1.5:3 items of the same section. |
| floor mosaic thickness in millimetres as printed | 10 | ⛔ rejected | Contradicts mosaic-thickness-inch printed on the same line, and PWD SoR item 05.10.1 shipped in assets/content/rates/pwd_sor_2022.json. |
| area covered by one 40 kg tin of snowcem | 275 | ⛔ rejected | Contradicts finish-cement-paint from the same section by a factor of three. |
| stated total of the building cost breakdown | 100 | ⛔ rejected | Contradicts the seven costshare items extracted from the same table, which sum to 108%. |
| Extra cost of an RCC frame structure over a 10-inch load-bearing brick wall stru | 15-20 | ⛔ rejected | assets/content/rates/prices.json ships live 2026 material rates (rod 90,000-95,000 Tk/tonne, brick 8,500-9,000 Tk/1000, as_of 2026-09-02); the 2019 premium was computed off none of these. |
| Labour cost as a share of total building cost (thumb rule) | 15 | ⛔ rejected | Contradicts the same book at [৮-৪](৬) (31%) and [৮-৫](খ)(২) (20%). |
| Septic tank size (L x W x depth) for 100 users, as given in the thumb-rules appe | 11x?x4.5 | ⛔ rejected | Contradicts টেবিল (১১-১), which gives 100 users as 11'-0" x 6'-0" x 5'-10". |
| Septic tank size (L x W x depth) for 250 users, as given in the thumb-rules appe | 21x6x7.17 | ⛔ rejected | The book's টেবিল (১১-১) has no 250-user row; its nearest row is 200 users at 22'-0" x 6'-0" x 7'-2" — same width and depth, different length and different user count. |
| Plinth (floor) area construction rate for the ground floor | 1500-2000 | ⛔ rejected | assets/content/rates/prices.json already ships house_standard_sft at 1,800-2,200 Tk/sft with as_of 2026-09-02. The book's 2019 ground-floor rate sits below the app's current standard-finish  |
| Plinth (floor) area construction rate for the first floor | 2000-2200 | ⛔ rejected | assets/content/rates/prices.json ships current per-sft build rates (house_standard_sft 1,800-2,200, house_medium_sft 2,200-2,800, as_of 2026-09-02). |
| Plinth (floor) area construction rate for the second floor | 2200-2400 | ⛔ rejected | assets/content/rates/prices.json ships current per-sft build rates as_of 2026-09-02. |
| Plinth (floor) area construction rate for the third floor | 2200-2500 | ⛔ rejected | assets/content/rates/prices.json ships current per-sft build rates as_of 2026-09-02. |
| Foundation cost, given as a share within the civil-work line | 15 | ⛔ rejected | The same book gives foundation as 6% ([৭-০](৭)(খ)২), 10% ([৮-৩](১)) and 20% ([৮-২]). |
| Labour (mason and worker) cost as a share of building cost | 31 | ⛔ rejected | Conflicts with [৭-০](১)(চ) at 15% and [৮-৫](খ)(২) at 20%. |
| Sanitary and water supply cost as a share of building cost (footnote) | 8 | ⛔ rejected | Contradicts [৮-১] and the [৭-০](৭)(খ) service list, both of which give 15%. |
| Electrical installation cost as a share of building cost (footnote) | 7 | ⛔ rejected | Contradicts [৮-১] and the [৭-০](৭)(খ) service list, both of which give 9%. |
| DDT share of the termite-killing solution | 5 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 already in assets/content/rates/pwd_sor_2022.json: chapter 29 (items 29.1, 29.2, 29.3, 29.5, 29.7) names DURSBAN 20 EC as the anti-termite chemical, not  |
| BHC share of the termite-killing solution | 0.5 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 chapter 29, which specifies DURSBAN 20 EC for anti-termite treatment. |
| aldrin share of the termite-killing solution | 0.25 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 chapter 29, which specifies DURSBAN 20 EC. |
| heptachlor share of the termite-killing solution | 0.25 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 chapter 29, which specifies DURSBAN 20 EC. |
| chlordane share of the termite-killing solution | 0.5 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 chapter 29, which specifies DURSBAN 20 EC. |
| water share of the termite-killing solution | 93.5 | ⛔ rejected | Part of the same recipe the shipped PWD SoR 2022 chapter 29 supersedes with DURSBAN 20 EC. |
| volume of the termite solution applied per cubic metre of termite nest | 4 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 chapter 29 dosing, which is built around DURSBAN 20 EC. |
| thickness of the damp-proof course (DPC) cast on the plinth wall | 1 or 1.5 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 in assets/content/rates/pwd_sor_2022.json: items 03.6.1 and 03.6.2 give 75 mm and 150 mm DPC, against the book's 25-38 mm. |
| septic tank size for 250 users as given in the appendix | 21 × 6 × 7.17 | ⛔ rejected | Contradicts the shipped PWD SoR 2022 in assets/content/rates/pwd_sor_2022.json: its septic-tank items top out at 32.87.6 '200 user septic tank', with no 250-user class. |
| Cement-to-sand mortar ratio for 10-inch brick wall masonry | 1:6 | 🟠 review | Shipped assets/content/rates/pwd_sor_2022.json item 04.3 prices exterior-wall brickwork at 1:4; the book says all 10-inch walls are 1:6. The app must not present 1:6 as correct for an exteri |
| Cement-to-sand mortar ratio for wall pointing | 1:4 | 🟠 review | Shipped pwd_sor_2022.json items 15.7–15.9 give pointing mortar as 1:2, not the book's 1:4. |
| Cement-to-sand plaster ratio for septic tank | 1:3 | 🟠 review | Shipped pwd_sor_2022.json item 32.103 gives septic-tank plaster as 1:4; the book says 1:3. |
| Plaster thickness on septic tank | 0.75 | 🟠 review | Shipped pwd_sor_2022.json item 32.103 specifies 12 mm for septic-tank plaster; the book specifies 3/4 inch (19 mm). |
| Hours after casting before curing starts for damp-proof course concrete | 20 | 🟠 review | The curing table labels DPC as (1:2:4); shipped pwd_sor_2022.json item 03.6.1 gives DPC as 1:1.5:3. |
| Mortar ratio quoted for 10-inch brick wall masonry in the thumb-rule section | 1:6 | 🟠 review | Shipped pwd_sor_2022.json item 04.3 uses 1:4 for exterior walls, against the book's blanket 1:6 for 10-inch walls. |
| drop height from which a 1st class brick should not break easily (identification | 3 | 🟠 review | guide.json card m3c3 (Brick) already ships a different height — 'Dropped from chest height a good brick does not break', i.e. roughly 4 to 4.5 ft, matching neither the 3 ft here nor the 6 ft |
| standard Bangla brick size in millimetres (PWD schedule) | 238 x 113 x 70 | 🟠 review | PWD SoR 2022 item 04.6, shipped in assets/content/rates/pwd_sor_2022.json, gives 241 × 114 × 70 mm where this fact gives 238 × 113 × 70 mm. |
| fineness modulus of fine (soru/chikon) sand, used for plaster work | 1.05 | 🟠 review | Every plaster item in the shipped SoR (15.1.1 through 15.6, 15.15.x) specifies sand of F.M. 1.2, not 1.05, so an app card pairing F.M. 1.05 with plaster work would undercut the schedule the  |
| fineness modulus of medium-coarse sand, used for brick masonry mortar | 1.50 | 🟠 review | The shipped SoR specifies F.M. 1.2 sand for brickwork mortar throughout chapter 4, where this fact assigns F.M. 1.50 to that job. |
| fineness modulus of Sylhet sand, the coarsest of the listed sands | 2.50 | 🟠 review | assets/content/rates/pwd_sor_2022.json items 03.6.1, 03.6.2 and 24.18.1 all give Sylhet sand as F.M. 2.2 against the 2.50 here. |
| lower end of the acceptable fineness modulus range for good sand | 1.50 | 🟠 review | The shipped SoR requires F.M. 1.2 sand for masonry mortar and plaster, which falls below this 1.50 'good sand' floor — a reader could reject sand the schedule requires. |
| wire gauge specified for tying slab, column and beam rods firmly in place | 22 | 🟠 review | The same book gives 26 gauge for the same job in [৯-৯] and under table [৯-২] (fact rod-binding-wire-gauge-26). |
| smallest listed floor tile size | 6 x 6 | 🟠 review | The shipped SoR chapter 6 starts floor tiles at 300 mm x 300 mm; a 6 inch floor tile is not in the schedule the same app carries. |
| largest listed floor tile size | 12 x 12 | 🟠 review | The shipped SoR prices floor tiles from 300 mm up to 1200 mm square, so the book's 12 inch maximum is the schedule's minimum. |
| wall tile size used in bathrooms and toilets | 6 x 6 x 1/2 | 🟠 review | The shipped SoR chapter 6 wall tile items start at 250 mm x 330 mm, larger than the 6 x 6 inch tile given here. |
| cement needed for 100 sft of 5 inch (1:4) brick wall | 3 | 🟠 review | The shipped brickwork calculator returns ≈2.0 bags for 100 sft of 5 inch 1:4 wall; a user comparing the two screens would see 3 against 2. |
| sand needed for 100 sft of 5 inch (1:4) brick wall | 13 | 🟠 review | The shipped brickwork calculator returns ≈9.9 cft for 100 sft of 5 inch 1:4 wall against the book's 13 cft. |
| cement needed for 100 cft of 10 inch (1:6) brick wall | 4 | 🟠 review | The shipped brickwork calculator returns ≈3.4 bags per 100 cft of 1:6 brickwork against the book's 4. |
| sand needed for 100 cft of 10 inch (1:6) brick wall | 30 | 🟠 review | The shipped brickwork calculator returns ≈25 cft per 100 cft of 1:6 brickwork against the book's 30. |
| sand needed for 100 cft of 1:3:6 cement concrete | 40 | 🟠 review | The shipped concrete calculator returns ≈46 cft for the same pour; the book's 40 also makes its own row internally inconsistent (13 bags = 16.25 cft cement against 40 cft sand is 1:2.5, not  |
| bricks needed instead of khoa for 100 cft of 1:1.5:3 RCC | 850 | 🟠 review | Uses the same 850 as the 1:2:4 item even though this mix takes 84 cft of khoa rather than 90; the book does not reconcile the two. |
| damp proof course thickness in inches | 1.5 | 🟠 review | Contradicts PWD SoR 2022 item 03.6.1, which the app already ships in assets/content/rates/pwd_sor_2022.json: 75 mm, not 38-40 mm. |
| damp proof course thickness in millimetres | 40 | 🟠 review | Contradicts PWD SoR 2022 item 03.6.1 shipped in assets/content/rates/pwd_sor_2022.json (75 mm damp proof course). |
| cement:sand:aggregate ratio for DPC casting | 1:2:4 | 🟠 review | Contradicts PWD SoR 2022 item 03.6.1 shipped in assets/content/rates/pwd_sor_2022.json, which uses 1:1.5:3 for DPC. |
| cement needed for 100 sft of 1 inch 1:2:4 patent stone flooring | 2 | 🟠 review | The shipped concrete calculator returns ≈1.5 bags for the same 1 inch 1:2:4 topping against the book's 2. |
| cement needed for 100 sft of 6 mm 1:4 cement plaster | 0.5 | 🟠 review | The shipped plaster calculator returns ≈0.43 bags for the same area and thickness against the book's 0.5. |
| white cement to grey cement ratio in floor mosaic | 10:1 | 🟠 review | PWD SoR items 05.1.1 and 05.1.2, shipped in assets/content/rates/pwd_sor_2022.json, price mosaic at 100% white or 100% grey cement rather than a 10:1 mix — a contractor billed at the 100% wh |
| weight of one bag of cement in pounds | 112 | 🟠 review | Sits beside cement-bag-kg (50 kg) in the same row and does not agree with it; the app ships kgPerCementBag = 50 in lib/features/calculators/logic/units.dart. |
| Plinth level height above the existing road level | 1.5-2.0 | 🟠 review | assets/content/checklists/godown.json item g1 already ships a different plinth standard — about 80 cm (2 ft 7 in) above ground, higher where local flood level is higher. A reader comparing t |
| Septic tank size (L x W x depth) for 100 users, chapter 11 table | 11x6x5.83 | 🟠 review | Supersedes the appendix's [৭-০](৫)(গ) row, which is rejected as unreadable. |
| Thickness of damp-proof course | 1.5 | 📐 rule of thumb | Shipped pwd_sor_2022.json item 03.6.1 specifies a 75 mm DPC — twice the book's 1.5 inch. |
| lap length for a 3 suta (3/8 inch) rod | 18 | 📐 rule of thumb | guide.json card m5c3 tells the reader lap length is set by rule, not by eye — a fixed inch figure invites the opposite reading. |
| lap length for a 5 suta (5/8 inch) rod | 25 | 📐 rule of thumb | guide.json card m5c3 tells the reader lap length is set by rule, not by eye. |
| lap length for a 6 suta (3/4 inch) rod | 34 | 📐 rule of thumb | guide.json card m5c3 tells the reader lap length is set by rule, not by eye. |
| one foot taken as a rounded site figure in millimetres | 300 | 📐 rule of thumb | The app's own converter uses 0.3048 m per foot; a 300 mm foot would give different answers from every calculator screen in the app. |
| cement:sand:aggregate ratio for RCC casting (item 6) | 1:2:4 | 📐 rule of thumb | The app's own guide card m4c1 (assets/content/guide/guide.json, module m4_mixing) already tells readers BNBC 2020 specifies concrete by f′c, not by ratio; shipping 1:2:4 as an RCC spec would |
| cement:sand:aggregate ratio for RCC casting (item 7) | 1:1.5:3 | 📐 rule of thumb | The app's guide card m4c1 (assets/content/guide/guide.json) already states BNBC 2020 specifies structural concrete by f′c rather than by ratio. |
| share of total building cost spent on labour and masons | 31 | 📐 rule of thumb | Contradicts costmodel-mason-labour from section [৮-৫] of the same book, which puts masons and labourers at 20%. |
| construction materials as a share of building cost | 60 | 📐 rule of thumb | Contradicts the [৮-৪] cost-share table in the same book, where the material lines come to about 70%. |
| masons and labourers as a share of building cost | 20 | 📐 rule of thumb | Contradicts costshare-labour from section [৮-৪] of the same book, which puts labour at 31%. |
| Minimum compaction time for filled earth before casting the floor slab | 1.5 | 📐 rule of thumb | assets/content/checklists/godown.json item g2 already ships the correct method — fill in layers no thicker than about 200 mm, watering and compacting each layer. The book's time rule would l |
| Cement:sand:aggregate ratio for RCC work (column, lintel, beam, slab) in an ordi | 1:2:4 | 📐 rule of thumb | The app's own guide card assets/content/guide/guide.json modules[4].cards[0] already tells the reader that BNBC 2020 specifies concrete by strength (f′c), not by ratio. Shipping 1:2:4 as the |
| Minimum water requirement per person per day | 10 | 📐 rule of thumb | The book's own sizing does not use it: a family of five at 10 gallons each needs 50 gallons a day, which would make the book's 400 gallon roof tank an eight-day store — the tank was clearly  |
| Foundation share of building structure cost | 6 | 📐 rule of thumb | The same book gives foundation as 10% at [৮-৩](১), 15% at [৮-১] and 20% at [৮-২]. |
| Sanitary work share of total building cost | 15 | 📐 rule of thumb | [৮-৪] বিঃদ্রঃ (ক) gives sanitary plus water supply as 8% of building cost. |
| Electrical work share of total building cost | 9 | 📐 rule of thumb | [৮-৪] বিঃদ্রঃ (খ) gives electrical installation as 7%. |
| Water supply and sanitary share of total building cost | 15 | 📐 rule of thumb | [৮-৪] বিঃদ্রঃ (ক) gives the same item as 8%. |
| Electrical share of total building cost | 9 | 📐 rule of thumb | [৮-৪] বিঃদ্রঃ (খ) gives electrical as 7%. |
| Foundation cost up to plinth level, as a share of total building cost | 20 | 📐 rule of thumb | The same book gives foundation as 6% ([৭-০](৭)(খ)২), 10% ([৮-৩](১)) and 15% ([৮-১]). |
| Foundation up to plinth, including piling, as a share of building cost | 10 | 📐 rule of thumb | The same book gives foundation as 6%, 15% and 20% elsewhere. |
| Mason and labour cost as a share of construction cost | 20 | 📐 rule of thumb | Conflicts with [৭-০](১)(চ) at 15% and [৮-৪](৬) at 31%. |
| Plaster thickness on brick masonry walls | 0.5 | ✅ verified | Shipped guide.json card m4c6 (modules[4].cards[5]) tells readers outer walls are usually three-quarters of an inch — that is 19 mm, well above both the book's 1/2 inch and PWD's 12 mm minimu |
| Cement : sand : khoa ratio for mass concrete under the foundation | 1:3:6 | ✅ verified | Shipped pwd_sor_2022.json item 03.5.1 labels 1:2:4 as "Mass concrete in foundation". If the app prints "মাস কংক্রিট = ১:৩:৬", a reader comparing it with a PWD bill of quantities will be chec |
| cement plaster thickness in inches | 0.25 | ✅ verified | PWD SoR 2022 item 15.1.1, shipped in assets/content/rates/pwd_sor_2022.json, requires minimum 12 mm plaster on wall surfaces — twice this figure. Presenting 1/4 inch as the plaster thickness |
| cement plaster thickness in millimetres | 6 | ✅ verified | PWD SoR 2022 item 15.1.1 requires minimum 12 mm plaster on walls, so 6 mm must not be shipped as a general plaster thickness. |

---

## E. Where the book contradicts itself — 37

The same quantity, printed twice with different values. None ships until one is settled.

| Subject | Value given here | The conflict |
|---|---|---|
| bricks needed instead, if khoa is made on site, for 100 cft of 1:3:6 cement concrete | 450 | INTERNALLY INCONSISTENT: this is an alternative to 90 cft of khoa, but [৩-৫] item (২) states 100 cft of khoa takes 850 bricks, which would make 90 cft need about 765 bricks, not 450. The 1:2:4 and 1:1 |
| Khoa (brick chip) size used in patent stone floor concrete | 0.75 | Same passage gives the patent stone layer as 1/2 inch thick, which conflicts with the 1 to 1.5 inch figures elsewhere — a 3/4 inch aggregate in a 1/2 inch layer is not physically consistent, so the 1/ |
| drop height from which a 1st class brick should not break easily (identification list) | 3 | The book gives 3 ft here but 6 ft in the field-test list [৯-৫](গ)(২); the two passages disagree. Flag both to a reviewer before showing either in the app. |
| drop height in the two-brick T-shaped field drop test onto level ground | 6 | Conflicts with the 3 ft figure in [৯-৫](খ)(১). Also a safety concern: this is a field test the app would be telling a non-engineer to perform. |
| Cement : sand : khoa ratio for damp-proof course (DPC) | 1:1.5:3 | Conflicts with the book itself: the curing table [১২-৫] and the chapter 3 thumb rule both describe DPC as 1:2:4. Unresolved — flag before use. |
| DPC casting ratio quoted in the thumb-rule section | 1:2:4 | Conflicts with [১২-৪], which gives DPC as 1:1.5:3; agrees with the DPC label in the curing table [১২-৫]. |
| Water supply and sanitary share of total building cost | 15 | Conflicts with [৮-৪]'s footnote, which gives 8% for the same item. |
| Electrical share of total building cost | 9 | Conflicts with [৮-৪]'s footnote, which gives 7%. |
| Hours after casting before curing starts for roof slab casting | 20 | Other passages in the book say curing begins 24 hours after casting; the table says 20. Unresolved conflict. |
| Hours after casting before curing starts for floor concrete casting (1:3:6) | 20 | The chapter 13 floor method text instead says 18 hours; and the duplicate curing table in chapter 2 labels this row (1:2:4) rather than (1:3:6). Both discrepancies unresolved. |
| Hours after casting before curing starts, stated generally for concrete casting | 24 | This general 24-hour figure conflicts with the 12/15/20-hour item-specific values in the curing table [১২-৫]. The table is the more specific source. |
| Hours after floor casting before ponded curing starts | 18 | Conflicts with the 20 hours given for floor casting in [১২-৫]. Method described is ponding water within a temporary kerb. |
| Foundation share of building structure cost | 6 | Conflicts with chapter 8's tables, which put foundation at 10% ([৮-৩]), 15% ([৮-১]) and 20% ([৮-২]). The book gives four different foundation shares in four places. |
| floor mosaic thickness in millimetres as printed | 10 | INCONSISTENT WITH THE INCH FIGURE IN THE SAME LINE: 3/4 inch is 19 mm, not 10 mm. One of the two is a misprint; do not publish either without checking the printed page. |
| Thickness of jolchhad layer | 4 | The book is inconsistent: elsewhere it states 3 inches, and section [১-১৪] gives an average range of 3 to 4 inches depending on roof area and rainfall. Do not present 4 inches as the single figure. |
| Labour cost as a share of total building cost (thumb rule) | 15 | Conflicts with the book's own chapter 8 tables, which give labour as 31% ([৮-৪]) and mason+labour as 20% ([৮-৫]). Do not present these three as agreeing. |
| Labour (mason and worker) cost as a share of building cost | 31 | The book's single largest labour figure. It conflicts with the 15% thumb rule in the appendix and the 20% in [৮-৫]. If the app shows one labour share, show the range 15-31% and say the source disagree |
| length of each steel rod piece taken as a lab sample | 1 | OCR/print conflict: 1 metre is about 3.3 ft, not 6 ft. The parenthetical foot value is inconsistent with the metric value; do not publish the 6 ft figure without checking the printed page. |
| Thickness of grey mosaic layer | 0.5 | Conflicts with the chapter 3 thumb rule, which uses 3/4 inch floor mosaic. |
| Floor mosaic thickness used in the thumb-rule estimate | 0.75 | Unit mismatch in the source: 3/4 inch is 19 mm, not 10 mm. Either the inch or the mm figure is wrong (10 mm would be about 3/8 inch). Also conflicts with the 0.5 inch grey mosaic in [১২-৩]. Do not pub |
| Thickness of patent stone layer | 1-1.5 | Elsewhere the book gives 1 inch (25 mm) in the chapter 3 thumb rule and 1/2 inch in the chapter 13 method text — three different figures; unresolved. |
| Cement-to-sand plaster ratio for sunshade, cornice and drip-course | 1:2 | No thickness printed for this row. Note the same book row [১২-২](২) gives 1:4 for sunshade/cornice as an RCC member — the two rows disagree for sunshade and cornice; treat as unresolved. |
| sample plot dimensions and area for a 1.75 katha plot | 25 × 50 = 1250 | At the book's own 720 sqft/katha (implied by every other row), 1.75 katha is 1260 sqft, not 1250. The 25×50 rectangle does give 1250 sqft, so the katha figure and the area are slightly inconsistent. |
| G.I. wire gauge specified for tying reinforcement | 26 | Conflicts with the 22 gauge (22 SWG) given for tying slab, column and beam rods in the chapter 13 rod-laying list. Both figures appear in the same book. |
| wire gauge specified for tying slab, column and beam rods firmly in place | 22 | Conflicts with the 26 gauge given in [৯-৯] and in the note under table [৯-২]. Two different gauges for the same job in one book — needs a reviewer decision before the app shows either. |
| dining room, standard size | 11 × 12 | 11 ft is 3.35 m, but 3.08 m is printed; the two unit columns disagree for this row. |
| Septic tank size (L x W x depth) for 100 users, as given in the thumb-rules appendix | 11x?x4.5 | OCR damaged and it CONFLICTS with the book's own Table (১১-১), which gives 100 users as 11'-0" x 6'-0" x 5'-10". The width "৪-২'" is unreadable and the depth disagrees with the table. Do not publish t |
| Septic tank size (L x W x depth) for 250 users, as given in the thumb-rules appendix | 21x6x7.17 | Uncertain and CONFLICTING. The depth "৭-২'" is almost certainly 7 ft 2 in. Chapter 11 Table (১১-১) has no 250-user row; it has a 200-user row of 22'-0" x 6'-0" x 7'-2" — same depth and width but a dif |
| Septic tank size (L x W x depth) for 100 users, chapter 11 table | 11x6x5.83 | Depth is 5 ft 10 in. This CONFLICTS with the thumb-rules appendix entry for 100 users (depth 4.5 ft, width unreadable). Prefer this table row, but flag both for human review against the printed book. |
| septic tank length, width and depth for 100 users | 11 × 6 × 5.83 | Conflicts with the appendix, which gives 11' × 4'-2" × 4.5' for 100 users. The two figures cannot both be right; the book does not reconcile them. Do not publish either without a second source. |
| septic tank length, width and depth for 200 users | 22 × 6 × 7.17 | Opening bracket missing on the length cell (OCR). The appendix instead gives a 250-user row of 21' × 6' × 7'-2" — similar dimensions but a different user count, so the two tables disagree on capacity. |
| septic tank size for 100 users as given in the appendix | 11 × 4.17 × 4.5 | Width printed as '৪-২'', read as 4 ft 2 in. This contradicts টেবিল (১১-১), which gives 11' × 6' × 5'-10" for the same 100 users. Flag as unresolved — do not show a 100-user septic tank size from this  |
| septic tank size for 250 users as given in the appendix | 21 × 6 × 7.17 | Depth printed as '৭-২'', read as 7 ft 2 in. টেবিল (১১-১) gives nearly the same tank (22' × 6' × 7'-2") but for 200 users, not 250 — the two parts of the book disagree on how many people this size serv |
| Sanitary and water supply cost as a share of building cost (footnote) | 8 | Conflicts with the 15% given in [৮-১] and in the appendix list. |
| Electrical installation cost as a share of building cost (footnote) | 7 | Conflicts with the 9% given in [৮-১] and in the appendix list. |
| one hundredweight (হন্দর) expressed in kilograms | 50 | Rounded: 112 lb is 50.8 kg, so the book's own two figures in this row are inconsistent by about 1.6%. Treat 50 kg as the trade rounding (it matches the cement-bag convention). |
| average water a person uses in a day | 30 | Conflicts with the appendix figure of a 10 gallon per person per day minimum. These are different quantities — average use versus a design minimum — so both can stand, but the app must label which is  |

---

## F. From the 2025 Bidhimala, read off the gazette

Read directly from the rendered pages of the gazette PDF, not from its text layer,
which is legacy-encoded Bangla and unusable for numbers. Verdict **verified**:
each figure was read off the printed page and the rule it sits in is named.

**Source for all rows:** ঢাকা মহানগর ইমারত বিধিমালা, ২০২৫ — S.R.O. 469-Ain/2025,
Bangladesh Gazette extraordinary, 14 December 2025.

### সারণি-১ — minimum setbacks (gazette page 13452)

| Storeys | Between buildings on one plot (m) | Side setback (m) | Rear setback (m) |
|---|---|---|---|
| up to 7 | 2.00 | 1.00 | 1.25 |
| 8 to 10 | 2.50 | 1.25 | 2.00 |
| 11 to 15 | 5.00 | 3.00 | 3.00 |
| 16 to 20 | 6.00 | 3.25 | 3.25 |
| 21 to 30 | 6.5 | 3.50 | 3.50 |
| 31 to 40 | 7 | 4.50 | 4.50 |
| above 40 | 10.00 | 5.00 | 5.00 |

Measured from the boundary line. Non-residential uses on the master plan's wider
roads may require more. Residential hotel (A-5), education (B), health (D),
assembly (I), commercial (F), business (E), industry (G2), godown (H), hazardous
(J) and mixed-use buildings need a minimum 6 m wide space across the plot frontage
kept clear for vehicles to load and unload.

### Roads and FAR (gazette page 13466)

| Rule | What it says |
|---|---|
| (7) | A plot fronting a road 2.5 m or wider but under 6 m: the road is widened to 6 m. Old Dhaka only, densely populated areas per the master plan, may be approved down to not less than 1.8 m |
| (8) | Where widening is proposed, road-based FAR is the **average** of the existing-road and proposed-road FAR |
| (9) | Land for widening is surrendered **half from each side**, transferred to local government by easement deed |
| (10) | A plot with more than one road takes the **existing width of the widest** |
| (11) | Block-based development: base FAR, maximum FAR and density are redetermined per the detailed area plan |
| (12) | Where base FAR and maximum FAR differ by **0.1 or less**, the applicant gets maximum FAR unconditionally |
| (14) | If a plot's use changes, the **smaller** of the two FARs applies, and a Traffic Impact Assessment is required |
| (15) | The planning permit states the residential units and the FAR index |

**Not extracted, and deliberately not shipped:** the FAR value tables themselves.
FAR depends on master-plan zone, road width, use and the detailed area plan for the
block, so a figure printed in the app would be read as an answer when it is at best
an input. The module says so and sends the reader to an architect and to RAJUK.
