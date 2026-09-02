# নির্মাণ পাহারা v2 — from monitoring app to complete construction guide

**Status:** plan, not yet implemented. Written 2026-09-02.
**Baseline:** v1.0.0 shipped — 11 guide modules / 42 cards, 6 calculators, 5 checklists,
1,749 PWD SoR items, schedule-import + anomaly analysis, photo evidence, PDF report, rights module.

---

## 0. What the new source is, and what we may take from it

`003-138_markdown_output/` is an OCR + image extraction of **কিভাবে সহজে বাড়ি নির্মাণ এবং সাইট
সুপারভিশন করবেন?** — মোহাম্মদ আলী সিদ্দিকী (বি.এস.সি. ইঞ্জিনিয়ার, সিভিল, বুয়েট; Life Fellow, IEB
F/7218), রাফসান পাবলিকেশন, latest edition January 2019, cover price Tk 300, sponsored by
Shah Cement Industries Ltd. 16 chapters + 3 inserted chapters + 8 appendices; 164 extracted
images; ~677 KB of text.

It is a genuinely good book and it fills the exact hole v1 has: v1 knows how to *check* work,
this book knows how to *do and sequence* it. But it is in copyright, and the plan has to be
precise about which parts of it can travel into the app.

### The line we work to

| Layer | Copyright status | What we do |
|---|---|---|
| **Facts and figures** — mix ratios, curing days, FM values, hook = 12d, striking times, material-per-100-sft coefficients, unit conversions | Not protectable. Facts. Most also appear in PWD SoR / BNBC / standard practice | **Use freely, but verify each against a citable source before it ships.** The book becomes a checklist of *what to cover*, not the authority we cite |
| **Prose** | Protected | **Do not paraphrase sentence-by-sentence.** Write fresh from the verified fact, in the app's own voice (§4). A rewrite that tracks the original's sentence order is still a derivative |
| **Tables as arrangements** | Thin compilation right | Re-derive from the underlying facts and re-order/regroup for the app's own use; never reproduce a table's layout and selection wholesale |
| **The 164 images** | Protected — and many are not even the book's own (the column-tie and standard-hook plates are recognisably ACI/CRSI-derived) | **Never ship a scan.** Redraw as painted diagrams (§5) |
| **Directories** — libraries, 22 loan institutions, soil-test firms, design consultancies | Compilation, and seven years stale | **Drop entirely.** Stale phone numbers in a trust app are worse than no numbers |
| **Shah Cement pages** (0105-00, 0108-24, 0116-23 and the brand plate) | Sponsor advertising | **Drop.** A monitoring app that carries a cement brand's copy has no standing to judge cement |

**Attribution.** We cite the book once, in `NOTICE` and the in-app about page, as a source
consulted — not as the source of any specific claim. Every claim in the app cites BNBC 2020,
PWD SoR 2022, BDS, or the LGED/RHD standard it actually rests on. If a fact appears only in
this book and nowhere citable, it does not ship.

### Four things in the book that must not ship as-is

1. **Chapter 7 cites ইমারত নির্মাণ বিধিমালা ১৯৯৬.** Superseded by the 2008 Bidhimala and again by
   the **Dhaka Imarat Nirman Bidhimala 2025** (gazetted ~Aug 2025) plus the DAP 2022–35
   amendment. Every FAR, setback and approval number must be rewritten from the 2025 gazette.
2. **Plinth-area rates of Tk 1,500–2,500/sft** are January-2019 numbers. Meaningless in 2026 and
   actively harmful if a homeowner budgets against them. Replaced by a live calculation off the
   PWD SoR 2022 table already in the app, with the rate basis and its date shown.
3. **Several thumb rules are unsafe if read as design.** "Foundation depth in feet = number of
   storeys" and "beam depth in inches = span in feet" are estimator's shortcuts, not engineering.
   They ship only inside a **রুলস অব থাম্ব** card type that says on its face: this is for sanity-
   checking a number someone quoted you, not for deciding a dimension. New `ReviewStatus.ruleOfThumb`.
4. **Nominal mixes quoted in psi** (2600 psi for 1:2:4, 2900 psi for 1:1.5:3). Keep the mix
   ratios — masons work in them — but present strength in BNBC Part 6 / ACI terms with the psi
   equivalent alongside, and say plainly that a nominal ratio is not a strength guarantee
   without a cylinder test.

