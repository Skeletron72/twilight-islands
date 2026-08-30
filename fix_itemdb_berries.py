import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

# Replace red berry
old_red = """	"red_berry": {
		"name": "Красная ягода",
		"desc": "Вкусная и сочная. Восстанавливает голод.",
		"max_stack": 99,
		"hunger_restore": 15.0,
		"grid_pos": Vector2(13, 3)
	},"""

new_red = """	"red_berry": {
		"name": "Рубиновая ягода",
		"desc": "Сочная ягода. Отлично утоляет голод и немного лечит.",
		"max_stack": 99,
		"hunger_restore": 20.0,
		"health_restore": 15.0,
		"grid_pos": Vector2(13, 3)
	},"""

# Replace yellow berry
old_yellow = """	"yellow_berry": {
		"name": "Желтая ягода",
		"desc": "Сладкая и питательная. Восстанавливает голод.",
		"max_stack": 99,
		"hunger_restore": 25.0,
		"grid_pos": Vector2(12, 3)
	},"""

new_yellow = """	"yellow_berry": {
		"name": "Золотистая ягода",
		"desc": "Терпкая ягода. Слегка утоляет голод и бодрит.",
		"max_stack": 99,
		"hunger_restore": 10.0,
		"stamina_restore": 25.0,
		"grid_pos": Vector2(12, 3)
	},"""

content = content.replace(old_red, new_red)
content = content.replace(old_yellow, new_yellow)

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
