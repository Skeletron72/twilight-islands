import re

def add_shadow(filepath, tileset_ext_id, offset_y, sprite_uid):
    with open(filepath, 'r') as f:
        content = f.read()

    shadow_sub = f"""[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]
atlas = ExtResource("{tileset_ext_id}")
region = Rect2(560, 176, 16, 16)

"""
    if '[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]' not in content:
        content = content.replace('[sub_resource', shadow_sub + '[sub_resource', 1)
    
    shadow_node = f"""[node name="Shadow" type="Sprite2D" parent="." unique_id=999999999]
position = Vector2(0, {offset_y})
texture = SubResource("AtlasTexture_universal_shadow")

"""
    if '[node name="Shadow" type="Sprite2D"' not in content:
        content = content.replace(f'[node name="Sprite2D" type="Sprite2D" parent="." unique_id={sprite_uid}]', shadow_node + f'[node name="Sprite2D" type="Sprite2D" parent="." unique_id={sprite_uid}]')
    elif '[node name="Sprite2D" type="Sprite2D" parent="."]' in content and '[node name="Shadow" type="Sprite2D"' not in content:
        content = content.replace('[node name="Sprite2D" type="Sprite2D" parent="."]', shadow_node + '[node name="Sprite2D" type="Sprite2D" parent="."]')

    with open(filepath, 'w') as f:
        f.write(content)

# Tree uses 2_5qchx. We can grep its Sprite2D unique_id.
# Let's just find it and replace.
add_shadow('scenes/objects/tree.tscn', '2_5qchx', -2, '969829852')

with open('scenes/objects/campfire.tscn', 'r') as f:
    c = f.read()
    if '[node name="Shadow"' not in c:
        shadow = """[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]
atlas = ExtResource("1_tex")
region = Rect2(560, 176, 16, 16)

"""
        c = c.replace('[sub_resource', shadow + '[sub_resource', 1)
        node = """[node name="Shadow" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_universal_shadow")
position = Vector2(0, 0)

[node name="Sprite2D" type="Sprite2D" parent="."]"""
        c = c.replace('[node name="Sprite2D" type="Sprite2D" parent="."]', node)
        with open('scenes/objects/campfire.tscn', 'w') as f2:
            f2.write(c)
