import re

with open('scenes/ui/storage_ui.tscn', 'r') as f:
    content = f.read()

# Add size_flags_horizontal = 4 (Shrink Center) to PlayerGrid
content = content.replace('[node name="PlayerGrid" type="GridContainer" parent="DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage"]\nlayout_mode = 2', '[node name="PlayerGrid" type="GridContainer" parent="DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage"]\nlayout_mode = 2\nsize_flags_horizontal = 4')

# Add size_flags_horizontal = 4 to ChestGrid
content = content.replace('[node name="ChestGrid" type="GridContainer" parent="DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/ChestMargin"]\nlayout_mode = 2', '[node name="ChestGrid" type="GridContainer" parent="DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/ChestMargin"]\nlayout_mode = 2\nsize_flags_horizontal = 4')

with open('scenes/ui/storage_ui.tscn', 'w') as f:
    f.write(content)
