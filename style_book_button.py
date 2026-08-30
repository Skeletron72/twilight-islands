import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Add a flat style for the book button
style_str = """[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_btn"]
bg_color = Color(0.4, 0.2, 0.1, 1)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.2, 0.1, 0.05, 1)
anti_aliasing = false

[node name="UILayer" type="CanvasLayer\""""

content = content.replace('[node name="UILayer" type="CanvasLayer"', style_str)

# Apply style to BookButton
old_btn = """[node name="BookButton" type="Button" parent="." unique_id=749661782]
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -100.0
offset_top = 16.0
offset_right = -16.0
offset_bottom = 64.0
grow_horizontal = 0
text = "КНИГА (Tab)\""""

new_btn = """[node name="BookButton" type="Button" parent="." unique_id=749661782]
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -120.0
offset_top = 16.0
offset_right = -16.0
offset_bottom = 64.0
grow_horizontal = 0
theme_override_styles/normal = SubResource("StyleBoxFlat_btn")
theme_override_styles/hover = SubResource("StyleBoxFlat_btn")
theme_override_styles/pressed = SubResource("StyleBoxFlat_btn")
theme_override_colors/font_color = Color(0.9, 0.8, 0.6, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/outline_size = 4
text = "КНИГА (Tab)\""""

content = content.replace(old_btn, new_btn)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