---

## 1. Shape of v2

v1 answered *"is this work being done right?"* v2 also answers *"how is this work supposed to be
done, and what should it cost?"* — for someone who has never read a drawing.

Three audiences, one content engine, explicitly layered so the general reader is never made to
scroll past detailing tables:

```
Tier 1 · সাধারণ পাঠক     — every guide card. Plain Bangla, one diagram, one number, "কী দেখবেন"
Tier 2 · কাজ যিনি করাচ্ছেন — calculators, measurement tools, stage checklists, cost check
Tier 3 · প্রকৌশলীর রেফারেন্স — a separate section at the end. Detailing, foundation types,
                            bore logs, RCC sections. Gated behind its own entry, never mixed in
```

Tier 3 is what "also for engineers, reference at last" means in the UI: a distinct
**রেফারেন্স** destination on home, after everything else, with its own index. A homeowner never
lands in it by accident; an SAE can live in it.

---

## 2. Content map — book chapter → app destination

Existing modules are extended, not replaced. **New** = does not exist in v1 at all.

| Book | App destination | New? | Cards |
|---|---|---|---|
| Ch 1 — ভূমিকম্প প্রস্তুতি | `m10_safety` extended + new `m20_earthquake` | new | 5 |
| Ch 2 + extra-1 — নির্মাণ সতর্কতা, ফাউন্ডেশন সতর্কতা | `m1_basics`, `m6_stagewise` | partial | 4 |
| Ch 3 — গাণিতিক সূত্র, একক | **Measurement tools** (§3) + `m13_measure` | new | 4 |
| Ch 4 — সাইট পরিদর্শন, জমি নির্বাচন ও ক্রয় | new `m14_site_land` | **new** | 6 |
| Ch 5 — সয়েল টেস্ট | new `m15_soil` | **new** | 5 |
| Ch 6 — আর্কিটেকচারাল প্ল্যান | new `m16_drawings` | **new** | 6 |
| Ch 7 — প্ল্যান পাশ (**rewrite to Bidhimala 2025**) | new `m17_approval` | **new** | 5 |
| Ch 8 — এস্টিমেট ও নির্মাণ ব্যয় | `m7` calculators + new `m18_estimate` | partial | 5 |
| Ch 9 — নির্মাণ সামগ্রী ও টেস্ট | `m3_materials` 4 → 11 cards | extend | +7 |
| Ch 10 — ব্যয় কমানোর উপায় | new `m19_cost_control` | **new** | 4 |
| Ch 11 — সার্ভিস (বিদ্যুৎ, পানি, স্যানিটেশন, গ্যাস, লিফট) | new `m21_services` + electrical checklist | **new** | 7 |
| Ch 12 — কোয়ালিটি কন্ট্রোল (মিশ্রণ, কিউরিং, সাটারিং ছক) | **Lookup tools** (§3) + `m4_mixing` | extend | +3 |
| Ch 13 — নির্মাণ পরিকল্পনা ও ধাপ | drives new **stage sequence** in inspection | **new** | 4 |
| Ch 14 — ফাউন্ডেশন, সুপার-স্ট্রাকচার, ফিনিশিং | `m6_stagewise` + building checklist | extend | +5 |
| Ch 15 — সংস্কার, ড্যাম্প, উঁইপোকা, নিষ্কাশন | `repair.json` + new `m22_maintenance` | **new** | 6 |
| Ch 16 — ভূমিকম্প, অগ্নি, নিরাপত্তা, ঠিকাদার নিয়োগ | `m10_safety`, `m11_contract`, `m12_malpractice` | extend | +4 |
| extra-2 — ফাউন্ডেশনের প্রকারভেদ | **Tier 3 reference** | **new** | 8 |
| extra-3 + appendix 5, 8 — টেকনিক্যাল বিষয়, RCC রড সেটিং | **Tier 3 reference** | **new** | 12 |
| appendix 1–4, 6, 7 — directories, sponsor | dropped | — | 0 |

**Result: 42 cards → ~145 cards, 11 modules → 22 modules + a 20-card engineer reference.**

---

## 3. Measurement tools and calculators — the complete set

