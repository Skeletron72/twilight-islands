import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

old_margins = """theme_override_constants/margin_left = 12
theme_override_constants/margin_top = 18
theme_override_constants/margin_right = 12
theme_override_constants/margin_bottom = 18"""
new_margins = """theme_override_constants/margin_left = 4
theme_override_constants/margin_top = 18
theme_override_constants/margin_right = 4
theme_override_constants/margin_bottom = 18"""
content = content.replace(old_margins, new_margins)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
