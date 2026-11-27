import json, sys
import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter1d
from scipy.signal import find_peaks

raw = json.load(open('pages_raw.json'))

def expected_lines(page):
    if page == 1 or page == 2:
        return 8
    return 15

def analyze(page):
    im = Image.open(f'imgs/{page:03d}.webp').convert('RGBA')
    a = np.array(im)
    h, w = a.shape[:2]
    alpha = a[..., 3] > 128
    r, g, b = a[..., 0].astype(int), a[..., 1].astype(int), a[..., 2].astype(int)
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    green = alpha & ((g - r) > 20) & (lum > 150)
    ink = alpha & (lum < 110)
    # inner paper area: columns/rows that are mostly not frame green
    midrows = slice(h // 4, 3 * h // 4)
    colgreen = green[midrows].mean(axis=0)
    inner_cols = np.nonzero(colgreen < 0.35)[0]
    midcols = slice(w // 4, 3 * w // 4)
    rowgreen = green[:, midcols].mean(axis=1)
    inner_rows = np.nonzero(rowgreen < 0.35)[0]
    x0, x1 = int(inner_cols[0]), int(inner_cols[-1])
    y0, y1 = int(inner_rows[0]), int(inner_rows[-1])
    sub = ink[y0:y1 + 1, x0:x1 + 1]
    n = expected_lines(page)
    prof = sub.sum(axis=1).astype(float)
    pitch = (y1 - y0 + 1) / n
    smooth = gaussian_filter1d(prof, sigma=max(2.0, pitch / 9))
    peaks, props = find_peaks(smooth, distance=pitch * 0.6, prominence=smooth.max() * 0.04)
    method = 'peaks'
    if len(peaks) > n:
        order = np.argsort(props['prominences'])[::-1][:n]
        peaks = np.sort(peaks[order])
    if len(peaks) != n:
        method = 'uniform'
        peaks = np.array([(i + 0.5) * pitch for i in range(n)])
    # regularity of detected peaks
    gaps = np.diff(peaks)
    irregular = float(gaps.std() / gaps.mean()) if len(gaps) > 1 and gaps.mean() > 0 else 0.0
    bounds = []
    for i, c in enumerate(peaks):
        top = (peaks[i - 1] + c) / 2 if i > 0 else max(0, c - (peaks[1] - c) / 2) if n > 1 else 0
        bot = (c + peaks[i + 1]) / 2 if i < n - 1 else min(sub.shape[0], c + (c - peaks[i - 1]) / 2)
        band = sub[int(top):int(bot) + 1]
        cols = np.nonzero(band.sum(axis=0) > 0)[0]
        xmin, xmax = (int(cols[0]), int(cols[-1])) if len(cols) else (0, sub.shape[1] - 1)
        bounds.append([round(y0 + top, 1), round(y0 + bot, 1), x0 + xmin, x0 + xmax])
    return {'w': w, 'h': h, 'inner': [x0, y0, x1, y1], 'lines': bounds, 'method': method, 'irregular': round(irregular, 3)}

if __name__ == '__main__':
    pages = range(1, 605) if len(sys.argv) < 2 else [int(x) for x in sys.argv[1:]]
    out = {}
    bad = []
    for p in pages:
        g = analyze(p)
        out[p] = g
        if g['method'] != 'peaks' or g['irregular'] > 0.12:
            bad.append((p, g['method'], g['irregular']))
    print('pages', len(out), 'problem pages', len(bad))
    print(bad[:40])
    if len(sys.argv) < 2:
        json.dump(out, open('geometry.json', 'w'))