v1 has 6 calculators. v2 has 18, in three groups. Every one keeps the v1 contract: it returns
the number **and the formula** **and the assumption list**, so a contractor can be argued with
rather than just contradicted.

### A · পরিমাপ (measurement) — new group

| Tool | What it does | Source of truth |
|---|---|---|
| **একক রূপান্তর** | ft↔m, sft↔m², cft↔m³, kg↔md↔lb↔ton, psi↔MPa↔kg/cm² | SI definitions |
| **জমির একক** | শতক / কাঠা / বিঘা / একর / হেক্টর / sft, both directions | Bangladesh land measure |
| **ক্ষেত্রফল ও আয়তন** | rectangle, triangle, trapezium, circle, cylinder, cone, sphere, pyramid — pick a shape, enter dimensions | geometry |
| **অনিয়মিত জমি** | irregular plot area by breaking into triangles from a corner | geometry |
| **সুতা ↔ মিমি ↔ ইঞ্চি** | the sizing masons actually speak — ৩-সুতা = ⅜″ = 10 mm, ৫-সুতা = ⅝″ = 16 mm | trade convention + BDS ISO 6935 |
| **কত মিস্ত্রী, কত দিন** | quantity → mason-days + labourer-days, so you can tell whether the gang on site matches the work billed | PWD SoR analysis-of-rates labour coefficients |

The সুতা converter is small and matters more than it looks: v1 asks for rod diameter in mm and
every mason on every site in Bangladesh says সুতা. That mismatch alone loses users on the first
screen.

### B · হিসাব (quantity) — 6 existing, 5 new

Existing: rod weight, concrete materials, brickwork, plaster, slab volume, road layer.

| New tool | Output |
|---|---|
| **হুক ও ল্যাপ** | hook length at 12d, lap length, and where a lap is not allowed, per bar diameter |
| **সিঁড়ি** | floor-to-floor height → riser count, riser and tread, landing, against the ≥10″ tread / ≤6″ riser floor |
| **পানির ট্যাংক** | occupants + storeys → underground reservoir and overhead tank volume at 10 gal/person/day |
| **সেপটিক ট্যাংক ও সোকপিট** | users → tank dimensions and soak-pit sizing |
| **ইটের সলিং ও হেরিংবোন** | area → brick count and filling sand |

### C · যাচাই (verification lookups) — new group

These are not calculators, they are *"what should it be?"* lookups — the single most-used thing
in the book, and what a person standing on a site actually needs in ten seconds.

| Lookup | Answers |
|---|---|
| **মিশ্রণ অনুপাত** | pick the work item (10″ wall / 5″ wall / ceiling plaster / DPC / septic tank / drain / floor) → the mortar, plaster or concrete ratio for it |
| **কিউরিং সময়সূচি** | pick the item → when curing starts and how many days it runs. 7 days for brickwork and plaster, 28 for a slab or lintel |
| **সাটারিং খোলার সময়** | span → earliest striking day, floor with a hard minimum of 14 days |
| **বালুর এফ.এম.** | which sand for which job — ভিটি 0.5 filling only, চিকন 1.05 plaster, মধ্যম মোটা 1.5 mortar, মোটা 2.0 concrete, সিলেট 2.5 |
| **খরচের ভাগ** | element-wise share of a building's cost — brickwork ~30%, roof ~20%, doors/windows ~16%, plaster+paint ~10% — so an inflated single item stands out |
| **রুলস অব থাম্ব** | the estimator's shortcuts, each behind the "not a design method" banner of §0.3 |

The কিউরিং and সাটারিং lookups tie straight into v1's inspection run: a checklist item that
fails on curing now offers "কত দিন লাগার কথা?" inline instead of sending the user out to the guide.

---

## 4. Writing — how ~145 cards get written without touching the book's prose

Method, applied per card:

1. **Extract the fact** from the book (a number, a ratio, a sequence, a failure mode).
2. **Verify it** against BNBC 2020 / PWD SoR 2022 / BDS / LGED standard drawing. Record the
   citation. If it does not verify, it does not ship — or it ships with the amber
   `review` badge v1 already has.
3. **Write the card from the verified fact**, in the app's house voice, with the book closed.
4. **Claim edit-pass** before commit — the same one already enforced on public copy.

