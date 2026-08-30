import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Add size_flags_horizontal and horizontal_alignment to NameLabel
old_name = """[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/HBoxContainer" unique_id=1309798203]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
theme_override_fonts/font = ExtResource("3_ue6pm")
theme_override_font_sizes/font_size = 16
text = "Выберите чертеж" """

new_name = """[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/HBoxContainer" unique_id=1309798203]
layout_mode = 2
size_flags_horizontal = 3
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
theme_override_fonts/font = ExtResource("3_ue6pm")
theme_override_font_sizes/font_size = 16
horizontal_alignment = 1
text = "Выберите чертеж" """

content = content.replace(old_name, new_name)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
