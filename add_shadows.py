import re

shadow_sub = """[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]
atlas = ExtResource("2_tex")
region = Rect2(560, 176, 16, 16)

"""

shadow_node = """[node name="Shadow" type="Sprite2D" parent="." unique_id=999999999]
position = Vector2(0, -2)
texture = SubResource("AtlasTexture_universal_shadow")

[node name="Sprite2D" type="Sprite2D" parent="."]"""

# Stone
with open('scenes/objects/stone.tscn', 'r') as f:
    content = f.read()

content = content.replace('[sub_resource', shadow_sub + '[sub_resource', 1)
content = content.replace('[node name="Sprite2D" type="Sprite2D" parent="." unique_id=395918286]', shadow_node.replace('unique_id=999999999', 'unique_id=395918287')[:-34] + '[node name="Sprite2D" type="Sprite2D" parent="." unique_id=395918286]')
with open('scenes/objects/stone.tscn', 'w') as f:
    f.write(content)

# Tree
with open('scenes/objects/tree.tscn', 'r') as f:
    content = f.read()

# Tree uses ExtResource 2_tex for the tileset too! (Hopefully). Let's check.
