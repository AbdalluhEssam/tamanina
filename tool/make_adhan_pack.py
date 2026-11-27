#!/usr/bin/env python3
"""Prepare an adhan recording for the Tamanina audio catalog.

    python3 tool/make_adhan_pack.py madinah recording.mp3 --out build/adhan \
        --url https://example.com/adhan/madinah.mp3 \
        --name-ar "المدينة المنورة" --name-en "Madinah" [--fajr fajr.mp3]

It writes `<id>.mp3` (re-encoded mono) and `<id>.caf` (iOS notification clip,
at most 28 seconds) to --out, then prints the catalog entry to paste into the
Firebase Remote Config parameter `audio_catalog` under `"adhan": [...]`.

With --packs path/to/packs.json the entry is merged into that file for you.
Upload the files to any HTTPS host, then set the URLs. Integrity comes from the
SHA-256 values printed here, so the host does not need to be trusted.

`phrases` is a DRAFT: voiced segments found by ffmpeg `silencedetect`. Listen
through the recording and fix the numbers before publishing. A voice without
`phrases` still works; the screen then shows the adhan text without
highlighting. Requires ffmpeg, ffprobe and (for the iOS clip) macOS afconvert.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

CLIP_SECONDS = 28


def run(*command: str) -> str:
    result = subprocess.run(command, capture_output=True, text=True, check=True)
    return result.stdout + result.stderr


def duration_ms(path: Path) -> int:
    out = run('ffprobe', '-v', 'error', '-show_entries', 'format=duration',
              '-of', 'default=nw=1:nk=1', str(path))
    return round(float(out.strip().splitlines()[0]) * 1000)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def draft_phrases(path: Path, noise: str, min_gap: float) -> list[list[float]]:
    log = run('ffmpeg', '-hide_banner', '-i', str(path), '-af',
              f'silencedetect=noise={noise}:d={min_gap}', '-f', 'null', '-')
    starts = [float(x) for x in re.findall(r'silence_start: ([\d.]+)', log)]
    ends = [float(x) for x in re.findall(r'silence_end: ([\d.]+)', log)]
    total = duration_ms(path) / 1000
    voiced, cursor = [], 0.0
    for index, start in enumerate(starts):
        if start - cursor > 0.3:
            voiced.append([round(cursor, 1), round(start, 1)])
        cursor = ends[index] if index < len(ends) else total
    if total - cursor > 0.3:
        voiced.append([round(cursor, 1), round(total, 1)])
    return voiced


def build(source: Path, out: Path, name: str, args, is_fajr: bool = False) -> dict:
    mp3 = out / f'{name}.mp3'
    run('ffmpeg', '-y', '-i', str(source), '-vn', '-ac', '1', '-af', 'loudnorm=I=-16:LRA=11:TP=-1.5', '-ar', '44100', '-b:a', '64k', str(mp3))
    clip = out / f'{name}.caf'
    wav = out / f'{name}.clip.wav'
    run('ffmpeg', '-y', '-i', str(source), '-t', str(CLIP_SECONDS), '-ac', '1',
        '-ar', '22050', '-af', f'afade=t=out:st={CLIP_SECONDS - 2}:d=2', str(wav))
    run('afconvert', '-f', 'caff', '-d', 'ima4', str(wav), str(clip))
    wav.unlink()
    entry = {
        'url': f'{args.url_prefix}{mp3.name}' if args.url_prefix else 'https://REPLACE/' + mp3.name,
        'sha256': sha256(mp3),
        'bytes': mp3.stat().st_size,
        'durationMs': duration_ms(mp3),
        'iosUrl': f'{args.url_prefix}{clip.name}' if args.url_prefix else 'https://REPLACE/' + clip.name,
        'iosSha256': sha256(clip),
        'iosBytes': clip.stat().st_size,
    }
    if not args.no_phrases:
        entry['phrases'] = draft_phrases(mp3, args.noise, args.min_gap)
        expected = 14 if is_fajr else 12
        if len(entry['phrases']) != expected:
            print(f'# WARNING {mp3.name}: found {len(entry["phrases"])} phrases but the app expects '
                  f'{expected}. Fix `phrases` by hand or pass --no-phrases (the app then shows the '
                  'text without highlighting).', file=sys.stderr)
    return entry


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('id', help='lowercase id, e.g. madinah')
    parser.add_argument('source', type=Path)
    parser.add_argument('--fajr', type=Path, help='separate Fajr recording')
    parser.add_argument('--out', type=Path, default=Path('build/adhan'))
    parser.add_argument('--url-prefix', default='', help='e.g. https://cdn.example.com/adhan/')
    parser.add_argument('--name-ar', default='')
    parser.add_argument('--name-en', default='')
    parser.add_argument('--noise', default='-25dB')
    parser.add_argument('--min-gap', default='0.35')
    parser.add_argument('--no-phrases', action='store_true')
    parser.add_argument('--credit', default='', help='attribution shown in the app')
    parser.add_argument('--packs', type=Path,
                        help='packs.json to update: adds or replaces this voice')
    args = parser.parse_args()
    if not re.fullmatch(r'[a-z0-9_-]{1,32}', args.id):
        sys.exit('id must be 1-32 characters of a-z, 0-9, _ or -')
    args.out.mkdir(parents=True, exist_ok=True)
    voice = {'id': args.id, 'nameAr': args.name_ar or args.id,
             'nameEn': args.name_en or args.id,
             'main': build(args.source, args.out, args.id, args)}
    if args.fajr:
        voice['fajr'] = build(args.fajr, args.out, f'{args.id}-fajr', args, is_fajr=True)
    if args.credit:
        voice['credit'] = args.credit
    if args.packs:
        packs = json.loads(args.packs.read_text()) if args.packs.exists() else {}
        voices = [v for v in packs.get('adhan', []) if v['id'] != args.id]
        packs['adhan'] = [*voices, voice]
        args.packs.write_text(json.dumps(packs, ensure_ascii=False, indent=2) + '\n')
        print(f'# updated {args.packs}. Now copy {args.out}/{args.id}*.mp3 and *.caf into the '
              'packs repo adhan/ folder, commit, tag (v4, ...) and push. Installed apps list the '
              'new voice within minutes, no app update needed.', file=sys.stderr)
    print(json.dumps(voice, ensure_ascii=False, indent=2))
    total = sum(v['bytes'] + v['iosBytes'] for v in (voice['main'], voice.get('fajr', {'bytes': 0, 'iosBytes': 0})))
    print(f'\n# download size per user: {total / 1048576:.1f} MB (Android needs only the .mp3)', file=sys.stderr)
    print('# phrases are a DRAFT - listen through and correct before publishing', file=sys.stderr)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
