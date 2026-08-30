import re

with open('scenes/objects/tree.tscn', 'r') as f:
    content = f.read()

# Change texture path and node name
content = content.replace('spr_deco_tree_01_strip4.png', 'spr_tileset_sunnysideworld_16px.png')
content = content.replace('[node name="Tree"', '[node name="SmallBush"')

# Change AtlasTexture region
content = re.sub(r'region = Rect2\(.*?\)', 'region = Rect2(816, 64, 16, 16)', content)

# Change resource drop to stick and amount to 1
# destructible.gd has no explicit resource_id override in the tree.tscn yet?
# Let's check if tree.tscn has drop_amount
content = content.replace('drop_amount = 2', 'drop_amount = 1\nresource_id = "stick"')

# Adjust hitboxes for 16x16 bush
content = re.sub(r'size = Vector2\(40, 60\)', 'size = Vector2(16, 16)', content) # Main hurtbox
content = re.sub(r'size = Vector2\(16, 10.5\)', 'size = Vector2(12, 6)', content) # Static body physics
content = re.sub(r'size = Vector2\(28, 24\)', 'size = Vector2(16, 12)', content) # Occluder

# Offsets for bottom-center anchoring
# Center of 16 is 8, so offset -8
content = content.replace('offset = Vector2(0, -17)', 'offset = Vector2(0, -8)')
content = content.replace('position = Vector2(0, -17)', 'position = Vector2(0, -8)') # Hurtbox pos
content = content.replace('position = Vector2(0, -5)', 'position = Vector2(0, -3)') # Static pos
content = content.replace('position = Vector2(0, -22)', 'position = Vector2(0, -8)') # Occluder pos

with open('scenes/objects/small_bush.tscn', 'w') as f:
    f.write(content)

