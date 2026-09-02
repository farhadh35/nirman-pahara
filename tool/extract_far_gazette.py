#!/usr/bin/env python3
"""Extract Table 5 (road-width FAR) from the 2025 Dhaka building rules gazette.

The gazette's Bangla text layer is legacy-encoded, so `extract_text` returns
`(cid:NN)` tokens rather than characters. The digits, however, map one-to-one
and consistently, and the map below was not guessed: it was read off the
gazette's own column-number header row, where the printed cells (1) to (13)
pin every glyph to a digit.

Nothing here trusts that decoding on its own. The output is checked three ways
before it is written:

  * every FAR value lands on a quarter step, apart from three cells the gazette
    really does print as 2.3 / 2.8 / 3.3;
  * no row falls as the road gets wider;
  * no row is permitted, then dashed, then permitted again.

Those checks caught a real defect: a "6" bleeding out of the neighbouring
column turned row K2's 5.5 into 5.56. Cells that fail them are printed and the
asset is not written.

Usage:  python3 tool/extract_far_gazette.py <gazette.pdf> [out.json]
"""
import json
import re
import sys

import pdfplumber

# Read off the gazette's own "(1) ... (13)" column-number row.
DIGITS = {
    '(cid:27)': '1', '(cid:23)': '2', '(cid:29)': '3', '(cid:28)': '4',
    "'": '5', '(cid:24)': '6', 'r': '7', 's': '8', '&': '0',
}
PAGES = range(52, 57)          # PDF pages holding Table 5
BANDS = [(1.8, 2.5), (2.5, 3.66), (3.66, 4.88), (4.88, 6.0), (6.0, 9.0),
         (9.0, 12.0), (12.0, 18.0), (18.0, 24.0), (24.0, None)]
ZONES = [('central', 'কেন্দ্রীয় ঢাকা, পূর্বাচল, ঝিলমিল'),
         ('outer', 'বহিঃস্থ নগর অঞ্চল — যেমন নারায়ণগঞ্জ সিটি কর্পোরেশন, সাভার পৌরসভা'),
         ('other', 'অন্যান্য এলাকা')]
# Printed exactly as the gazette prints them; the codes come out of the PDF.
LABELS = json.load(open(__file__.replace('extract_far_gazette.py',
                                         'far_use_labels.json'), encoding='utf-8'))


def decode(cell):
    if not cell:
        return ''
    return ''.join(DIGITS.get(t, t) for t in re.findall(r'\(cid:\d+\)|.', cell))


def value(cell):
    """A dash means the use is not permitted on that road width.

    A cell holding both a dash and a digit is a dash: the digit has bled in
    from the column next door.
    """
    cell = cell.replace('*NR', '').replace(',', '').strip()
    if '-' in cell:
        return None
    found = re.findall(r'[0-9]+(?:\.[0-9]{1,2})?', cell)
    return float(found[0]) if found else None


def extract(path):
    doc = pdfplumber.open(path)
    rows = []
    for n in PAGES:
        page = doc.pages[n - 1]
        tables = page.find_tables()
        if not tables:
            continue
        tb = max(tables, key=lambda t: (t.bbox[2] - t.bbox[0]) * (t.bbox[3] - t.bbox[1]))
        for row in tb.rows:
            cells = [c for c in (row.cells or []) if c]
            if len(cells) < 10:
                continue
            text = [decode((page.crop(c).extract_text() or '').replace('\n', ' ').strip())
                    for c in cells]
            code = [t for t in text if re.fullmatch(r'[A-Z]\s?[0-9]?', t)]
            if len(code) != 1:
                continue
            band = text[-9:]
            rows.append({'code': code[0].replace(' ', ''),
                         'far': [value(b) for b in band],
                         'not_recommended': any('NR' in b for b in band)})
    return rows


def check(rows):
    bad = []
    for r in rows:
        vals = [v for v in r['far'] if v is not None]
        if not vals:
            bad.append((r['code'], 'no FAR value at all'))
        if vals != sorted(vals):
            bad.append((r['code'], f"falls as the road widens: {r['far']}"))
        idx = [i for i, v in enumerate(r['far']) if v is not None]
        if idx and idx != list(range(idx[0], len(r['far']))):
            bad.append((r['code'], f"permitted, then not, then permitted: {r['far']}"))
        for v in vals:
            if not (abs(v * 4 - round(v * 4)) < 1e-9 or v in (2.3, 2.8, 3.3)):
                bad.append((r['code'], f'{v} is off the quarter step'))
    return bad


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else 'assets/content/rules/far_2025.json'

    rows = extract(src)
    bad = check(rows)
    if bad:
        print('FAILED — the asset was not written:')
        for code, why in bad:
            print(f'  {code}: {why}')
        sys.exit(1)

    uses, seen_a = [], 0
    for r in rows:
        zone = None
        if r['code'].startswith('A'):
            zone = ZONES[seen_a // 6][0]
            seen_a += 1
        uses.append({'code': r['code'], 'zone': zone,
                     'label_bn': LABELS[r['code']], 'far': r['far'],
                     'not_recommended': r['not_recommended']})
    if seen_a != 18:
        sys.exit(f'expected 18 housing rows across 3 zones, found {seen_a}')

    doc = {
        'version': 1,
        'table': 'সারণি-৫ — প্লট সংলগ্ন বিদ্যমান রাস্তার জন্য প্রযোজ্য FAR সূচক',
        'source_bn': 'ঢাকা মহানগর ইমারত (নির্মাণ, উন্নয়ন, সংরক্ষণ ও অপসারণ) বিধিমালা, '
                     '২০২৫; এস.আর.ও. নং ৪৬৯-আইন/২০২৫; বাংলাদেশ গেজেট, অতিরিক্ত, '
                     '১৪ ডিসেম্বর ২০২৫, সারণি-৫ (গেজেট পৃষ্ঠা ১৩৪৬০–১৩৪৬৪)',
        'road_bands': [{'from_m': a, 'to_m': b} for a, b in BANDS],
        'zones': [{'id': i, 'label_bn': l} for i, l in ZONES],
        'uses': uses,
    }
    with open(out, 'w', encoding='utf-8') as fh:
        json.dump(doc, fh, ensure_ascii=False, indent=1)
    print(f'wrote {out}: {len(uses)} rows, {seen_a} of them housing')


if __name__ == '__main__':
    main()
