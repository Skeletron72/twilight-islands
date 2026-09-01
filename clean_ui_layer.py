import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

content = re.sub(r'uid="uid://chalkboardfont" ', '', content)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