House voice, unchanged from v1's `CONTENT_RULES.md`: open with a hook the reader recognises, not
a definition. Address them directly (আপনি/আপনার). Colloquial verbs. English technical nouns
transliterated (কিউরিং, কভার ব্লক, স্টিরাপ, সাটারিং, এফ.এম.). Every bullet is a short label plus
one concrete sentence with a real number in it. No superlatives. Never assert fraud — state the
standard, state the observation, let the gap be the finding.

`docs/CONTENT_REVIEW.md` grows from 44 claims to roughly 190. The 34 already awaiting a licensed
engineer's sign-off stay on the list; the new ones join it. Amber badge on every unsigned claim,
same as v1.

---

## 5. Images — recalibration

**Triage of the 164 extracted images:**

| Class | Count | Disposition |
|---|---|---|
| House floor plans (0034–0048) | ~38 | **Drop.** Architects' plans, no monitoring value, worst copyright exposure |
| Sponsor pages, chapter title plates, OCR text fragments | ~14 | **Drop** |
| Sub-100 px artefacts (26×46, 68×21) | ~10 | **Drop** |
| Duplicate / near-duplicate plates | ~8 | **Drop** |
| Data presented as an image (mix tables, water-% tables, org flowcharts) | ~15 | **Convert to native widgets** — a real table or list, searchable and screen-reader-readable, not a picture of a table |
| **Tier 1 — general reader diagrams** | **~30** | **Redraw** |
| **Tier 3 — engineer reference diagrams** | **~35** | **Redraw** |
| Low-priority (bath fittings, window styles, grills) | ~14 | Defer to v2.1 |

**~65 diagrams to redraw. ~85 dropped. ~15 become native UI.**

Every redraw is a `CustomPainter` in `lib/features/guide/diagrams/`, extending the existing
`DiagramPalette` / `paintLabel` base, following the rule already written into `diagram_base.dart`:
*every dimension shown is one this code put there.* Bangla labels shape through the same text
engine as the rest of the app, colours follow light and dark theme, and the whole set adds well
under a megabyte instead of the 20 MB the scans weigh.

**Tier 1 redraw list (~30)** — the ones a homeowner or a UP member needs:

- বালুর সিল্ট টেস্ট — the 4-step bottle/jar test, the single most useful figure in the book
- ইটের বন্ড — English, Flemish, header, stretcher, and what a wrong bond looks like
- ইটের অংশ — closer, half, queen closer, king closer
- কলামের টাই বিন্যাস — 4/6/8/12/16 bar arrangements with alternating hook positions
- স্ট্যান্ডার্ড হুক — 12d extension, bend radius by bar size
- ল্যাপ ও যেখানে ল্যাপ দেওয়া যাবে না
- কভার ব্লক — 25 mm at a beam, more against earth, in section
- স্টিরাপ ঘনত্ব — tightening near supports
- স্ল্যাবের রড বিন্যাস — main vs distribution, top extra over supports, in plan and section
- লিন্টেল ও সানসেড সেকশন
- গ্রেড বিম লং-সেকশন
- ফুটিং সেকশন — mass concrete, footing, plinth, DPC, plinth level above road
- ইটের সলিং ও হেরিংবোন প্যাটার্ন
- প্লিন্থ ও ড্যাম্প-প্রুফ কোর্স
- সিঁড়ির সেকশন — riser, tread, landing, handrail height
- ডগলেগ সিঁড়ির প্ল্যান
- ছাদের ওয়াটারপ্রুফিং স্তর
- এক্সপ্যানশন জয়েন্ট
- ভবনের অংশের নাম — plinth, lintel, sunshade, parapet, chajja, in one labelled section
- প্লটের ফ্রন্ট / সাইড / রিয়ার — what each setback is measured from
- সেপটিক ট্যাংক — plan and section
- সোকপিট / সোকওয়েল
- ট্র্যাপ — P, S, Q and the nahani trap, and why a dry trap smells
- পাইপ ফিটিংস — bend, tee, junction, cleanout
- পয়েন্টিং-এর ধরন — flush, cut, V, weathered
- জলছাদ স্তর
- বিদ্যুৎ লাইনের কনসিল্ড রুট
- ওভারহেড ট্যাংক ও রিজার্ভার বিন্যাস
- ভূমিকম্প জোন ম্যাপ — redrawn from the BNBC 2020 zone map, not the book's plate
- কনফাইনিং রিইনফোর্সমেন্ট — the seismic detail at a footing and a joint

