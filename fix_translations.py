import json

# Load Arabic translation
with open('assets/translations/ar.json.backup') as f:
    content = f.read()
    # Remove markdown fences if present
    content = content.replace('```json\n', '').replace('\n```', '')
    ar_data = json.loads(content)

# Load English translation
with open('assets/translations/en.json') as f:
    content = f.read()
    # Remove markdown fences if present
    content = content.replace('```json\n', '').replace('\n```', '')
    en_data = json.loads(content)

# Write clean JSON back
with open('assets/translations/ar.json', 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=4)

with open('assets/translations/en.json', 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=4)

print('✅ Both files cleaned and rewritten as valid JSON')

# Now compare
missing_ar = sorted(set(en_data.keys()) - set(ar_data.keys()))
missing_en = sorted(set(ar_data.keys()) - set(en_data.keys()))

print(f'\n📊 English: {len(en_data)} keys')
print(f'📊 Arabic: {len(ar_data)} keys')
print(f'\n⚠️  Missing in Arabic: {len(missing_ar)}')
if missing_ar:
    for key in missing_ar[:10]:
        print(f'  → {key}')
    if len(missing_ar) > 10:
        print(f'  ... and {len(missing_ar) - 10} more')

print(f'\n⚠️  Missing in English: {len(missing_en)}')
if missing_en:
    for key in missing_en[:10]:
        print(f'  → {key}')
    if len(missing_en) > 10:
        print(f'  ... and {len(missing_en) - 10} more')
