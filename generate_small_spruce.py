import re

with open('scenes/objects/tree.tscn', 'r') as f:
    content = f.read()

# Change the texture path and node name
content = content.replace('spr_deco_tree_01_strip4.png', 'spr_tileset_sunnysideworld_16px.png')
content = content.replace('[node name="Tree"', '[node name="SmallSpruce"')

# Change the AtlasTexture region
content = re.sub(r'region = Rect2\(.*?\)', 'region = Rect2(832, 48, 16, 48)', content)

# Adjust hitboxes for 16x48 tall thin tree
# Old Tree size: size = Vector2(40, 60), Offset: -17
# Small spruce is 16px wide, 48px tall.
# Collision shape size:
content = re.sub(r'size = Vector2\(40, 60\)', 'size = Vector2(16, 48)', content) # Main hurtbox
content = re.sub(r'size = Vector2\(16, 10.5\)', 'size = Vector2(12, 8)', content) # Static body physics
content = re.sub(r'size = Vector2\(28, 24\)', 'size = Vector2(16, 32)', content) # Occluder

# Offsets for bottom-center anchoring
# Center of 48 is 24, so offset -24
content = content.replace('offset = Vector2(0, -17)', 'offset = Vector2(0, -24)')
# Main hurtbox shape position
content = content.replace('position = Vector2(0, -17)', 'position = Vector2(0, -24)') 
# StaticBody collision (should be at the very bottom, so ~ -4)
content = content.replace('position = Vector2(0, -5)', 'position = Vector2(0, -4)')
# Occluder position
content = content.replace('position = Vector2(0, -22)', 'position = Vector2(0, -28)')

# Optional: drop amount 1 because it's a small spruce?
content = content.replace('drop_amount = 2', 'drop_amount = 1')

with open('scenes/objects/small_spruce.tscn', 'w') as f:
    f.write(content)

