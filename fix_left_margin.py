import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

content = content.replace('theme_override_constants/margin_left = 36', 'theme_override_constants/margin_left = 54')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
