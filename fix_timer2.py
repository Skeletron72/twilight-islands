import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Remove the offending lines
content = re.sub(r'\t# Просто ждем небольшую паузу.*?PROCESS_MODE_ALWAYS\n', '', content, flags=re.DOTALL)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
