import json
import os
import re

def get_keys_from_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            # Matches 'key'.tr() and "key".tr()
            # Also matches 'key'.tr(args: ...)
            return set(re.findall(r'[\'\"](\w+)[\'\"]\.tr\(', content))
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return set()

def get_all_keys(root_dir):
    keys = set()
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                keys.update(get_keys_from_file(os.path.join(root, file)))
    return keys

def check_missing_keys(json_path, used_keys):
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            existing_keys = set(data.keys())
            missing = used_keys - existing_keys
            return missing
    except Exception as e:
        print(f"Error reading {json_path}: {e}")
        return set()

root_dir = 'lib'
used_keys = get_all_keys(root_dir)
print(f"Found {len(used_keys)} keys in code.")

missing_en = check_missing_keys('assets/translations/en.json', used_keys)
missing_ar = check_missing_keys('assets/translations/ar.json', used_keys)

print("Missing in en.json:", sorted(list(missing_en)))
print("Missing in ar.json:", sorted(list(missing_ar)))
