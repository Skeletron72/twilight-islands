import re

for filename in ['scripts/components/player.gd', 'scripts/components/skeleton.gd']:
    with open(filename, 'r') as f:
        content = f.read()

    # Add anti_aliasing = false to all new StyleBoxFlats
    content = content.replace('StyleBoxFlat.new()', 'StyleBoxFlat.new(); hp_dummy = 0') # dirty hack to find them
    
    # Actually, a simple regex is better:
    content = re.sub(r'(var \w+ = StyleBoxFlat.new\(\))', r'\1\n\t\t\1.anti_aliasing = false'.replace(r'\1.anti_aliasing', r'{}.anti_aliasing'), content)

    # Let's do it cleanly:
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'StyleBoxFlat.new()' in line:
            var_name = line.split('var')[1].split('=')[0].strip()
            lines[i] = line + f'\n\t{var_name}.anti_aliasing = false'
            
    with open(filename, 'w') as f:
        f.write('\n'.join(lines))
