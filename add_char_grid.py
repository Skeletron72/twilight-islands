import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

setup_inv = """	# Setup Inventory Grid
	inventory_grid.columns = 5
	for i in range(10):
		var slot = InventorySlotScene.instantiate()
		inventory_grid.add_child(slot)
		slot.set_slot_index(i)"""

setup_both = """	# Setup Inventory Grid
	inventory_grid.columns = 5
	char_inv_grid.columns = 5
	for i in range(10):
		var slot = InventorySlotScene.instantiate()
		inventory_grid.add_child(slot)
		slot.set_slot_index(i)
		
		var char_slot = InventorySlotScene.instantiate()
		char_inv_grid.add_child(char_slot)
		char_slot.set_slot_index(i)"""

content = content.replace(setup_inv, setup_both)

callback_inv = """func _on_ui_slots_changed(idx: int) -> void:
	if inventory_grid.get_child_count() > idx:
		var slot = inventory_grid.get_child(idx)
		if slot.has_method("_refresh"):
			slot._refresh()"""

callback_both = """func _on_ui_slots_changed(idx: int) -> void:
	if inventory_grid.get_child_count() > idx:
		var slot = inventory_grid.get_child(idx)
		if slot.has_method("_refresh"):
			slot._refresh()
	if char_inv_grid.get_child_count() > idx:
		var char_slot = char_inv_grid.get_child(idx)
		if char_slot.has_method("_refresh"):
			char_slot._refresh()"""

content = content.replace(callback_inv, callback_both)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