**Tier 3 redraw list (~35)** — foundation types (isolated, combined, strap, raft, pile,
well/caisson), pile classes (bearing, friction, sheet, batter, anchor, precast, timber, H-pile),
pile cap and pile group, bore log and SPT chart, core chart of formations, wash/percussion/rotary
boring, dewatering, cofferdam, column-beam joint detailing, flat slab and drop panel, cantilever
and canopy, RCC column classification by shape, inverted arch footing, combined footing types.

---

## 6. What changes in code

New, small, and mostly additive — the v1 engine already has the right shapes.

```
lib/
  core/content/
    models.dart              + ReviewStatus.ruleOfThumb, + CardTier (general|work|reference)
    lookup_models.dart       NEW  — the §3C verification tables
  features/
    measure/                 NEW  — unit, land, geometry, সুতা, gang-size tools
      logic/  units_extended.dart, land_units.dart, geometry.dart, sutas.dart, gang_size.dart
      ui/     measure_screen.dart
    calculators/logic/       + hook_lap.dart, stair.dart, water_tank.dart, septic.dart, soling.dart
    lookups/                 NEW  — mix ratio, curing, striking, FM, cost share, thumb rules
      logic/lookup_tables.dart      ui/lookup_screen.dart
    reference/               NEW  — Tier 3 engineer section, its own index
      ui/reference_screen.dart
    guide/diagrams/          + ~65 painters across 6 new files, grouped by subject
      materials_diagrams.dart, rebar_diagrams.dart, structure_diagrams.dart,
      services_diagrams.dart, foundation_diagrams.dart, site_diagrams.dart
assets/content/
  guide/guide.json           42 → ~145 cards (split into per-module files; 118 KB → ~400 KB
                             across files, so no single asset trips the 50 KB isolate threshold
                             that already bit us once in tests)
  lookups/lookups.json       NEW
  reference/reference.json   NEW
  checklists/*.json          extended with the ch-13 stage sequence
```

**Two known traps to respect, both already paid for once:**
- `rootBundle.loadString` moves UTF-8 decoding to a worker isolate above 50 KB, which hangs
  `pumpAndSettle`. Splitting `guide.json` per module keeps every file under it and keeps the
  existing test injection working.
- Theme `minimumSize` must stay `Size(64, minTapTarget)` — never `Size.fromHeight`.

**Tests.** v1 has 211. v2 adds: golden cases for all 11 new calculators hand-computed;
a lookup-table completeness test (every work item referenced by a checklist resolves to a mix
ratio); a diagram smoke test that every `diagram` key in content resolves to a painter and every
painter is referenced by at least one card; a content-integrity test that every card carries a
citation and a tier. Target ~290.

**Size.** ~65 painters ≈ 250 KB of Dart. Content ≈ 400 KB. No new binary assets. Estimated
bundle growth under 1 MB against v1's 57.3 MB — the scans would have added 20 MB.

---

## 7. Order of work

| Phase | Deliverable | Gate |
|---|---|---|
| 1 | Fact-extraction sheet: every number from the book → its verifying source → verdict (verified / review / rule-of-thumb / rejected) | Nothing is written until this exists. This is the phase that keeps us honest |
| 2 | Measurement tools + the 5 new calculators + §3C lookups, pure Dart, tested against hand-computed goldens | `flutter test` green |
| 3 | Tier 1 diagrams (~30) | Every one visually reviewed against the fact it teaches, not against the book's plate |
| 4 | Guide content: the 11 new modules + 5 extended, written per §4, claim edit-pass applied | `CONTENT_REVIEW.md` regenerated |
| 5 | Tier 3 reference section + its ~35 diagrams | — |
| 6 | Inspection stage sequence from ch 13 wired into the checklist packs; curing/striking lookups linked from failing items | — |
| 7 | Bidhimala 2025 rewrite of the approval module | **Blocked on obtaining the 2025 gazette.** Ships in 2.1 if the gazette is not in hand; the module carries a dated "যাচাই করুন" banner until then |
| 8 | Version 1.1.0, `NOTICE` attribution, Play listing update, release | Signed bundle, analyzer clean |

---

## 8. Risks specific to this integration

