import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Restore tabs to 42, 42
for tab_name in ["BtnInv", "BtnChar", "BtnCraft", "BtnQuest"]:
    pattern = rf'(\[node name="{tab_name}".*?\]\n)custom_minimum_size = Vector2\(32, 32\)'
    content = re.sub(pattern, r'\1custom_minimum_size = Vector2(42, 42)', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
