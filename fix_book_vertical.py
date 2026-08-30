import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Add separation override to Details VBoxContainer
old_details = """[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin" unique_id=1032841872]
layout_mode = 2"""

new_details = """[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin" unique_id=1032841872]
layout_mode = 2
theme_override_constants/separation = 2"""

content = content.replace(old_details, new_details)

# Reduce DescLabel font size
content = re.sub(r'\[node name="DescLabel".*?font_size = 12', 
                 lambda m: m.group(0).replace('font_size = 12', 'font_size = 10'), 
                 content, flags=re.DOTALL)

# Reduce StatsLabel font size
content = re.sub(r'\[node name="StatsLabel".*?font_size = 12', 
                 lambda m: m.group(0).replace('font_size = 12', 'font_size = 10'), 
                 content, flags=re.DOTALL)

# Reduce ReqTitle ("Требуется:") font size
old_req_title = """[node name="ReqTitle" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details" unique_id=851873744]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.2, 0.1, 1)
text = "Требуется:"
label_settings = SubResource("LabelSettings_nd61c")"""

new_req_title = """[node name="ReqTitle" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details" unique_id=851873744]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.2, 0.1, 1)
theme_override_fonts/font = ExtResource("4_yq8p3")
theme_override_font_sizes/font_size = 10
text = "Требуется:"
label_settings = SubResource("LabelSettings_nd61c")"""
content = content.replace(old_req_title, new_req_title)

# Reduce main icon size
content = content.replace('custom_minimum_size = Vector2(42, 42)', 'custom_minimum_size = Vector2(32, 32)')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
