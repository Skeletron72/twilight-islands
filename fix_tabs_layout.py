import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

content = re.sub(r'(\[node name="Tabs".*?\]\nlayout_mode = 2\n)', r'\1size_flags_horizontal = 3\n', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
