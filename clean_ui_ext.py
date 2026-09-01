import re

with open('scenes/ui/mobile_controls.tscn', 'r') as f:
    content = f.read()

# Remove the ext_resource declarations
content = re.sub(r'\[ext_resource type="Texture2D".*?id="tex_base"\]\n', '', content)
content = re.sub(r'\[ext_resource type="Texture2D".*?id="tex_knob"\]\n', '', content)
content = re.sub(r'\[ext_resource type="Texture2D".*?id="tex_action"\]\n', '', content)

with open('scenes/ui/mobile_controls.tscn', 'w') as f:
    f.write(content)
