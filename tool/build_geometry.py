"""Build assets/data/mushaf_geometry.json (where each verse is on the page images).

Steps (run from a folder that has the page images in imgs/001.webp ... 604.webp,
for example unpacked from the Mushaf pack):

    python3 fetch_pages.py        # Quran.com line numbers -> pages_raw.json
    python3 geometry.py           # text line bands per page image -> geometry.json
    python3 build_geometry.py     # verse positions -> mushaf_geometry.json

Needs numpy, scipy and pillow. 15-line pages share one grid, taken as the median
of the cleanly detected pages; pages 1 and 2 (8 lines) are rebuilt from their own
spacing.
"""
import json, sys, unicodedata
import numpy as np
from PIL import Image
raw = json.load(open('pages_raw.json'))
geo = json.load(open('geometry.json'))
def _template():
    import os, statistics
    if os.path.exists('tmpl.json'):
        return json.load(open('tmpl.json'))['tmpl']
    regular = [int(p) for p, v in geo.items()
               if v['method'] == 'peaks' and v['irregular'] <= 0.12 and int(p) > 2]
    t = [[statistics.median(geo[str(p)]['lines'][i][k] for p in regular) for k in (0, 1)]
         for i in range(15)]
    json.dump({'tmpl': t}, open('tmpl.json', 'w'))
    return t

tmpl = _template()

# verse key -> global verse number (1..6236)
AYAHS = [7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,73,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6]
assert len(AYAHS) == 114 and sum(AYAHS) == 6236
START = [0]
for n in AYAHS: START.append(START[-1] + n)
def number(key):
    s, a = map(int, key.split(':'))
    return START[s - 1] + a

def weight(word):
    pos, line, pg, kind, text = word
    if kind == 'end':
        return 2.4
    letters = [c for c in text if unicodedata.category(c).startswith('L')]
    return max(1.0, len(letters)) + 0.8

def line_bounds(page):
    g = geo[str(page)]
    x0, _, x1, _ = g['inner']
    if page <= 2:
        # Pages 1 and 2 have 8 lines; the first verse line sits below an uneven
        # gap, so rebuild the bands from the regular spacing of the later lines.
        centers = [(t + b) / 2 for t, b, _, _ in g['lines']]
        pitch = float(np.median(np.diff(centers[2:])))
        centers[1] = centers[2] - pitch
        im = Image.open(f'imgs/{page:03d}.webp').convert('RGBA')
        a = np.array(im)
        alpha = a[..., 3] > 128
        lum = 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]
        ink = alpha & (lum < 110)
        out = [g['lines'][0]]
        for c in centers[1:]:
            top, bot = int(c - pitch / 2), int(c + pitch / 2)
            band = ink[top:bot + 1, x0:x1 + 1]
            cols = np.nonzero(band.sum(axis=0) > 0)[0]
            xmin, xmax = (x0 + int(cols[0]), x0 + int(cols[-1])) if len(cols) else (x0, x1)
            out.append([top, bot, xmin, xmax])
        return out
    im = Image.open(f'imgs/{page:03d}.webp').convert('RGBA')
    a = np.array(im)
    alpha = a[..., 3] > 128
    lum = 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]
    ink = alpha & (lum < 110)
    out = []
    for top, bot in tmpl:
        band = ink[int(top):int(bot) + 1, x0:x1 + 1]
        cols = np.nonzero(band.sum(axis=0) > 0)[0]
        xmin, xmax = (x0 + int(cols[0]), x0 + int(cols[-1])) if len(cols) else (x0, x1)
        out.append([int(top), int(bot), xmin, xmax])
    return out

from scipy.ndimage import find_objects, label


def surah_ayah(n):
    for s_i in range(114):
        if n <= START[s_i + 1]:
            return s_i + 1, n - START[s_i]
    raise ValueError(n)


