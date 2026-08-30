import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

old_campfire = """	"campfire": {
		"name": "Костер",
		"desc": "Согревает и освещает в ночи. Можно готовить.",
		"max_stack": 10,
		"placeable": true,
		"scene": "res://scenes/objects/campfire.tscn",
		"custom_atlas": "res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png",
		"custom_region": Rect2(592, 336, 32, 32)
	},"""

new_campfire = """	"campfire": {
		"name": "Костер",
		"desc": "Согревает и освещает в ночи. Можно готовить.",
		"max_stack": 10,
		"placeable": true,
		"scene": "res://scenes/objects/campfire.tscn",
		"grid_pos": Vector2(2, 32)
	},"""

old_box = """	"storage_box": {
		"name": "Деревянный сундук",
		"desc": "Для хранения ваших вещей.",
		"max_stack": 5,
		"placeable": true,
		"scene": "res://scenes/objects/storage_box.tscn",
		"custom_atlas": "res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png",
		"custom_region": Rect2(560, 160, 16, 16)
	}"""

new_box = """	"storage_box": {
		"name": "Деревянный сундук",
		"desc": "Для хранения ваших вещей.",
		"max_stack": 5,
		"placeable": true,
		"scene": "res://scenes/objects/storage_box.tscn",
		"grid_pos": Vector2(4, 32)
	}"""

content = content.replace(old_campfire, new_campfire)
content = content.replace(old_box, new_box)

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