| Risk | Mitigation |
|---|---|
| **Paraphrase creep** — a writer under time pressure reverts to sentence-level rewriting | Phase 1 forces fact-first. Cards are written from the extraction sheet, not from the book text. Spot-check a random 10% against the source for structural similarity before release |
| **Stale numbers shipping as current** | Every card carries `updated:` and its citation's year. The 2019 rates never enter the app; costs are computed live off the SoR table |
| **A thumb rule read as a design rule** — the real safety exposure here | Dedicated card type, distinct visual treatment, explicit "this is for checking a quoted number, not for deciding one" line. Foundation depth and beam depth carry an additional "get this from a soil test and an engineer" line |
| **Tier 3 leaking into Tier 1** and burying the general reader | Tier is a field on the card, enforced by a test; the reference section is a separate destination reached only from the bottom of home |
| **Diagram redraw introducing an error the scan didn't have** | Each painter's dimensions come from the extraction sheet's verified value, and the painter is reviewed against that value. Same discipline as v1's calculator goldens |
| **Content volume outrunning engineer review** | 190 claims is more than one reviewer will sign quickly. The amber badge means we can ship unsigned claims honestly; the alternative — waiting — ships nothing |

---

## 9. What this does not do

- No design. The app still refuses to tell anyone a bar size or a footing dimension. It tells
  them what to measure, what the standard says, and when to get an engineer.
- No plan approval service, no drawing generation, no structural calculation.
- No house plans. The book's 38 floor plans are not reproduced and no substitutes are drawn —
  a plan is an architect's work product, not reference content.
- No backend. Still fully offline.

---

## 13. Addendum — LSD godown drawings and the Patnitala BoQ (2026-09-02)

Three further documents were supplied: the Directorate General of Food working-drawing set for a
1000 MT capacity godown (Aug 2024, consultant JV of Shaheedullah & Associates Ltd. and Shahidul
Consultant Ltd.), a 1000 MT godown floor plan, and the complete BoQ for an office building at
Patnitala LSD, Naogaon (FY 2025-26, Tk 2,978,819.142).

These matter more than the book, because the godown set is a **type design for a national
programme** — "New Food Godowns … in Different Strategic Locations Across The Country" — so its
dimensions recur at many sites rather than one.

**Copyright.** The sheets carry an explicit instrument-of-service notice reserving them to the
consultant and forbidding use on other projects. Same rule as §0: derive facts, redraw, never ship
a sheet, never imply consultant endorsement. The Patnitala BoQ is a live FY2025-26 procurement
naming real officers — reference only, never published.

### 13.1 What it gives the app

| Use | Value | Note |
|---|---|---|
| 76 tape-measurable checks (godown, RCC road, boundary wall, footings, slab) | **High** | Converts `godown.json` from qualitative to measurable |
| Real BoQ item skeleton for an LSD office building — civil, sanitary, electrical | **High** | `expected_items.dart` profiles are currently invented |
| Cross-validation of the shipped SoR 2022 table against a FY2025-26 estimate | **High** | Two of three sampled items match; see §13.3 |
| The কারিগরি প্রতিবেদন as the register the receiving officer actually reads | Medium | Report format target |
| Cleaner diagram sources than the 2019 book's scans | Medium | Still redraw, not reuse |

### 13.2 Framing the dimensions honestly

The app must **not** hardcode 4'-0" gangway as universal truth — it is this type design's figure.
The correct teaching is: *get the approved drawing for your site, find the dimension, measure it.*
This set becomes the worked example, and "ask for the approved drawing" becomes an RTI target in
the rights module. That is both honest and more actionable than a hardcoded number.

### 13.3 Rate cross-check (SoR 2022 vs Patnitala FY2025-26)

| Item | App, 4 regions | BoQ | Verdict |
|---|---|---|---|
| Brick work 1:6 superstructure | 8,987–9,394 /cum | 9,340 | inside band |
| Brick flat soling, solid block | 607–613 /sqm | 607 | exact |
| 75 mm DPC (1:1.5:3) | 1,563–1,642 /sqm | 1,312 | 16% below — ask, may be a different spec |

Abstract reconciles exactly: 2,296,116.412 + 395,833.194 + 286,869.536 = 2,978,819.142.

### 13.4 Defects this material exposed

