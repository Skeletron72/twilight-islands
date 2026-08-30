import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

def replace_btn(name, icon_res):
    old_btn = rf'\[node name="{name}" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs".*?text = ".*?"\n'
    new_btn = rf"""[node name="{name}" type="TextureButton" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]
custom_minimum_size = Vector2(60, 48)
layout_mode = 2
texture_normal = SubResource("AtlasTexture_bookmark_red")
stretch_mode = 0

[node name="Icon" type="TextureRect" parent="DimBackground/CenterContainer/HBoxContainer/Tabs/{name}"]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -16.0
offset_top = -16.0
offset_right = 16.0
offset_bottom = 16.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource("{icon_res}")
expand_mode = 1
stretch_mode = 5
"""
    return re.sub(old_btn, new_btn, content, flags=re.DOTALL)

content = replace_btn("BtnInv", "AtlasTexture_icon_inv")
content = replace_btn("BtnChar", "AtlasTexture_icon_char")
content = replace_btn("BtnCraft", "AtlasTexture_icon_craft")

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
