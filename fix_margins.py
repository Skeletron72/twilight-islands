import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

old_pages = """[node name="Pages" type="MarginContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 16
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 16"""

new_pages = """[node name="Pages" type="MarginContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/margin_left = 40
theme_override_constants/margin_top = 25
theme_override_constants/margin_right = 40
theme_override_constants/margin_bottom = 25"""
content = content.replace(old_pages, new_pages)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
