import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 1. Revert LeftPage ScrollMargin
content = content.replace('theme_override_constants/margin_left = 54', 'theme_override_constants/margin_left = 24')

# 2. Fix RightPage DetailsMargin (margin_left = 32, margin_right = 12)
old_right_margin = """[node name="DetailsMargin" type="MarginContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/margin_left = 12
theme_override_constants/margin_right = 24"""

new_right_margin = """[node name="DetailsMargin" type="MarginContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/margin_left = 28
theme_override_constants/margin_right = 12"""

content = content.replace(old_right_margin, new_right_margin)

# 3. Reduce fonts in tscn to 8
content = re.sub(r'(\[node name="(DescLabel|StatsLabel|ReqTitle)".*?\]\n.*?theme_override_font_sizes/font_size = )10', r'\g<1>8', content, flags=re.DOTALL)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)


with open('scripts/components/book_ui.gd', 'r') as f:
    gd_content = f.read()

# 4. Reduce req_label font in GDScript to 8
gd_content = gd_content.replace('req_label.add_theme_font_size_override("font_size", 10)', 'req_label.add_theme_font_size_override("font_size", 8)')

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(gd_content)

