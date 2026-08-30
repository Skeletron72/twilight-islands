import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Fix LeftPage ScrollMargin
content = re.sub(r'(\[node name="ScrollMargin".*?\]\nlayout_mode = 2\nsize_flags_vertical = 3\ntheme_override_constants/margin_left = )\d+', r'\g<1>40', content)

# Fix RightPage DetailsMargin
content = re.sub(r'(\[node name="DetailsMargin".*?\]\nlayout_mode = 2\nsize_flags_vertical = 3\ntheme_override_constants/margin_left = )\d+', r'\g<1>40', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
