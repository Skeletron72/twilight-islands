import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Fix inventory grid
inv_old = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6
columns = 4
size_flags_vertical = 4
columns = 5
theme_override_constants/h_separation = 2
theme_override_constants/v_separation = 2"""

inv_new = """[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6
columns = 4
theme_override_constants/h_separation = 2
theme_override_constants/v_separation = 2"""
# Since the exact text might be messy from multiple replaces, let's just rewrite the block!

content = re.sub(r'\[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer"\].*?\[node name="CharacterTab"', inv_new + '\n\n[node name="CharacterTab"', content, flags=re.DOTALL)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
