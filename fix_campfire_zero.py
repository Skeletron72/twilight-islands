import re

with open('scenes/objects/campfire.tscn', 'r') as f:
    content = f.read()

content = content.replace('position = Vector2(0, 16)\n', '')

with open('scenes/objects/campfire.tscn', 'w') as f:
    f.write(content)