def find_shapes(page, lines):
    """Verse-end markers and surah banners, found from the page image.

    Markers are frame-coloured blobs about one line tall; banners are wide
    frame-coloured shapes. Returns ({line: [(left, right), ...]}, {banner lines}).
    """
    g = geo[str(page)]
    x0, y0, x1, y1 = g['inner']
    a = np.array(Image.open(f'imgs/{page:03d}.webp').convert('RGBA'))
    alpha = a[..., 3] > 128
    r, gr = a[..., 0].astype(int), a[..., 1].astype(int)
    lum = 0.299 * r + 0.587 * gr + 0.114 * a[..., 2]
    green = alpha & ((gr - r) > 20) & (lum > 150)
    mask = np.zeros_like(green)
    mask[y0:y1 + 1, x0:x1 + 1] = green[y0:y1 + 1, x0:x1 + 1]
    if page <= 2:
        # Pages 1 and 2 put the text in a white circle on a green ground, so
        # only look inside the circle (found as the largest paper-coloured area).
        from scipy.ndimage import binary_dilation, binary_fill_holes
        clear_labels, _ = label(~alpha)
        cy, cx = (y0 + y1) // 2, (x0 + x1) // 2
        window = clear_labels[cy - 60:cy + 61, cx - 60:cx + 61]
        ids = window[window > 0]
        circle = binary_fill_holes(
            clear_labels == int(np.bincount(ids).argmax())
        )
        mask = mask & binary_dilation(circle, iterations=3)
    labels, _ = label(mask)
    pitch = float(np.median([b - t for t, b, _, _ in lines]))
    centers = [(t + b) / 2 for t, b, _, _ in lines]
    # Side decorations (such as the hizb sign) sit outside the text column.
    col_min = float(np.percentile([ln[2] for ln in lines], 25))
    col_max = float(np.percentile([ln[3] for ln in lines], 75))
    markers, banners = {}, set()
    for index, box in enumerate(find_objects(labels)):
        h = box[0].stop - box[0].start
        w = box[1].stop - box[1].start
        cy = (box[0].start + box[0].stop) / 2
        line = int(np.argmin([abs(cy - c) for c in centers]))
        if w >= 0.5 * (x1 - x0) and h <= 1.4 * pitch and page > 2:
            banners.add(line)
            continue
        # Markers on pages 1 and 2 can be cut by the edge of the circle.
        min_w = (0.1 if page <= 2 else 0.35) * pitch
        if not (min_w <= w <= 1.05 * pitch and 0.35 * pitch <= h <= 1.05 * pitch):
            continue
        if page > 2 and int((labels[box] == index + 1).sum()) / float(w * h) < 0.5:
            continue
        if abs(cy - centers[line]) > pitch * 0.6:
            continue
        cx = (box[1].start + box[1].stop) / 2
        if not (col_min - 0.2 * pitch <= cx <= col_max + 0.2 * pitch):
            continue
        markers.setdefault(line, []).append((box[1].start, box[1].stop))
    if page <= 2:
        banners.add(0)
    if page == 1 and len(markers.get(3, [])) == 1:
        # The marker of verse 4 ends the line right at the edge of the circle,
        # where it merges with the green ground, so place it by hand.
        left = int(lines[3][2])
        markers[3].append((left - 36, left - 2))
    return markers, banners


