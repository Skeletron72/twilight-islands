import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Change Spacer from 340 to 320
content = content.replace('custom_minimum_size = Vector2(340, 0)', 'custom_minimum_size = Vector2(320, 0)')

# Change Tabs separation from 16 to 4
old_tabs = """[node name="Tabs" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox" unique_id=1403863197]
layout_mode = 2
size_flags_horizontal = 3
theme_override_constants/separation = 16"""
new_tabs = """[node name="Tabs" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox" unique_id=1403863197]
layout_mode = 2
size_flags_horizontal = 3
theme_override_constants/separation = 4"""

content = content.replace(old_tabs, new_tabs)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
