import glob
import os

# Target ALL lib files
files = glob.glob('lib/**/*.dart', recursive=True)

print(f"Processing {len(files)} files...")

for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        
        new_lines = []
        header_done = False
        changed = False
        
        for i, line in enumerate(lines):
            if not header_done:
                stripped = line.strip()
                if stripped.startswith('///'):
                    new_lines.append(line.replace('///', '//', 1))
                    changed = True
                elif stripped.startswith('//'):
                    new_lines.append(line)
                elif stripped == '':
                    new_lines.append(line)
                    # Don't mark header done on empty lines within header
                    if i < len(lines) - 1 and lines[i+1].strip().startswith('import'):
                        header_done = True
                elif stripped.startswith('import') or stripped.startswith('library') or stripped.startswith('part') or stripped.startswith('class') or stripped.startswith('enum') or stripped.startswith('void main'):
                    header_done = True
                    new_lines.append(line)
                else:
                    header_done = True
                    new_lines.append(line)
            else:
                new_lines.append(line)
        
        if changed:
            with open(f, 'w', encoding='utf-8') as file:
                file.writelines(new_lines)
            print(f"Fixed {f}")
            
    except Exception as e:
        print(f"Error checking {f}: {e}")
