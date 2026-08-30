import re

with open('scenes/objects/storage_box.tscn', 'r') as f:
    content = f.read()

# 1. Remove the shadow sub_resource and node
content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_shadow"\].*?region = Rect2\(560, 176, 16, 16\)\n\n', '', content, flags=re.DOTALL)
content = re.sub(r'\[node name="Shadow" type="Sprite2D" parent="\."\]\ntexture = SubResource\("AtlasTexture_shadow"\)\n\n', '', content)

# 2. Update AtlasTexture_box to 16x32
content = content.replace('region = Rect2(560, 160, 16, 16)', 'region = Rect2(560, 160, 16, 32)')

# 3. Add offset = Vector2(0, -8) to Sprite2D
content = content.replace('[node name="Sprite2D" type="Sprite2D" parent="."]\ntexture = SubResource("AtlasTexture_box")', '[node name="Sprite2D" type="Sprite2D" parent="."]\ntexture = SubResource("AtlasTexture_box")\noffset = Vector2(0, -8)')

# 4. Update CollisionShape2D to size Vector2(16, 16) and position Vector2(0, 0)
content = re.sub(r'size = Vector2\(16, 14\)', 'size = Vector2(16, 16)', content)
content = re.sub(r'position = Vector2\(0, 1\)', 'position = Vector2(0, 0)', content)


with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(content)
