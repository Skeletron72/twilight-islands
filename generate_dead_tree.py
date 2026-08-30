import re

with open('scenes/objects/tree.tscn', 'r') as f:
    content = f.read()

# Change texture path and node name
content = content.replace('spr_deco_tree_01_strip4.png', 'spr_tileset_sunnysideworld_16px.png')
content = content.replace('[node name="Tree"', '[node name="DeadTree"')

# Change AtlasTexture region
content = re.sub(r'region = Rect2\(.*?\)', 'region = Rect2(848, 48, 32, 48)', content)

# Adjust hitboxes for 32x48 tree
content = re.sub(r'size = Vector2\(40, 60\)', 'size = Vector2(24, 48)', content) # Main hurtbox
content = re.sub(r'size = Vector2\(16, 10.5\)', 'size = Vector2(12, 8)', content) # Static body physics
content = re.sub(r'size = Vector2\(28, 24\)', 'size = Vector2(24, 24)', content) # Occluder

# Offsets for bottom-center anchoring
# Center of 48 is 24, so offset -24
content = content.replace('offset = Vector2(0, -17)', 'offset = Vector2(0, -24)')
content = content.replace('position = Vector2(0, -17)', 'position = Vector2(0, -24)') # Hurtbox pos
content = content.replace('position = Vector2(0, -5)', 'position = Vector2(0, -4)') # Static pos
content = content.replace('position = Vector2(0, -22)', 'position = Vector2(0, -24)') # Occluder pos

with open('scenes/objects/dead_tree.tscn', 'w') as f:
    f.write(content)

