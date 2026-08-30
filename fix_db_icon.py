with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

content = content.replace('Rect2(560, 160, 16, 32)', 'Rect2(560, 160, 16, 16)')

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
