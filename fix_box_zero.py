import re

with open('scenes/objects/storage_box.tscn', 'r') as f:
    content = f.read()

# Remove ANY position or offset from Shadow and Sprite2D
content = re.sub(r'\[node name="Shadow" type="Sprite2D" parent="."\]\nposition = Vector2\(.*?\)\n', '[node name="Shadow" type="Sprite2D" parent="."]\n', content)
content = re.sub(r'\[node name="Sprite2D" type="Sprite2D" parent="."\]\noffset = Vector2\(.*?\)\n', '[node name="Sprite2D" type="Sprite2D" parent="."]\n', content)

# Remove any other position just in case
content = content.replace('position = Vector2(0, 16)\n', '')

with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(content)
