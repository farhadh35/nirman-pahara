"""Extract priced items from PWD Schedule of Rates 2022 for E/M Works (2nd revised).

Two things this has to survive, both found by inspecting the document rather than
assuming it is well formed:

1.  The four regional rate columns sit at different x positions on different page
    groups, the header wraps differently between subheads, and some subheads
    repeat no header at all on continuation pages.  Rates are therefore read by
    column geometry -- from the header where there is one, and otherwise from the
    alignment of the numeric cells themselves -- never by splitting on whitespace.

2.  The published document itself misprints some rates: row 7.1.1.2 reads
    "109,117.00 | 1946 | 18789 | 18789" where the row above it reads
    "92,722.00 | 92652 | 92395 | 92395".  Leading digits are dropped in the PDF.
    Those values are recorded as unavailable, never repaired by guessing, because
    a plausible invented rate is worse here than a missing one.
"""
import json, re
import pdfplumber

SRC = 'em_2nd.pdf'
NOT_ZONAL = {'13'}   # subhead 13 columns are vehicle models, not zones

NUM = re.compile(r'^[\d,]+(?:\.\d+)?$')
CODE = re.compile(r'^\d+(?:\.\d+){0,5}\.?$')
UNITS = {'each', 'each.', 'meter', 'metre', 'mtr', 'set', 'sets', 'day', 'job',
         'ft', 'ft.', 'feet', 'pc', 'pc.', 'pcs', 'pcs.', 'point', 'points',
         'kg', 'kg.', 'sft', 'sft.', 'cft', 'cft.', 'yard', 'nos', 'nos.',
         'no.', 'litre', 'liter', 'kit', 'pair', 'lot', 'rm', 'sqm', 'cum',
         'km', 'ton', 'hour', 'month', 'l.s.', 'ls'}

# Legitimate variation between the four zones never exceeds 1.25x across the
# 2,192 rows that parse cleanly, so a value below three-quarters of the row's
# highest is a misprint, not a regional difference.
SUSPECT_RATIO = 0.75


def num(t):
    t = t.replace(',', '').replace('Tk.', '').replace('Tk', '').strip().rstrip('.')
    if not t:
        return None
    try:
        return float(t)
    except ValueError:
        return None


def header_columns(words):
    """Column centres from the four "Rate" words of "Unit Rate in <zone>"."""
    xs = sorted((w['x0'] + w['x1']) / 2
                for w in words
                if w['text'].lower() == 'rate' and w['top'] < 160)
    if len(xs) == 5:                       # a stray "Rate" inside a spec heading
        gaps = [xs[i + 1] - xs[i] for i in range(4)]
        xs.pop(gaps.index(min(gaps)))
    if len(xs) != 4:
        return None
    gaps = [xs[i + 1] - xs[i] for i in range(3)]
    if min(gaps) <= 0 or max(gaps) / min(gaps) > 2.5:
        return None
    return xs


def numeric_columns(words):
    """Fallback for continuation pages that repeat no header: recover the four
    columns from the alignment of the money cells themselves."""
    cents = [round(((w['x0'] + w['x1']) / 2) / 6) * 6
             for w in words
             if NUM.match(w['text']) and w['top'] > 60
             and (w['x0'] + w['x1']) / 2 > 360 and len(w['text']) >= 3]
    if len(cents) < 8:
        return None
    freq = {}
    for c in cents:
        freq[c] = freq.get(c, 0) + 1
    top = sorted(freq.items(), key=lambda kv: -kv[1])[:4]
    if len(top) < 4 or min(v for _, v in top) < 2:
        return None
    xs = sorted(k for k, _ in top)
    gaps = [xs[i + 1] - xs[i] for i in range(3)]
    if min(gaps) < 25 or max(gaps) / min(gaps) > 2.5:
        return None
    return xs


def rows_of(words, tol=3.0):
    rows, cur, anchor = [], [], None
    for w in sorted(words, key=lambda w: (w['top'], w['x0'])):
        if anchor is None:
            cur, anchor = [w], w['top']
        elif abs(w['top'] - anchor) <= tol:
            cur.append(w)
        else:
            rows.append(sorted(cur, key=lambda w: w['x0']))
            cur, anchor = [w], w['top']
    if cur:
        rows.append(sorted(cur, key=lambda w: w['x0']))
    return rows


def item_column(words):
    """x0 of the "Item No." column, from the header. A wrapped description line
    can begin with something that looks like a code -- "3.4 mm." is a wall
    thickness, not item 3.4 -- and only the column position tells them apart."""
    for w in words:
        if w['text'] == 'Item' and w['top'] < 150:
            return w['x0']
    return None


