import re
with open('scenes/ui/mobile_controls.tscn', 'r') as f:
    content = f.read()

content = content.replace('texture = ExtResource("tex_act")\n', '')
content = content.replace('texture_normal = ExtResource("tex_act")\n', '')
content = content.replace('texture_pressed = ExtResource("tex_act")\n', '')

with open('scenes/ui/mobile_controls.tscn', 'w') as f:
    f.write(content)
