import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Replace any occurrence of parent=".../RightPage/Details/..." 
# with parent=".../RightPage/DetailsMargin/Details/..."

old_prefix = 'parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/'
new_prefix = 'parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/'

content = content.replace(old_prefix, new_prefix)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)

