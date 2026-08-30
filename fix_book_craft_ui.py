import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Add ScrollMargin to LeftPage
old_scroll = """[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage" unique_id=913068805]
layout_mode = 2
size_flags_vertical = 3
horizontal_scroll_mode = 0

[node name="RecipeList" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollContainer" unique_id=692617277]"""

new_scroll = """[node name="ScrollMargin" type="MarginContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/margin_left = 24
theme_override_constants/margin_right = 12
theme_override_constants/margin_bottom = 12

[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollMargin" unique_id=913068805]
layout_mode = 2
size_flags_vertical = 3
horizontal_scroll_mode = 0

[node name="RecipeList" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollMargin/ScrollContainer" unique_id=692617277]"""

content = content.replace(old_scroll, new_scroll)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
