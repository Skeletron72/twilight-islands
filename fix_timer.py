import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

content = content.replace('await get_tree().create_timer(0.15).timeout', 'await get_tree().create_timer(0.15, true).timeout')

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
