#!/usr/bin/env python3
"""Split the Mushaf page images into downloadable chunks.

    python3 tool/make_mushaf_pack.py assets/mushaf --out build/packs/mushaf \
        --url-prefix https://cdn.jsdelivr.net/gh/USER/REPO@v1/mushaf/

Pages up to --bundled stay inside the app. The other pages are written to
`mushaf-<from>-<to>.pack` files and listed, with their SHA-256 and size, in the
JSON printed to stdout. That JSON is the `mushaf` entry of the audio catalog
(assets/data/packs.json and the Remote Config parameter `audio_catalog`).

Pack format (all integers big-endian): "TMNP", uint32 count, then per page
uint16 page and uint32 length, then the page files in the same order.
"""

import argparse
import hashlib
import json
from pathlib import Path
import struct


def write_pack(pages: list[tuple[int, Path]], target: Path) -> None:
    with target.open('wb') as out:
        out.write(b'TMNP')
        out.write(struct.pack('>I', len(pages)))
        for number, path in pages:
            out.write(struct.pack('>HI', number, path.stat().st_size))
        for _, path in pages:
            out.write(path.read_bytes())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('source', type=Path, help='folder with 001.webp ... 604.webp')
    parser.add_argument('--out', type=Path, default=Path('build/packs/mushaf'))
    parser.add_argument('--url-prefix', required=True)
    parser.add_argument('--bundled', type=int, default=5, help='pages kept in the app')
    parser.add_argument('--chunk', type=int, default=100, help='pages per file')
    args = parser.parse_args()

    pages = sorted((int(p.stem), p) for p in args.source.glob('[0-9][0-9][0-9].webp'))
    pages = [(n, p) for n, p in pages if n > args.bundled]
    args.out.mkdir(parents=True, exist_ok=True)
    chunks = []
    for start in range(0, len(pages), args.chunk):
        group = pages[start:start + args.chunk]
        first, last = group[0][0], group[-1][0]
        target = args.out / f'mushaf-{first:03d}-{last:03d}.pack'
        write_pack(group, target)
        chunks.append({
            'from': first,
            'to': last,
            'url': f'{args.url_prefix}{target.name}',
            'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
            'bytes': target.stat().st_size,
        })
    print(json.dumps({'bundledPages': args.bundled, 'chunks': chunks}, indent=2))


if __name__ == '__main__':
    main()
