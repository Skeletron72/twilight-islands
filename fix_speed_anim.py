import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace("var fps: float = 10.0", "var fps: float = 6.0")
content = content.replace("@export var speed: float = 60.0", "@export var speed: float = 40.0")

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
