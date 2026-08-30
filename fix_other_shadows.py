import re

def add_shadow(filepath, tileset_ext_id, sprite_uid):
    with open(filepath, 'r') as f:
        content = f.read()

    shadow_sub = f"""[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]
atlas = ExtResource("{tileset_ext_id}")
region = Rect2(560, 176, 16, 16)

"""
    if '[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]' not in content:
        content = content.replace('[sub_resource', shadow_sub + '[sub_resource', 1)
    
    shadow_node = f"""[node name="Shadow" type="Sprite2D" parent="." unique_id=999999999]
texture = SubResource("AtlasTexture_universal_shadow")

"""
    # Just to be safe, find the sprite node and inject before it
    if sprite_uid:
        target = f'[node name="Sprite2D" type="Sprite2D" parent="." unique_id={sprite_uid}]'
    else:
        target = f'[node name="Sprite2D" type="Sprite2D" parent="."]'
        
    if target in content:
        content = content.replace(target, shadow_node + target)

    with open(filepath, 'w') as f:
        f.write(content)

add_shadow('scenes/objects/campfire.tscn', '1_tex', None)
add_shadow('scenes/objects/tree.tscn', '2_5qchx', '969829852')
add_shadow('scenes/objects/stone.tscn', '2_tex', '395918286')
