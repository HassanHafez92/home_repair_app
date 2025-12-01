import json

def get_keys(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return {}

en_data = get_keys('assets/translations/en.json')
ar_data = get_keys('assets/translations/ar.json')

print(f"EN keys: {len(en_data)}")
print(f"AR keys: {len(ar_data)}")

missing_keys = {}
for key, value in en_data.items():
    if key not in ar_data:
        missing_keys[key] = value # Use English value as placeholder

print(json.dumps(missing_keys, indent=4, ensure_ascii=False))
