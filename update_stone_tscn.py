import re

with open('scenes/objects/stone.tscn', 'r') as f:
    content = f.read()

# Replace script path
content = content.replace('path="res://scripts/components/destructible.gd"', 'path="res://scripts/components/stone.gd"')

# Remove old exported properties from destructible.gd
content = re.sub(r'max_hp = 6\n.*?\nregions = Array\[Rect2\].*?\n', '', content, flags=re.DOTALL)

with open('scenes/objects/stone.tscn', 'w') as f:
    f.write(content)
