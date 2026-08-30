import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

old_name = """[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/HBoxContainer" unique_id=1309798203]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0, 0, 1)
text = "Выберите чертеж"
label_settings = SubResource("LabelSettings_nd61c")"""

new_name = """[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/HBoxContainer" unique_id=1309798203]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
theme_override_fonts/font = ExtResource("1_h3l6g")
theme_override_font_sizes/font_size = 16
text = "Выберите чертеж" """

content = content.replace(old_name, new_name)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
