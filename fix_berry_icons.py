import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

# Replace red berry
content = content.replace(
    '"red_berry": {\n\t\t"name": "Красная ягода",\n\t\t"desc": "Вкусная и сочная. Восстанавливает голод.",\n\t\t"max_stack": 99,\n\t\t"hunger_restore": 15.0,\n\t\t"grid_pos": Vector2(0, 0)\n\t},',
    '"red_berry": {\n\t\t"name": "Красная ягода",\n\t\t"desc": "Вкусная и сочная. Восстанавливает голод.",\n\t\t"max_stack": 99,\n\t\t"hunger_restore": 15.0,\n\t\t"grid_pos": Vector2(13, 3)\n\t},'
)

# Replace yellow berry
content = content.replace(
    '"yellow_berry": {\n\t\t"name": "Желтая ягода",\n\t\t"desc": "Сладкая и питательная. Восстанавливает голод.",\n\t\t"max_stack": 99,\n\t\t"hunger_restore": 25.0,\n\t\t"grid_pos": Vector2(0, 0)\n\t},',
    '"yellow_berry": {\n\t\t"name": "Желтая ягода",\n\t\t"desc": "Сладкая и питательная. Восстанавливает голод.",\n\t\t"max_stack": 99,\n\t\t"hunger_restore": 25.0,\n\t\t"grid_pos": Vector2(12, 3)\n\t},'
)

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
