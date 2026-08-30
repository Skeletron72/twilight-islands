import re

with open('scenes/objects/campfire.tscn', 'r') as f:
    content = f.read()

# Replace texture path
content = content.replace('res://resources/items/Items.png', 'res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png')

# Replace region
content = re.sub(r'region = Rect2\(.*?\)', 'region = Rect2(592, 336, 32, 32)', content)

# Replace collision shape size
content = re.sub(r'size = Vector2\(.*?\)', 'size = Vector2(28, 28)', content)

with open('scenes/objects/campfire.tscn', 'w') as f:
    f.write(content)

