import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

content = content.replace('custom_minimum_size = Vector2(320, 0)', 'custom_minimum_size = Vector2(330, 0)')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
