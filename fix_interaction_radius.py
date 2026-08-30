import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# [sub_resource type="CircleShape2D" id="CircleShape2D_interaction"]
# radius = 9.055386
content = re.sub(r'\[sub_resource type="CircleShape2D" id="CircleShape2D_interaction"\]\nradius = [0-9\.]+', '[sub_resource type="CircleShape2D" id="CircleShape2D_interaction"]\nradius = 20.0', content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
