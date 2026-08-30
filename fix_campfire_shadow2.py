import re

with open('scenes/objects/campfire.tscn', 'r') as f:
    content = f.read()

content = content.replace('[node name="Shadow" type="Sprite2D" parent="." unique_id=999999999]\ntexture = SubResource("AtlasTexture_universal_shadow")', '[node name="Shadow" type="Sprite2D" parent="." unique_id=999999999]\nposition = Vector2(0, 16)\ntexture = SubResource("AtlasTexture_universal_shadow")')

with open('scenes/objects/campfire.tscn', 'w') as f:
    f.write(content)
