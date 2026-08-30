import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Increase left margin on LeftPage
content = content.replace('theme_override_constants/margin_left = 24\ntheme_override_constants/margin_right = 12', 'theme_override_constants/margin_left = 36\ntheme_override_constants/margin_right = 12')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
