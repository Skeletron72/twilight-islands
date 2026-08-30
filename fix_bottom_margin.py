import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

content = re.sub(r'(\[node name="DetailsMargin".*?\]\nlayout_mode = 2\nsize_flags_vertical = 3\ntheme_override_constants/margin_left = 40\ntheme_override_constants/margin_right = 24\ntheme_override_constants/margin_bottom = )\d+', r'\g<1>32', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
