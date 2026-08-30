import re

with open('scenes/objects/tree.tscn', 'r') as f:
    content = f.read()

# Change the texture path
content = content.replace('spr_deco_tree_01_strip4.png', 'spr_deco_tree_02_strip4.png')

# Change the AtlasTexture region (2nd frame: x=28, y=0, w=28, h=43)
# The old one was Rect2(32, 0, 32, 34)
content = re.sub(r'region = Rect2\(.*?\)', 'region = Rect2(28, 0, 28, 43)', content)

# Change node name from Tree to SpruceTree
content = content.replace('[node name="Tree"', '[node name="SpruceTree"')

# Adjust Sprite offset
# Old was offset = Vector2(0, -17). The new sprite is 43px high. 
# Usually bottom center is desired. So offset y = -21 (half of 43)
content = content.replace('offset = Vector2(0, -17)', 'offset = Vector2(0, -21)')
content = content.replace('position = Vector2(0, -17)', 'position = Vector2(0, -21)') # for CollisionShape2D
content = content.replace('position = Vector2(0, -22)', 'position = Vector2(0, -26)') # for OccluderArea

with open('scenes/objects/spruce_tree.tscn', 'w') as f:
    f.write(content)
