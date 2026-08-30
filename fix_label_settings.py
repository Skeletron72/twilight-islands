import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Remove label_settings from DescLabel, StatsLabel, ReqTitle
# DescLabel
content = re.sub(r'\[node name="DescLabel".*?\]\nlayout_mode = 2\nlabel_settings = SubResource\("LabelSettings_nd61c"\)', 
                 '[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"]\nlayout_mode = 2', 
                 content)

# StatsLabel
content = re.sub(r'\[node name="StatsLabel".*?\]\nlayout_mode = 2\nlabel_settings = SubResource\("LabelSettings_nd61c"\)', 
                 '[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"]\nlayout_mode = 2', 
                 content)

# ReqTitle
content = re.sub(r'\[node name="ReqTitle".*?\]\nlayout_mode = 2\ntheme_override_colors/font_color = Color\(0.4, 0.2, 0.1, 1\)\ntheme_override_fonts/font = ExtResource\("4_yq8p3"\)\ntheme_override_font_sizes/font_size = 10\ntext = "Требуется:"\nlabel_settings = SubResource\("LabelSettings_nd61c"\)', 
                 '[node name="ReqTitle" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"]\nlayout_mode = 2\ntheme_override_colors/font_color = Color(0.4, 0.2, 0.1, 1)\ntheme_override_fonts/font = ExtResource("4_yq8p3")\ntheme_override_font_sizes/font_size = 10\ntext = "Требуется:"', 
                 content)

# Also remove trailing duplicate label_settings lines
content = re.sub(r'autowrap_mode = 3\nlabel_settings = SubResource\("LabelSettings_nd61c"\)', 'autowrap_mode = 3', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
