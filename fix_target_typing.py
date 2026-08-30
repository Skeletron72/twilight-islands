import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace('var current_target: Interactable = null', 'var current_target: Area2D = null')
content = content.replace('var closest_target: Interactable = null', 'var closest_target: Area2D = null')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
