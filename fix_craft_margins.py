import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 1. Wrap Details in CraftTab in a MarginContainer
old_details = r'(\[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage" unique_id=1032841872\]\nlayout_mode = 2\nsize_flags_vertical = 3\n)'

new_details = """[node name="DetailsMargin" type="MarginContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/margin_left = 24
theme_override_constants/margin_right = 12
theme_override_constants/margin_bottom = 12

[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin" unique_id=1032841872]
layout_mode = 2
"""

content = re.sub(old_details, new_details, content)

# But wait, now all children of Details have the wrong `parent=` string!
# "parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details""
# needs to be replaced with:
# "parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details""

old_parent = 'parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"'
new_parent = 'parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details"'

content = content.replace(old_parent, new_parent)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
