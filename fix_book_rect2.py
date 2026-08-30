import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Add AtlasTexture_book at the top
atlas_res = """[sub_resource type="AtlasTexture" id="AtlasTexture_book"]
atlas = ExtResource("tex_book")
region = Rect2(16, 17, 160, 111)

[node name="BookUI" type="Control"]"""
content = re.sub(r'\[node name="BookUI" type="Control"\]', atlas_res, content)

# Change BookPanel to TextureRect
content = re.sub(r'\[node name="BookPanel" type="NinePatchRect" parent="DimBackground/CenterContainer/HBoxContainer"\].*?axis_stretch_vertical = 1', 
"""[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/HBoxContainer"]
custom_minimum_size = Vector2(480, 333)
layout_mode = 2
texture = SubResource("AtlasTexture_book")
texture_filter = 1
expand_mode = 1
stretch_mode = 5""", content, flags=re.DOTALL)

# Revert Tab Buttons
for btn in ['BtnInv', 'BtnChar', 'BtnCraft']:
    content = re.sub(rf'\[node name="{btn}" type="Button".*?text = "', 
rf'[node name="{btn}" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]\nlayout_mode = 2\ntext = "', content, flags=re.DOTALL)

# Remove StyleBoxTexture_tab
content = re.sub(r'\[sub_resource type="StyleBoxTexture" id="StyleBoxTexture_tab"\].*?region_rect = Rect2\(224, 240, 144, 64\)\n', '', content, flags=re.DOTALL)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
