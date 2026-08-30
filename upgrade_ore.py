import re

with open('scenes/levels/twilight_ore.tscn', 'r') as f:
    content = f.read()

# Replace script path
content = content.replace('path="res://scripts/components/resource_node.gd"', 'path="res://scripts/components/destructible.gd"')

# Add properties
old_node = '[node name="TwilightOre" type="Area2D" unique_id=75770497]\ncollision_layer = 2\ncollision_mask = 0\nscript = ExtResource("1_rnode")'
new_node = old_node + '\nmax_hp = 5\nresource_id = "twilight_ore"\ndrop_amount = 1\nis_permanent = false'

content = content.replace(old_node, new_node)

with open('scenes/levels/twilight_ore.tscn', 'w') as f:
    f.write(content)
