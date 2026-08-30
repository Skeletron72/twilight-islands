import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Fix DetailsMargin on right page
old_right = """[node name="DetailsMargin" type="MarginContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/margin_left = 24
theme_override_constants/margin_right = 12"""

new_right = """[node name="DetailsMargin" type="MarginContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/margin_left = 12
theme_override_constants/margin_right = 24"""

content = content.replace(old_right, new_right)

# Add autowrap to StatsLabel
old_stats = """[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details" unique_id=93012913]
layout_mode = 2
label_settings = SubResource("LabelSettings_nd61c")
theme_override_colors/font_color = Color(0, 0.3, 0, 1)
theme_override_font_sizes/font_size = 12
label_settings = SubResource("LabelSettings_nd61c")"""

new_stats = """[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details" unique_id=93012913]
layout_mode = 2
label_settings = SubResource("LabelSettings_nd61c")
theme_override_colors/font_color = Color(0, 0.3, 0, 1)
theme_override_font_sizes/font_size = 12
autowrap_mode = 3
label_settings = SubResource("LabelSettings_nd61c")"""

content = content.replace(old_stats, new_stats)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
