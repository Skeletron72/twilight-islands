import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

old_logic = "atlas.region = Rect2(pos.x * ITEM_SIZE, pos.y * ITEM_SIZE, ITEM_SIZE, ITEM_SIZE)"
new_logic = "atlas.region = Rect2((pos.x - 1) * ITEM_SIZE, (pos.y - 1) * ITEM_SIZE, ITEM_SIZE, ITEM_SIZE)"

content = content.replace(old_logic, new_logic)

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