1. **`schedule_row_parser.dart:16`** — `_scheduleQtyWords` lacks bare `quantity`/`qty`/`পরিমাণ`;
   `_serialWords` `'sl'` does not match the header `S.L No.`. An ordinary estimate BoQ therefore
   imports with serial and quantity **null**, which can manufacture false
   "billed with nothing scheduled" findings. Fix: fall back to bare `quantity` only when no
   specific schedule/measured term matched, so running bills keep their current mapping.
2. **`boq_text_parser.dart:16`** — serial regex needs 2+ spaces after the number, so `1.05(a)`,
   `1.22(b)`, `06.1.4Gp` never match; and the emit guard needs ≥5 trailing numbers, which an
   estimate BoQ (qty, rate, amount) never has. The text path reads running statements only.
3. **The rate table has no electrical works.** See §13.5.

### 13.5 The rate schedule is the civil volume only

`pwd_sor_2022.json` holds **32 chapters, 1,749 items**, four regional columns, markups recorded
(10% profit, 3.5% overhead, 10% VAT) — the complete civil works volume, including sanitary and
water supply (320 items), deep tube-well (185), gas (40) and repair works (225).

It does **not** include PWD's separate **Schedule of Rates for Electrical Works**. Searching the
shipped table returns zero items for conduit, switch, light point, fan point, circuit breaker,
earthing, sub-distribution board and energy meter.

Consequence: the Patnitala BoQ carries Tk 286,869.536 of electrical work — 9.6% of the contract,
codes 5.02–5.83 — that the app cannot rate-check at all, while shipping an electrical checklist.

**Resolved 2026-09-02 (v1.1.0).** PWD publishes electrical rates as the *E/M (electro-mechanical)*
volume: `Pwd_Schedule_Of_Rates_EM_2nd_revised.pdf`, 744 pages, same four zones as the civil book.
2,606 priced items across 19 subheads now ship as
`assets/content/rates/pwd_sor_em_2022.json`, selectable beside the civil volume. See §14.

Also note: the extraction script that produced `pwd_sor_2022.json` was never committed — only its
output. Re-run it against the source and assert the item count, so "complete" is testable rather
than asserted.

### 13.6 Discrepancies inside the drawing set itself

Reported as observations, not as errors, and drawn from scans that may themselves be misread:

- Every title block reads **500 MT CAPACITY NEW GODOWN** while the file, the cover sheet and the
  A-01 drawing body read **1000 MT**. The body was revised; the title blocks were not.
- Grid 1–7 spacings differ between structural sheets: S-02 (pile layout) gives
  15'-6"/11'-8"/15'-2"/15'-2"/11'-8"/15'-6"; S-08/S-09 (tie beam layout) gives
  16'-8"/11'-8"/14'-0"/14'-0"/11'-8"/16'-8". Both chains total 84'-8", but S-08 separately notes
  86'-8" overall.
- Sheet A-06's title block says NORTH ELEVATION; the drawing on it is labelled RIGHT SIDE ELEVATION.

This is a useful demonstration in its own right: the app's whole thesis is that a careful reader
comparing documents finds things, and a careful read of one drawing set found three.

---

## 14. Electrical rates — what shipped, and what it cost to trust it (v1.1.0)

`assets/content/rates/pwd_sor_em_2022.json` — **2,606 priced items, 19 subheads**, four zones,
848 KB, from `Pwd_Schedule_Of_Rates_EM_2nd_revised.pdf` (744 pages).

### Why it is a separate table, not merged into the civil one

- Its item numbering restarts per subhead, so codes collide with the civil volume's *and with
  each other*: `3.4` exists in more than one place. The key is (volume, subhead, code).
- Subheads are numbered `2.1`, `20.1` — `PwdRateItem.chapter` became a `String` for this.
- **It states no profit or overhead basis.** The civil volume builds in 10% + 3.5%; this one says
  nothing, and its subhead 13 prints rates explicitly "WITHOUT PROFIT, OVERHEAD". Markups are
  therefore null here and the app shows no markup note for this volume. Assuming the civil
  figures carried over would have been a guess dressed as a fact.

### Why the rates are read by geometry, not by splitting text

The four zone columns sit at different x positions in different page groups, the header wraps
differently between subheads, and some subheads repeat no header at all on continuation pages.
A whitespace split silently shifts a value one column left. Columns are located per page from the
header, and on header-less continuation pages from the alignment of the money cells themselves —
but only within the same subhead, so one subhead's layout is never applied to the next one's table.

