import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

new_items = """	"red_berry": {
		"name": "Красная ягода",
		"desc": "Вкусная и сочная. Восстанавливает голод.",
		"max_stack": 99,
		"hunger_restore": 15.0,
		"grid_pos": Vector2(0, 0)
	},
	"yellow_berry": {
		"name": "Желтая ягода",
		"desc": "Сладкая и питательная. Восстанавливает голод.",
		"max_stack": 99,
		"hunger_restore": 25.0,
		"grid_pos": Vector2(0, 0)
	},
"""

content = content.replace('"wood": {', new_items + '\n\t"wood": {')

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
