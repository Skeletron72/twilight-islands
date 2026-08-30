import re

with open('scenes/ui/storage_ui.tscn', 'r') as f:
    content = f.read()

# Remove ChestMargin
old_chest = """[node name="ChestMargin" type="MarginContainer" parent="DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage"]
layout_mode = 2
theme_override_constants/margin_left = 32

[node name="ChestGrid" type="GridContainer" parent="DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/ChestMargin"]
layout_mode = 2
size_flags_horizontal = 4
columns = 4"""

new_chest = """[node name="ChestGrid" type="GridContainer" parent="DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_horizontal = 4
columns = 4"""

content = content.replace(old_chest, new_chest)

with open('scenes/ui/storage_ui.tscn', 'w') as f:
    f.write(content)

with open('scripts/components/storage_ui.gd', 'r') as f:
    gd_content = f.read()

gd_content = gd_content.replace('HBoxContainer/RightPage/ChestMargin/ChestGrid', 'HBoxContainer/RightPage/ChestGrid')

with open('scripts/components/storage_ui.gd', 'w') as f:
    f.write(gd_content)
