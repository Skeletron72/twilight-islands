import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Change BookPanel size to 640x384
content = content.replace('custom_minimum_size = Vector2(480, 288)', 'custom_minimum_size = Vector2(640, 384)')

# Update margins for Pages MarginContainer
# Left and Right 60, Top and Bottom 40
old_margins = """theme_override_constants/margin_left = 40
theme_override_constants/margin_top = 25
theme_override_constants/margin_right = 40
theme_override_constants/margin_bottom = 25"""
new_margins = """theme_override_constants/margin_left = 60
theme_override_constants/margin_top = 40
theme_override_constants/margin_right = 60
theme_override_constants/margin_bottom = 40"""
content = content.replace(old_margins, new_margins)

# Also scale the Tabs? The tabs are 48x48. They will just look a bit smaller relative to the book, but they are bookmarks so that's fine.

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
