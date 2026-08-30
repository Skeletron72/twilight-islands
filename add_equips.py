import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

new_items = """	"cloth_basic": {
		"name": "Простая рубаха",
		"desc": "Удобная одежда для выживания.",
		"max_stack": 1,
		"equip_slot": "chest",
		"grid_pos": Vector2(6, 4) # Пример (поменяйте на свои)
	},
	"boots_basic": {
		"name": "Кожаные сапоги",
		"desc": "Защищают ноги от колючек.",
		"max_stack": 1,
		"equip_slot": "boots",
		"grid_pos": Vector2(5, 5) # Пример
	}
}"""

content = content.replace("}", new_items, 1)

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
