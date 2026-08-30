import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Replace BookPanel from TextureRect to NinePatchRect
old_panel = """[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/HBoxContainer"]
custom_minimum_size = Vector2(400, 368)
layout_mode = 2
texture = ExtResource("tex_book")
expand_mode = 1
stretch_mode = 5"""

new_panel = """[node name="BookPanel" type="NinePatchRect" parent="DimBackground/CenterContainer/HBoxContainer"]
custom_minimum_size = Vector2(400, 368)
layout_mode = 2
texture = ExtResource("tex_book")
region_rect = Rect2(16, 17, 160, 111)
patch_margin_left = 32
patch_margin_top = 32
patch_margin_right = 32
patch_margin_bottom = 32
axis_stretch_horizontal = 1
axis_stretch_vertical = 1"""

content = content.replace(old_panel, new_panel)

# Also let's style the tabs buttons with Region 1! (144x64)
# Wait, standard Buttons don't use Texture, they use StyleBoxTexture!
# We can add a StyleBoxTexture to book_ui.tscn

style_tex = """[sub_resource type="StyleBoxTexture" id="StyleBoxTexture_tab"]
texture = ExtResource("tex_book")
texture_margin_left = 16.0
texture_margin_top = 16.0
texture_margin_right = 16.0
texture_margin_bottom = 16.0
region_rect = Rect2(224, 240, 144, 64)
"""
content = content.replace('[node name="BookUI"', style_tex + '\n[node name="BookUI"')

old_tab1 = """[node name="BtnInv" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]
layout_mode = 2
text = "Рюкзак\""""
new_tab1 = """[node name="BtnInv" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]
layout_mode = 2
theme_override_styles/normal = SubResource("StyleBoxTexture_tab")
theme_override_styles/hover = SubResource("StyleBoxTexture_tab")
theme_override_styles/pressed = SubResource("StyleBoxTexture_tab")
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Рюкзак\""""
content = content.replace(old_tab1, new_tab1)

old_tab2 = """[node name="BtnChar" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]
layout_mode = 2
text = "Герой\""""
new_tab2 = """[node name="BtnChar" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]
layout_mode = 2
theme_override_styles/normal = SubResource("StyleBoxTexture_tab")
theme_override_styles/hover = SubResource("StyleBoxTexture_tab")
theme_override_styles/pressed = SubResource("StyleBoxTexture_tab")
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Герой\""""
content = content.replace(old_tab2, new_tab2)

old_tab3 = """[node name="BtnCraft" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]
layout_mode = 2
text = "Крафт\""""
new_tab3 = """[node name="BtnCraft" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/Tabs"]
layout_mode = 2
theme_override_styles/normal = SubResource("StyleBoxTexture_tab")
theme_override_styles/hover = SubResource("StyleBoxTexture_tab")
theme_override_styles/pressed = SubResource("StyleBoxTexture_tab")
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Крафт\""""
content = content.replace(old_tab3, new_tab3)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
