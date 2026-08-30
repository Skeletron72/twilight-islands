with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

new_recipes = """	"stone_sword": {"stick": 1, "stone": 2},
	"cloth_basic": {"wood": 10},
	"campfire": {"wood": 5, "stone": 3},
	"storage_box": {"wood": 10}"""
content = content.replace('"cloth_basic": {"wood": 10}', new_recipes)

new_items = """	"stone_sword": {
		"name": "Каменный меч",
		"desc": "Идеально для сражений со скелетами.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 8,
		"durability": 150,
		"grid_pos": Vector2(2, 7)
	},
	"campfire": {
		"name": "Костер",
		"desc": "Согревает и освещает в ночи. Можно готовить.",
		"max_stack": 10,
		"placeable": true,
		"scene": "res://scenes/objects/campfire.tscn",
		"grid_pos": Vector2(9, 20)
	},
	"storage_box": {
		"name": "Деревянный сундук",
		"desc": "Для хранения ваших вещей.",
		"max_stack": 5,
		"placeable": true,
		"scene": "res://scenes/objects/storage_box.tscn",
		"grid_pos": Vector2(8, 20)
	}"""
content = content.replace('"stone_sword": {\n\t\t"name": "Каменный меч",\n\t\t"desc": "Идеально для сражений со скелетами.",\n\t\t"max_stack": 1,\n\t\t"equip_slot": "tool",\n\t\t"damage": 8,\n\t\t"durability": 150,\n\t\t"grid_pos": Vector2(2, 7)\n\t}', new_items)

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
