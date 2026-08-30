import re

with open('scripts/components/skeleton.gd', 'r') as f:
    content = f.read()

content = content.replace('@export var max_hp: int = 20', '@export var max_hp: int = 40')

with open('scripts/components/skeleton.gd', 'w') as f:
    f.write(content)
