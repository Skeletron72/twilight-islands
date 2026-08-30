import re

with open('scenes/objects/storage_box.tscn', 'r') as f:
    content = f.read()

# Replace texture path
content = content.replace('res://resources/items/Items.png', 'res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png')

# Add shadow AtlasTexture and Node
# The current SubResource is AtlasTexture_box
new_subresources = """[sub_resource type="AtlasTexture" id="AtlasTexture_box"]
atlas = ExtResource("1_tex")
region = Rect2(560, 160, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_shadow"]
atlas = ExtResource("1_tex")
region = Rect2(560, 176, 16, 16)"""

content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_box"\].*?region = Rect2\(.*?\)', new_subresources, content, flags=re.DOTALL)

# Add shadow sprite BEFORE the main sprite
shadow_node = """[node name="Shadow" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_shadow")

[node name="Sprite2D" type="Sprite2D" parent="."]"""

content = content.replace('[node name="Sprite2D" type="Sprite2D" parent="."]', shadow_node)

with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(content)

