import re

with open('scenes/objects/stone.tscn', 'r') as f:
    content = f.read()

pattern = r'(\[node name="Stone" type="Area2D"[^\]]*\]\n(?:[a-z_]+ = [^\n]+\n)*script = ExtResource\("1_dest"\)\n)max_hp = \d+\n(resource_id = "stone")'
replacement = r'\1max_hp = 3\ndrop_on_shrink = 1\nregions = Array[Rect2]([Rect2(848, 464, 32, 32), Rect2(816, 464, 32, 32), Rect2(784, 464, 32, 32)])\n\2'

content = re.sub(pattern, replacement, content)

with open('scenes/objects/stone.tscn', 'w') as f:
    f.write(content)
