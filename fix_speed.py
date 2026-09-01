import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace("@export var speed: float = 120.0", "@export var speed: float = 60.0")

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
