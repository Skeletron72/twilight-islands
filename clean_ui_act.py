import re

with open('scenes/ui/mobile_controls.tscn', 'r') as f:
    content = f.read()

content = re.sub(r'\[ext_resource type="Texture2D".*?path="res://assets/sprites/ui/action_button.png".*?\]\n', '', content)

with open('scenes/ui/mobile_controls.tscn', 'w') as f:
    f.write(content)

with open('scenes/ui/debug_panel.tscn', 'r') as f:
    content = f.read()
content = re.sub(r'uid="uid://debugscript123" ', '', content)
with open('scenes/ui/debug_panel.tscn', 'w') as f:
    f.write(content)
