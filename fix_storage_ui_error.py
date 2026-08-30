import re

with open('scripts/components/storage_ui.gd', 'r') as f:
    content = f.read()

old_logic = """func _transfer_to_player(item_id: String) -> void:
	if not current_chest.inventory.has(item_id): return
	
	if InventoryManager.add_item(item_id, 1):
		current_chest.inventory[item_id] -= 1
		if current_chest.inventory[item_id] <= 0:
			current_chest.inventory.erase(item_id)
		_refresh_ui()"""

new_logic = """func _transfer_to_player(item_id: String) -> void:
	if not current_chest.inventory.has(item_id): return
	
	InventoryManager.add_item(item_id, 1)
	current_chest.inventory[item_id] -= 1
	if current_chest.inventory[item_id] <= 0:
		current_chest.inventory.erase(item_id)
	_refresh_ui()"""

content = content.replace(old_logic, new_logic)

with open('scripts/components/storage_ui.gd', 'w') as f:
    f.write(content)
