import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Left page button font size 14 -> 12
content = content.replace('btn.add_theme_font_size_override("font_size", 14)', 'btn.add_theme_font_size_override("font_size", 12)')

# Right page name label font to chalkboard
# Wait, craft_name is a node setup in _ready or implicitly styled in tscn.
# We can style it in code in _ready, or find its path. Let's do it in code dynamically.

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
