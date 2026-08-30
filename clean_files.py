import re

for filename in ['scripts/components/player.gd', 'scripts/components/skeleton.gd']:
    with open(filename, 'r') as f:
        content = f.read()

    # Clean up the mess
    content = content.replace('\t\t{}.anti_aliasing = false; hp_dummy = 0\n', '')
    content = content.replace('\t{}.anti_aliasing = false; hp_dummy = 0\n', '')
    content = content.replace('; hp_dummy = 0', '')
    
    with open(filename, 'w') as f:
        f.write(content)
