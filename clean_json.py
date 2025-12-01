import json
import sys

filepath = sys.argv[1]
try:
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print(f"Cleaned {filepath}")
except Exception as e:
    print(f"Error: {e}")
