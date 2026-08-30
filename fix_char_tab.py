import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

char_tab_ui = """[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="LeftPage" type="VBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Экипировка"
horizontal_alignment = 1

[node name="EquipGrid" type="GridContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage"]
layout_mode = 2
size_flags_vertical = 3
columns = 2

[node name="Divider" type="ColorRect" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer"]
custom_minimum_size = Vector2(2, 0)
layout_mode = 2
color = Color(0.4, 0.2, 0.1, 0.5)

[node name="RightPage" type="VBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Гардероб"
horizontal_alignment = 1

[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
columns = 4"""

content = re.sub(r'\[node name="Label" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab"\].*?vertical_alignment = 1\n', char_tab_ui + '\n', content, flags=re.DOTALL)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
