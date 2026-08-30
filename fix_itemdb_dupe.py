with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

# Fix RECIPES
content = content.replace('\t"stone_sword": {"stick": 1, "stone": 2},\n\t\t"stone_sword": {"stick": 1, "stone": 2},', '\t"stone_sword": {"stick": 1, "stone": 2},')

# Fix ITEMS
content = content.replace('}\n\t\t"stone_sword": {', '},\n\t"stone_sword": {')

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
