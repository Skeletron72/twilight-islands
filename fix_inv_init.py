import re

with open('scripts/autoloads/inventory_manager.gd', 'r') as f:
    content = f.read()

init_code = """func _ready() -> void:
	# Populate UI slots with existing items on startup
	for item_id in inventory.keys():
		_update_ui_slots(item_id, inventory[item_id])
"""

content = content.replace('func add_item', init_code + '\nfunc add_item')

with open('scripts/autoloads/inventory_manager.gd', 'w') as f:
    f.write(content)
