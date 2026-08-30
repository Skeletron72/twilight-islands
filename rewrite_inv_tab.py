import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

start_idx = content.find('[node name="InventoryTab"')
end_idx = content.find('[node name="CharacterTab"')

new_inv_block = """[node name="InventoryTab" type="Control" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages"]
layout_mode = 2

[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="LeftPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Детали"
horizontal_alignment = 1

[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage"]
layout_mode = 2
size_flags_vertical = 3
alignment = 1

[node name="IconRect" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/Details"]
custom_minimum_size = Vector2(64, 64)
layout_mode = 2
stretch_mode = 5

[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0, 0, 1)
text = "Выберите предмет"
horizontal_alignment = 1

[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.2, 0.2, 1)
theme_override_font_sizes/font_size = 12
text = ""
horizontal_alignment = 1
autowrap_mode = 3

[node name="Divider" type="ColorRect" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer"]
custom_minimum_size = Vector2(2, 0)
layout_mode = 2
color = Color(0, 0, 0, 0)

[node name="RightPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Рюкзак"
horizontal_alignment = 1

[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 6
size_flags_vertical = 4
columns = 5
theme_override_constants/h_separation = 2
theme_override_constants/v_separation = 2

"""

content = content[:start_idx] + new_inv_block + content[end_idx:]

# Since we changed node paths, we MUST update book_ui.gd @onready vars!
# inventory_grid is now in RightPage!
# detail_name, detail_desc, detail_icon are now in LeftPage!

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
