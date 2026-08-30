import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

content = content.replace('ExtResource("1_h3l6g")', 'ExtResource("3_ue6pm")')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
