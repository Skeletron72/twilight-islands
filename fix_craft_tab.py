import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

craft_tab_ui = """[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="LeftPage" type="VBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Чертежи"
horizontal_alignment = 1

[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="RecipeList" type="VBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Divider" type="ColorRect" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer"]
custom_minimum_size = Vector2(2, 0)
layout_mode = 2
color = Color(0.4, 0.2, 0.1, 0.5)

[node name="RightPage" type="VBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Создание"
horizontal_alignment = 1

[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2

[node name="IconRect" type="TextureRect" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer"]
custom_minimum_size = Vector2(48, 48)
layout_mode = 2
stretch_mode = 5

[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0, 0, 1)
text = "Выберите чертеж"

[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.2, 0.2, 1)
theme_override_font_sizes/font_size = 12
autowrap_mode = 3

[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0.3, 0, 1)
theme_override_font_sizes/font_size = 12

[node name="Label" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.2, 0.1, 1)
text = "Требуется:"

[node name="ReqList" type="VBoxContainer" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
size_flags_vertical = 3

[node name="CraftButton" type="Button" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
text = "Создать"
"""

content = re.sub(r'\[node name="Label" type="Label" parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab"\].*?vertical_alignment = 1\n', craft_tab_ui + '\n', content, flags=re.DOTALL)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
