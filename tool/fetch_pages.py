import json, time, urllib.request, sys, os
out = {}
if os.path.exists('pages_raw.json'):
    out = json.load(open('pages_raw.json'))
for page in range(1, 605):
    if str(page) in out: continue
    url = f"https://api.quran.com/api/v4/verses/by_page/{page}?words=true&word_fields=line_number,page_number,position,char_type_name,text_uthmani&fields=verse_key&per_page=60&mushaf=2"
    for attempt in range(5):
        try:
            d = json.load(urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "mushaf-research/1.0"}), timeout=40))
            break
        except Exception as e:
            time.sleep(3 * (attempt + 1))
    else:
        print('FAILED', page); continue
    assert d['pagination']['total_pages'] == 1, page
    out[str(page)] = [
        {"key": v['verse_key'], "words": [[w['position'], w.get('line_number'), w.get('page_number'), w['char_type_name'], w.get('text_uthmani', '')] for w in v['words']]}
        for v in d['verses']
    ]
    if page % 50 == 0:
        json.dump(out, open('pages_raw.json', 'w')); print(page, flush=True)
    time.sleep(0.25)
json.dump(out, open('pages_raw.json', 'w'))
print('done', len(out))