def build_page(p, lines):
    """Rectangles for every verse on the page, from the markers in the image.

    The k-th marker (top to bottom, right to left) ends the k-th verse that ends
    on this page. This does not depend on the line numbers of the text source,
    which differ from this edition's line breaks on many pages.
    """
    words = sorted(words_by_page.get(p, []), key=lambda kw: (number(kw[0]), kw[1][0]))
    ends = []
    for key, w in words:
        if w[3] == 'end' and number(key) not in ends:
            ends.append(number(key))
    verses = sorted({number(key) for key, _ in words})
    markers, banners = find_shapes(p, lines)
    ordered = []
    for line in sorted(markers):
        for m in sorted(markers[line], key=lambda m: -m[1]):
            ordered.append((line, m))
    if len(ordered) != len(ends) or not verses:
        return None
    n = len(lines)
    # Clip the ink extent to the text column so side decorations (the hizb
    # sign in the margin) do not stretch a line.
    col_min = int(np.percentile([ln[2] for ln in lines], 25)) - 6
    col_max = int(np.percentile([ln[3] for ln in lines], 75)) + 6
    xs_min = [min([max(lines[i][2], col_min)] + [m[0] for m in markers.get(i, [])]) for i in range(n)]
    xs_max = [max([min(lines[i][3], col_max)] + [m[1] for m in markers.get(i, [])]) for i in range(n)]
    for i in range(n):
        lines[i][2], lines[i][3] = xs_min[i], xs_max[i]

    def first_text_line(start, verse):
        i, skipped = start, False
        while i < n and i in banners:
            i += 1
            skipped = True
        surah, ayah = surah_ayah(verse)
        if skipped and ayah == 1 and surah not in (1, 9):
            i += 1  # the bismillah line
        return min(i, n - 1)

    segments = {}
    pointer_line, pointer_x = first_text_line(0, verses[0]), None

    def add(verse, line, right_x, left_x):
        span = float(xs_max[line] - xs_min[line]) or 1.0
        f0 = int(round(1000 * (xs_max[line] - right_x) / span))
        f1 = int(round(1000 * (xs_max[line] - left_x) / span))
        if f1 > f0:
            segments.setdefault(str(verse), []).append([line + 1, f0, f1])

    def span_verse(verse, end):
        nonlocal pointer_line, pointer_x
        if end is None:
            end_line, end_x = n - 1, None
            while end_line > pointer_line and end_line in banners:
                end_line -= 1
        else:
            end_line, end_x = end
        for line in range(pointer_line, end_line + 1):
            if line in banners:
                continue
            right = pointer_x if (line == pointer_line and pointer_x is not None) else xs_max[line]
            left = end_x[0] if (line == end_line and end_x is not None) else xs_min[line]
            add(verse, line, right, left)
        if end is None:
            return
        # The next verse starts at the marker, or on the next line when the
        # marker closes the line.
        if end_x[0] <= xs_min[end_line] + 3:
            pointer_line, pointer_x = end_line + 1, None
        else:
            pointer_line, pointer_x = end_line, end_x[0]

    marker_i = 0
    for verse in verses:
        if verse in ends:
            end = ordered[marker_i]
            marker_i += 1
            if pointer_x is None:
                pointer_line = first_text_line(pointer_line, verse)
            span_verse(verse, (end[0], end[1]))
        else:
            if pointer_x is None:
                pointer_line = first_text_line(pointer_line, verse)
            span_verse(verse, None)
    return segments


def estimate_page(p, lines):
    """Fallback for pages whose marker count disagrees with the text source."""
    per_line = {}
    for key, w in words_by_page.get(p, []):
        per_line.setdefault(w[1], []).append((number(key), w))
    segs = {}
    for line, words in per_line.items():
        xmin, xmax = lines[line - 1][2], lines[line - 1][3]
        span = float(xmax - xmin) or 1.0
        total = sum(weight(w) for _, w in words)
        acc, runs = 0.0, []
        for num, w in words:
            wt = weight(w)
            if runs and runs[-1][0] == num:
                runs[-1][2] = acc + wt
            else:
                runs.append([num, acc, acc + wt])
            acc += wt
        for num, a0, a1 in runs:
            segs.setdefault(str(num), []).append([line, round(1000 * a0 / total), round(1000 * a1 / total)])
    return segs


# The API lists a verse under one page, but its words carry their own page
# numbers (a few verses straddle a page break), so regroup by the words' pages.
words_by_page = {}
for listed_page, vs in raw.items():
    for v in vs:
        for w in v['words']:
            if w[1] is None or w[2] is None:
                continue
            words_by_page.setdefault(int(w[2]), []).append((v['key'], w))

result = {}
exact, estimated = 0, []
for p in range(1, 605):
    lines = line_bounds(p)
    segs = build_page(p, lines)
    if segs is None:
        estimated.append(p)
        segs = estimate_page(p, lines)
    else:
        exact += 1
    g = geo[str(p)]
    result[str(p)] = {'w': g['w'], 'h': g['h'], 'l': lines, 'v': segs}
json.dump(result, open('mushaf_geometry.json', 'w'), separators=(',', ':'))
import os
print('size', os.path.getsize('mushaf_geometry.json'), 'pages placed by markers', exact, 'estimated pages', len(estimated), estimated[:40])
