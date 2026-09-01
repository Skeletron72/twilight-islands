import re

with open('scenes/ui/mobile_controls.tscn', 'r') as f:
    content = f.read()

# Remove the textures from TextureRect nodes and the Sprite2D in ActionButton
content = re.sub(r'texture = ExtResource\("tex_base"\)\n', '', content)
content = re.sub(r'texture = ExtResource\("tex_knob"\)\n', '', content)
content = re.sub(r'texture = ExtResource\("tex_action"\)\n', '', content)

with open('scenes/ui/mobile_controls.tscn', 'w') as f:
    f.write(content)