def subhead_of(words):
    txt = ' '.join(w['text'] for w in words if w['top'] < 60)
    m = re.search(r'Subhead[ -]?([\d.]+)', txt)
    return m.group(1).rstrip('.') if m else None


def main():
    out, dropped = [], []
    headings, subhead, geom, item_x = {}, None, None, 57.0
    geom_sub = None
    misprinted = 0
    pdf = pdfplumber.open(SRC)

    for pno, page in enumerate(pdf.pages, 1):
        words = page.extract_words()
        if not words:
            continue
        sh = subhead_of(words)
        if sh:
            subhead = sh
        if subhead in NOT_ZONAL:
            geom, geom_sub = None, None
            continue
        ix = item_column(words)
        if ix is not None:
            item_x = ix
        xs = header_columns(words)
        if xs:
            geom, geom_sub = xs, subhead
        elif geom_sub == subhead:
            # a continuation page that repeats no header: reuse the geometry,
            # but only inside the same subhead, so one subhead's column layout
            # is never applied to the next one's table
            xs = numeric_columns(words)
            if xs:
                geom = xs
        else:
            geom, geom_sub = None, None
        if not geom:
            continue
        bounds = [(geom[i] + geom[i + 1]) / 2 for i in range(3)]
        left = geom[0] - (geom[1] - geom[0]) * 0.55

        pending = None          # a coded row still waiting for its rates
        for row in rows_of(words):
            body = [w for w in row if w['top'] > 60]
            if not body:
                continue
            pre = [w for w in body if (w['x0'] + w['x1']) / 2 < left]
            rate_ws = [w for w in body if (w['x0'] + w['x1']) / 2 >= left]

            code = None
            if pre and CODE.match(pre[0]['text']) and pre[0]['x0'] <= item_x + 22:
                code = pre[0]['text'].rstrip('.')
                pre = pre[1:]
            # Some rows carry the code and description on one line and the unit
            # and rates on the next; keep the last coded line so those rates
            # land on the item they belong to instead of being thrown away.
            if code is None and not pre and rate_ws and pending:
                code, pre = pending
                pending = None

            cols = [[], [], [], []]
            for w in rate_ws:
                if w['text'].rstrip('.') in ('Tk', 'Tk.'):
                    continue
                c = (w['x0'] + w['x1']) / 2
                i = 0 if c < bounds[0] else 1 if c < bounds[1] else 2 if c < bounds[2] else 3
                cols[i].append(w['text'])
            rates = [num(''.join(c)) if c else None for c in cols]
            # A zero is never a published rate: it is an empty cell, or a stray
            # token that happened to parse. Treat it as absent so such rows fail
            # the "at least three zones" test below and never reach the app.
            rates = [None if (r is not None and r <= 0) else r for r in rates]

            if sum(r is not None for r in rates) < 3:
                if code and pre:
                    pending = (code, list(pre))
                    text = ' '.join(w['text'] for w in pre).strip()
                    if text:
                        d = code.count('.')
                        headings[d] = text
                        for k in [k for k in headings if k > d]:
                            del headings[k]
                continue
            if not code:
                continue

            unit = None
            if pre and pre[-1]['text'].lower().strip(',') in UNITS:
                unit = pre[-1]['text'].strip('.,')
                pre = pre[:-1]
            text = ' '.join(w['text'] for w in pre).strip()

            # A dropped digit only ever makes a printed rate smaller, so the
            # row's largest value is the reference.
            hi = max(r for r in rates if r is not None)
            flags = []
            clean = []
            for i, r in enumerate(rates):
                if r is None:
                    clean.append(None)
                elif hi > 0 and r / hi < SUSPECT_RATIO:
                    clean.append(None)
                    flags.append(i)
                else:
                    clean.append(r)
            if flags:
                misprinted += 1
            if not any(c is not None for c in clean):
                dropped.append({'code': code, 'page': pno, 'rates': rates})
                continue

            d = code.count('.')
            ctx = [headings[k] for k in sorted(headings) if k < d and headings.get(k)]
            out.append({
                'code': code,
                'subhead': subhead,
                'desc': text,
                'context': ' > '.join(ctx)[:400],
                'unit': unit,
                'rates': clean,
                'unclear_zones': flags,
                'page': pno,
            })

    json.dump(out, open('em_items.json', 'w'), ensure_ascii=False, indent=1)
    json.dump(dropped, open('em_dropped.json', 'w'), ensure_ascii=False, indent=1)
    shs = sorted({r['subhead'] for r in out if r['subhead']},
                 key=lambda s: [int(x) for x in s.split('.')])
    print('items kept                 ', len(out))
    print('rows with a misprinted zone', misprinted)
    print('rows dropped entirely      ', len(dropped))
    print('subheads                   ', shs)


main()
