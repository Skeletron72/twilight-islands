import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

content = re.sub(r'(\[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox".*?\]\n)',
                 r'\1mouse_filter = 2\n', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
