import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace('_play_anim("axe") # Use axe for combat for now', '_play_anim("attack")')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
