
lines = []
with open('assets/translations/en.json', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Keep lines up to "feature6" (which is line 307 in 1-based, index 306)
# Verify line 306 contains "feature6"
if "feature6" not in lines[306]:
    print(f"Error: Line 307 does not contain 'feature6'. It is: {lines[306]}")
    exit(1)

new_lines = lines[:307]
# Add comma to the last line if missing
new_lines[-1] = new_lines[-1].rstrip() + ",\n"

extra_keys = [
    '    "pleaseEnterStreetCity": "Please enter street and city",\n',
    '    "street": "Street",\n',
    '    "enterStreet": "Enter street name",\n',
    '    "city": "City",\n',
    '    "enterCity": "Enter city name",\n',
    '    "work": "Work",\n',
    '    "other": "Other"\n',
    '}'
]

new_lines.extend(extra_keys)

with open('assets/translations/en.json', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Successfully fixed en.json")
