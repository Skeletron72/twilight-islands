import re
with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace('var current_target: Area2D = null', 'var current_target = null')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
