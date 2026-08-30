import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

content = content.replace('"grid_pos": Vector2(13, 3)', '"grid_pos": Vector2(13, 3),\n\t\t"particle_color": Color(0.9, 0.1, 0.1, 1.0)')
content = content.replace('"grid_pos": Vector2(12, 3)', '"grid_pos": Vector2(12, 3),\n\t\t"particle_color": Color(0.95, 0.85, 0.1, 1.0)')

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
