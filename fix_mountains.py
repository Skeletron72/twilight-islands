import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

# Remove z_index = 1 from MountainsTopsLayer
pattern = r'(\[node name="MountainsTopsLayer" type="TileMapLayer"[^\]]*\]\n)z_index = 1\n'
content = re.sub(pattern, r'\1', content)

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
