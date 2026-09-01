import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

content = content.replace('"res://scenes/objects/stone_%d.tscn"', '"res://scenes/objects/stones/stone_%d.tscn"')

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
