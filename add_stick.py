import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

# Add stick to ITEMS
new_item = """	"wood": {
		"name": "Древесина",
		"desc": "Свежее бревно, срубленное на острове.",
		"max_stack": 99,
		"grid_pos": Vector2(2, 2)
	},
	"stick": {
		"name": "Ветка",
		"desc": "Обычная деревянная палка. Полезна для крафта.",
		"max_stack": 99,
		"grid_pos": Vector2(14, 3)
	},"""

content = content.replace("""	"wood": {
		"name": "Древесина",
		"desc": "Свежее бревно, срубленное на острове.",
		"max_stack": 99,
		"grid_pos": Vector2(2, 2)
	},""", new_item)

# Update recipes to use stick instead of wood where appropriate
content = content.replace('"wooden_axe": {"wood": 5}', '"wooden_axe": {"wood": 2, "stick": 3}')
content = content.replace('"wooden_pickaxe": {"wood": 5}', '"wooden_pickaxe": {"wood": 2, "stick": 3}')
content = content.replace('"stone_axe": {"wood": 2, "stone": 3}', '"stone_axe": {"stick": 2, "stone": 3}')
content = content.replace('"stone_pickaxe": {"wood": 2, "stone": 3}', '"stone_pickaxe": {"stick": 2, "stone": 3}')

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
