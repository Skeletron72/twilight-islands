import re

with open('scenes/objects/stone.tscn', 'r') as f:
    content = f.read()

# Remove the AtlasTexture definition
content = re.sub(r'\[sub_resource type="AtlasTexture".*?\n.*?\n.*?\n\n', '', content, flags=re.DOTALL)
# Remove the assignment
content = re.sub(r'texture = SubResource\("AtlasTexture_.*?"\)\n', '', content, flags=re.DOTALL)

with open('scenes/objects/stone.tscn', 'w') as f:
    f.write(content)
