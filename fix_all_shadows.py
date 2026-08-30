import re

shadow_sub = """[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]
atlas = ExtResource("1_tex")
region = Rect2(560, 176, 16, 16)

"""

def restore_shadow(filepath, ext_id, sprite_name, sprite_uid, offset_y=0):
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove old shadow sub if any
    content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"\].*?region = Rect2\(560, 176, 16, 16\)\n\n', '', content, flags=re.DOTALL)
    
    # Add new shadow sub
    sub = f"""[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]
atlas = ExtResource("{ext_id}")
region = Rect2(560, 176, 16, 16)

"""
    content = content.replace('[sub_resource', sub + '[sub_resource', 1)
    
    # Remove old shadow node if any
    content = re.sub(r'\[node name="Shadow" type="Sprite2D".*?texture = SubResource\("AtlasTexture_universal_shadow"\)\n\n', '', content, flags=re.DOTALL)
    
    shadow_node = f"""[node name="Shadow" type="Sprite2D" parent="."]
position = Vector2(0, {offset_y})
texture = SubResource("AtlasTexture_universal_shadow")

"""
    
    # Insert shadow node before main sprite
    # We must match the main sprite exactly.
    if sprite_uid:
        target = f'[node name="{sprite_name}" type="Sprite2D" parent="." unique_id={sprite_uid}]'
    else:
        target = f'[node name="{sprite_name}" type="Sprite2D" parent="."]'
        
    if target in content:
        content = content.replace(target, shadow_node + target)
    else:
        # Fallback for player
        if 'Visuals' in content:
            target_vis = '[node name="Visuals" type="Node2D" parent="." unique_id=1018988374]'
            if target_vis in content:
                content = content.replace(target_vis, shadow_node + target_vis)
    
    with open(filepath, 'w') as f:
        f.write(content)

# storage_box.tscn
# First rewrite it completely to be clean 16x16
box_content = """[gd_scene load_steps=5 format=3 uid="uid://dd2av7pbf5j11"]

[ext_resource type="Texture2D" uid="uid://items_atlas" path="res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png" id="1_tex"]

[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"]
atlas = ExtResource("1_tex")
region = Rect2(560, 176, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_box"]
atlas = ExtResource("1_tex")
region = Rect2(560, 160, 16, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_col"]
size = Vector2(16, 16)

[node name="StorageBox" type="StaticBody2D" groups=["interactable"]]
y_sort_enabled = true
collision_layer = 1
collision_mask = 1

[node name="Shadow" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_universal_shadow")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_box")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_col")
"""
with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(box_content)

# Player
# Need to add ext_resource for the tileset since player doesn't have it natively, but I added it in an earlier script. Let's just run my earlier logic but with offset 0.
