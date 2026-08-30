with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Replace RightPage/Details/ with RightPage/DetailsMargin/Details/
content = content.replace('RightPage/Details/', 'RightPage/DetailsMargin/Details/')
# Also need to fix RightPage/Details directly if it was used
content = content.replace('RightPage/Details\n', 'RightPage/DetailsMargin/Details\n')

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
