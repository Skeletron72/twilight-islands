import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

old_char_grid = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
columns = 4"""

new_char_grid = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6
size_flags_vertical = 4
columns = 5
theme_override_constants/h_separation = 2
theme_override_constants/v_separation = 2"""

content = content.replace(old_char_grid, new_char_grid)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
