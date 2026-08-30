import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Add WarmPixel font to DescLabel
old_desc = """[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.2, 0.2, 1)
theme_override_font_sizes/font_size = 10
autowrap_mode = 3"""

new_desc = """[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.2, 0.2, 1)
theme_override_fonts/font = ExtResource("4_yq8p3")
theme_override_font_sizes/font_size = 10
autowrap_mode = 3"""

content = content.replace(old_desc, new_desc)

# Add WarmPixel font to StatsLabel
old_stats = """[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0.3, 0, 1)
theme_override_font_sizes/font_size = 10
autowrap_mode = 3"""

new_stats = """[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0.3, 0, 1)
theme_override_fonts/font = ExtResource("4_yq8p3")
theme_override_font_sizes/font_size = 10
autowrap_mode = 3"""

content = content.replace(old_stats, new_stats)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
