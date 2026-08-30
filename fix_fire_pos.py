import re

with open('scenes/objects/campfire.tscn', 'r') as f:
    content = f.read()

# Replace FireSprite position
old_pos = "position = Vector2(-2, -4)"
new_pos = "position = Vector2(-1, -7)"

content = content.replace(old_pos, new_pos)

with open('scenes/objects/campfire.tscn', 'w') as f:
    f.write(content)
