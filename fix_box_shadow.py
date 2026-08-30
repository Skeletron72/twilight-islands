import re

with open('scenes/objects/storage_box.tscn', 'r') as f:
    content = f.read()

# Make sure Shadow is at Vector2(0, 16)
content = content.replace('[node name="Shadow" type="Sprite2D" parent="."]\ntexture = SubResource("AtlasTexture_universal_shadow")', '[node name="Shadow" type="Sprite2D" parent="."]\nposition = Vector2(0, 16)\ntexture = SubResource("AtlasTexture_universal_shadow")')

with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(content)