### Two traps found by inspecting rather than assuming

1. **Subhead 13 is vehicle spare parts.** Its sixteen columns are car models — Pajero, Corolla,
   Lancer — not zones. Read naively, a Corolla axle-bearing price lands in the Rajshahi column.
   Excluded, and named in `not_included` so the gap is visible.
2. **The published PDF misprints rates.** Row 7.1.1.2 prints
   `109,117.00 | 1946 | 18789 | 18789`, where the row above it prints
   `92,722.00 | 92652 | 92395 | 92395`. Leading digits are dropped in the source. **282 rows**
   carry at least one such zone. Those values are recorded as *unavailable* and the app says
   "প্রকাশিত তফসিলে এই অঞ্চলের রেট স্পষ্ট নয়". They are never repaired by guessing: an invented
   rate in this app is worse than an absent one.

The suspect test is `value / row-maximum < 0.75`, calibrated against the data: legitimate
zone-to-zone variation never exceeds 1.25× across the rows that parse cleanly, so the gate cannot
be discarding real regional differences.

### Verification

- Eight rows spanning eight subheads were rendered from the PDF and compared cell by cell against
  the extraction. All matched, including units.
- An independent `pdftotext -layout` parse agrees on 2,279 rows; the disagreements were traced to
  the *text* parse misreading sizes like `3.4 mm.` as item codes, which the geometric parse
  correctly rejects by column position.
- Eight tests cover the volume, anchored on two rows verified against the rendered page.

### Not carried

Subhead 8 (Lift & Escalator) is not in this edition — PWD publishes it separately, and there is now
a **2026** edition of it (`Lift_escalator-2026.pdf`), newer than everything else the app ships.
Subhead 12 (solar) prices nothing here. Subhead 20.1 (Building Management System) prints no item
descriptions against its rows.

### Still open

The civil table's own extraction script was never committed — only its output — so "1,749 = every
civil item" remains asserted rather than tested. The E/M extractor should be committed under
`tool/` and both counts asserted.


---

## 15. The 2025 Bidhimala — found, and what it actually is (2026-09-02)

The plan-approval module was blocked on the gazette. It is no longer blocked.

**ঢাকা মহানগর ইমারত বিধিমালা, ২০২৫** — note the title, which is *ইমারত বিধিমালা*
and not *ইমারত নির্মাণ বিধিমালা* as this plan assumed throughout.

| | |
|---|---|
| Gazette | বাংলাদেশ গেজেট, অতিরিক্ত সংখ্যা — রবিবার, ১৪ ডিসেম্বর ২০২৫ |
| Notification | এস.আর.ও. নং ৪৬৯-আইন/২০২৫, dated ২৬ অগ্রহায়ণ ১৪৩২ / ১১ ডিসেম্বর ২০২৫ |
| Issued by | গৃহায়ন ও গণপূর্ত মন্ত্রণালয় |
| Power | Building Construction Act, 1952 (Act No. II of 1953), section 18 |
| Extent | The Dhaka Metropolitan Master Plan area under the Town Improvement Act, 1953 |
| Commencement | ইহা অবিলম্বে কার্যকর হইবে — in force immediately |
| Length | 112 pages, cover price Tk 96 |
| Source | RAJUK, via the ministry object store linked from rajuk.gov.bd's আইন ও বিধি page |

Rule 2(1) defines অনুমোদিত নকশা by reference to **Bangladesh National Building Code, 2020**, so
the Bidhimala and BNBC 2020 are read together rather than as alternatives.

**Two corrections this forces on the plan.** The commencement is December 2025, not the August
2025 this plan guessed; and the DAP 2022–35 amendment referenced alongside it is also December
2025. Any card citing either must carry those dates.

The gazette PDF is kept at the repository root for reference. It is a public government document,
but it is 5 MB of scanned Bangla and does not belong in the app bundle: cards cite the S.R.O.
number and rule number, and the reader is pointed at RAJUK for the text.

**Still required before the approval module ships:** the FAR, setback and height numbers have to be
read out of the gazette rule by rule, into `docs/FACTS_V2.md`, the same way everything else was.
Finding the document is not the same as having read it.
