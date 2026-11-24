# Madinah Mushaf pages

Mushaf Al-Madinah, Hafs ‘an ‘Asim, digital edition for printing. Calligraphy by
Uthman Taha. © King Fahd Glorious Quran Printing Complex, Madinah.

The [publisher’s download and usage terms](https://qurancomplex.gov.sa/mushaf-printing)
permit free use of this digital edition in computer programs. The bundled WebP
files are raster renders of the publisher’s 604 Illustrator pages. The renderer
crops only the transparent outer margins. To reduce the offline download, the
assets are capped at 1440 pixels tall and use a compact ink and frame palette
with four opacity levels. The original line breaks, headings, verse markers
and page numbers are retained.

To regenerate the assets, download the 1441H Hafs archive from the publisher and
run `python3 tool/render_mushaf_pages.py 1441-mushaf-hafs-ai.zip` from the repo
root. The tool checks the publisher’s SHA-256 and uses Poppler’s `pdftocairo`,
Pillow, `pngquant`, and `cwebp`. To pack previous renders, pass their directory
as the source and use `--output` to write the compact pages to a separate
directory.
