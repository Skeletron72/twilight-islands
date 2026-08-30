import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Find BookPanel and replace
old_panel = """[node name="BookPanel" type="Panel" parent="DimBackground/CenterContainer/HBoxContainer"]
custom_minimum_size = Vector2(500, 300)
layout_mode = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_Book")"""

new_panel = """[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/HBoxContainer"]
custom_minimum_size = Vector2(400, 368)
layout_mode = 2
texture = ExtResource("tex_book")
expand_mode = 1
stretch_mode = 5"""
content = content.replace(old_panel, new_panel)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
