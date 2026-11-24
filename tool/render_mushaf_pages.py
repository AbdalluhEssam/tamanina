#!/usr/bin/env python3
"""Pack the official 1441H Hafs pages for offline reading."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
from zipfile import ZipFile

from PIL import Image, ImageChops


ARCHIVE_SHA256 = 'c2fa8d93a7c4f689b58eb32756e1ae56cd1b7ce4826f63e09723be8b092224fb'
PAGE_COUNT = 604
MAX_PAGE_HEIGHT = 1440
INK = (35, 31, 32)
FRAME = (191, 232, 194)


def pack_page(image: Image.Image, output: Path) -> None:
    image = image.convert('RGBA')
    if image.height > MAX_PAGE_HEIGHT:
        width = round(image.width * MAX_PAGE_HEIGHT / image.height)
        image = image.resize((width, MAX_PAGE_HEIGHT), Image.Resampling.BOX)

    # The printed pages use two inks. Four coverage levels retain antialiasing
    # without storing a separate color for each combination of ink and opacity.
    levels = 4
    coverage = image.getchannel('A').point([
        round(alpha * (levels - 1) / 255) for alpha in range(256)
    ])
    frame_mask = image.getchannel('G').point([0] * 128 + [255] * 128)
    frame_indices = ImageChops.add(coverage, Image.new('L', image.size, levels))
    indexed = Image.composite(frame_indices, coverage, frame_mask)
    indexed.paste(0, mask=coverage.point([255] + [0] * 255))
    indexed = indexed.convert('P')
    indexed.putpalette([channel for color in (INK, FRAME)
                       for _ in range(levels) for channel in color])
    alphas = bytes(round(255 * step / (levels - 1)) for step in range(levels)) * 2

    with TemporaryDirectory() as directory:
        palette = Path(directory) / 'indexed.png'
        indexed.save(palette, transparency=alphas)
        subprocess.run(
            ['cwebp', '-quiet', '-lossless', '-m', '6', palette, '-o', output],
            check=True,
        )


def render_page(source: bytes, output: Path) -> None:
    with TemporaryDirectory() as directory:
        base = Path(directory) / 'page'
        vector = base.with_suffix('.ai')
        raster = base.with_suffix('.png')
        palette = base.with_suffix('.palette.png')
        vector.write_bytes(source)
        subprocess.run(
            ['pdftocairo', '-png', '-transp', '-scale-to', '1860',
             '-singlefile', vector, base],
            check=True,
        )
        with Image.open(raster) as image:
            bounds = image.getchannel('A').getbbox()
            if bounds is None:
                raise ValueError(f'Blank artwork for {output.name}')
            image.crop(bounds).save(raster)
        subprocess.run(
            ['pngquant', '--nofs', '64', raster, '--output', palette], check=True,
        )
        with Image.open(palette) as image:
            pack_page(image, output)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path,
                        help='official vector ZIP or a directory of previously rendered pages')
    parser.add_argument('--output', type=Path, default=Path('assets/mushaf'))
    args = parser.parse_args()

    args.output.mkdir(parents=True, exist_ok=True)
    if args.source.is_dir():
        if args.source.resolve() == args.output.resolve():
            parser.error('render into a separate directory from the source')

        def pack_existing(page: int) -> None:
            name = f'{page:03d}.webp'
            with Image.open(args.source / name) as image:
                pack_page(image, args.output / name)

        pack_pages(pack_existing)
    else:
        with args.source.open('rb') as source:
            if hashlib.file_digest(source, 'sha256').hexdigest() != ARCHIVE_SHA256:
                raise ValueError('Archive does not match the publisher’s SHA-256')
        with ZipFile(args.source) as archive:
            def pack_from_vector(page: int) -> None:
                member = f'1441-mushaf-hafs-ai/{page:03d}___Hafs39__DM.ai'
                render_page(archive.read(member), args.output / f'{page:03d}.webp')

            pack_pages(pack_from_vector)


def pack_pages(pack) -> None:
    with ThreadPoolExecutor(max_workers=6) as pool:
        for page, _ in enumerate(pool.map(pack, range(1, PAGE_COUNT + 1)), 1):
            if page % 100 == 0 or page == PAGE_COUNT:
                print(f'Packed {page}/{PAGE_COUNT}', flush=True)


if __name__ == '__main__':
    main()
