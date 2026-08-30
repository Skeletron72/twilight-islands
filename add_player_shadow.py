import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Add ExtResource for tileset
tileset_ext = '[ext_resource type="Texture2D" uid="uid://tileset_atlas_shadow" path="res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png" id="tex_shadow_atlas"]\n'
content = content.replace('[sub_resource', tileset_ext + '\n[sub_resource', 1)

# Add SubResource for shadow
shadow_sub = """[sub_resource type="AtlasTexture" id="AtlasTexture_player_shadow"]
atlas = ExtResource("tex_shadow_atlas")
region = Rect2(560, 176, 16, 16)

"""
content = content.replace('[sub_resource', shadow_sub + '[sub_resource', 1)

# Add Sprite2D before Visuals
shadow_node = """[node name="Shadow" type="Sprite2D" parent="." unique_id=999999999]
position = Vector2(0, -2)
texture = SubResource("AtlasTexture_player_shadow")

[node name="Visuals" type="Node2D" parent="." unique_id=1018988374]"""
content = content.replace('[node name="Visuals" type="Node2D" parent="." unique_id=1018988374]', shadow_node)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)

