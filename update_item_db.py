import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

# Update recipes
old_recipes = """	"wooden_axe": {"wood": 2, "stick": 3},
	"wooden_pickaxe": {"wood": 2, "stick": 3},
	"stone_axe": {"stick": 2, "stone": 3},
	"stone_pickaxe": {"stick": 2, "stone": 3},
	"cloth_basic": {"wood": 10} # Пример"""

new_recipes = """	"wooden_axe": {"wood": 2, "stick": 3},
	"wooden_pickaxe": {"wood": 2, "stick": 3},
	"stone_axe": {"stick": 2, "stone": 1},
	"stone_pickaxe": {"stick": 2, "stone": 1},
	"stone_sword": {"stick": 1, "stone": 2},
	"cloth_basic": {"wood": 10}"""

content = content.replace(old_recipes, new_recipes)

# Add stone_sword to items
old_pick = """	"stone_pickaxe": {
		"name": "Каменная кирка",
		"desc": "Надежный инструмент шахтера.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 4,
		"efficiency": 2,
		"durability": 120,
		"grid_pos": Vector2(2, 9)
	}"""
	
new_pick = """	"stone_pickaxe": {
		"name": "Каменная кирка",
		"desc": "Надежный инструмент шахтера.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 4,
		"efficiency": 2,
		"durability": 120,
		"grid_pos": Vector2(2, 9)
	},
	"stone_sword": {
		"name": "Каменный меч",
		"desc": "Идеально для сражений со скелетами.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 8,
		"durability": 150,
		"grid_pos": Vector2(2, 7)
	}"""
	
content = content.replace(old_pick, new_pick)

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
