import re

# 1. Fix inventory_slot.tscn size
with open('scenes/ui/inventory_slot.tscn', 'r') as f:
    slot_content = f.read()

slot_content = slot_content.replace('custom_minimum_size = Vector2(48, 48)', 'custom_minimum_size = Vector2(42, 42)')
with open('scenes/ui/inventory_slot.tscn', 'w') as f:
    f.write(slot_content)

# 2. Fix book_ui.tscn margins and Tabs Spacer
with open('scenes/ui/book_ui.tscn', 'r') as f:
    book_content = f.read()

# Margins
old_margins = """theme_override_constants/margin_left = 60
theme_override_constants/margin_top = 40
theme_override_constants/margin_right = 60
theme_override_constants/margin_bottom = 40"""
new_margins = """theme_override_constants/margin_left = 80
theme_override_constants/margin_top = 60
theme_override_constants/margin_right = 80
theme_override_constants/margin_bottom = 60"""
book_content = book_content.replace(old_margins, new_margins)

# Tabs Spacer
# Use regex to inject spacer before the first TextureButton in Tabs
spacer = """[node name="Spacer" type="Control" parent="DimBackground/CenterContainer/MainVBox/Tabs"]
custom_minimum_size = Vector2(340, 0)
layout_mode = 2

"""
# Find the first TextureButton under Tabs
book_content = re.sub(r'(\[node name="BtnInv" type="TextureButton" parent="DimBackground/CenterContainer/MainVBox/Tabs".*?\])', spacer + r'\1', book_content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(book_content)
