import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

old_label = """[node name="Label" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details" unique_id=851873744]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.2, 0.1, 1)
text = "Требуется:"
label_settings = SubResource("LabelSettings_nd61c")"""

new_label = """[node name="ReqTitle" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details" unique_id=851873744]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.2, 0.1, 1)
text = "Требуется:"
label_settings = SubResource("LabelSettings_nd61c")"""

content = content.replace(old_label, new_label)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
