import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Revert BookPanel size
content = content.replace('custom_minimum_size = Vector2(640, 384)', 'custom_minimum_size = Vector2(480, 288)')

# Margins for 480x288
# Spine is at 240. Visual paper starts roughly at 24px and ends at 456px (margins 24)
# But user said: "details a little more to the left backpack a little more to the right."
# So left page needs to be shifted left -> make margin_left smaller, margin_right larger?
# Wait, HBoxContainer splits at exactly 50%.
# If margin_left = 16, margin_right = 16: HBox goes from 16 to 464. Midpoint is 240 (perfectly on spine).
# Left Page: 16 to 240. Center is 128.
# Right Page: 240 to 464. Center is 352.
# Let's set left and right margins to 20, and use a custom padding inside Left/Right pages if needed.
# Actually, if we just use margin_left=16, margin_right=16, it pushes them outward!
old_margins = """theme_override_constants/margin_left = 24
theme_override_constants/margin_top = 24
theme_override_constants/margin_right = 24
theme_override_constants/margin_bottom = 24"""
new_margins = """theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 18
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 18"""
content = content.replace(old_margins, new_margins)

# Change inventory_grid columns to 4
content = re.sub(r'\[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer".*?\]\nlayout_mode = 2\nsize_flags_horizontal = 6',
                 '[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer"]\nlayout_mode = 2\nsize_flags_horizontal = 6\ncolumns = 4', content)

# Change char_inv_grid columns to 4
content = re.sub(r'\[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer".*?\]\nlayout_mode = 2\nsize_flags_horizontal = 6',
                 '[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer"]\nlayout_mode = 2\nsize_flags_horizontal = 6\ncolumns = 4', content)

# Update Spacer size in Tabs!
# Book is 480 wide. Spine is 240. Right page is 240 to 464.
# If Tabs need to be over the right page, Spacer should be around 250!
content = content.replace('custom_minimum_size = Vector2(330, 0)', 'custom_minimum_size = Vector2(250, 0)')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
