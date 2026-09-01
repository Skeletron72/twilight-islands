import glob
import re

# 1. Clean the UIDs from the stones
for filepath in glob.glob('scenes/objects/stones/stone_*.tscn'):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Remove the fake texture UIDs
    content = re.sub(r'uid="uid://rock\d+tex" ', '', content)
    
    with open(filepath, 'w') as f:
        f.write(content)

# 2. Fix the Mobile Controls
with open('scenes/ui/mobile_controls.tscn', 'r') as f:
    content = f.read()

# Remove the textures from the TouchScreenButton nodes
content = re.sub(r'texture_normal = ExtResource\("tex_base"\)\n', '', content)
content = re.sub(r'texture_pressed = ExtResource\("tex_base"\)\n', '', content)
content = re.sub(r'texture_normal = ExtResource\("tex_knob"\)\n', '', content)
content = re.sub(r'texture_pressed = ExtResource\("tex_knob"\)\n', '', content)
content = re.sub(r'texture_normal = ExtResource\("tex_action"\)\n', '', content)
content = re.sub(r'texture_pressed = ExtResource\("tex_action"\)\n', '', content)

with open('scenes/ui/mobile_controls.tscn', 'w') as f:
    f.write(content)

