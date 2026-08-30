import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 1. Fix margins to 24
old_margins = """theme_override_constants/margin_left = 80
theme_override_constants/margin_top = 60
theme_override_constants/margin_right = 80
theme_override_constants/margin_bottom = 60"""
new_margins = """theme_override_constants/margin_left = 24
theme_override_constants/margin_top = 24
theme_override_constants/margin_right = 24
theme_override_constants/margin_bottom = 24"""
content = content.replace(old_margins, new_margins)

# 2. Details alignment
old_details = """[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage" unique_id=648843203]
layout_mode = 2
size_flags_vertical = 3
alignment = 1"""
new_details = """[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage" unique_id=648843203]
layout_mode = 2
size_flags_vertical = 3"""
# regex in case unique_id differs
content = re.sub(r'\[node name="Details" type="VBoxContainer" parent=".*?LeftPage".*?\]\nlayout_mode = 2\nsize_flags_vertical = 3\nalignment = 1',
                 r'[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage"]\nlayout_mode = 2\nsize_flags_vertical = 3', content)

# 3. GridContainer vertical centering (remove size_flags_vertical = 4)
# For InventoryTab
inv_grid = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6
size_flags_vertical = 4"""
new_inv_grid = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6"""
content = content.replace(inv_grid, new_inv_grid)

# For CharacterTab char_inv_grid
char_grid = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6
size_flags_vertical = 4"""
new_char_grid = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6"""
content = content.replace(char_grid, new_char_grid)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
