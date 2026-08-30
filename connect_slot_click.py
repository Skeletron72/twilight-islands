import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_inst = """	# Setup Inventory Grid
	inventory_grid.columns = 5
	char_inv_grid.columns = 5
	for i in range(10):
		var slot = InventorySlotScene.instantiate()
		inventory_grid.add_child(slot)
		slot.set_slot_index(i)
		
		var char_slot = InventorySlotScene.instantiate()
		char_inv_grid.add_child(char_slot)
		char_slot.set_slot_index(i)"""

new_inst = """	# Setup Inventory Grid
	inventory_grid.columns = 5
	char_inv_grid.columns = 5
	for i in range(10):
		var slot = InventorySlotScene.instantiate()
		inventory_grid.add_child(slot)
		slot.set_slot_index(i)
		slot.item_clicked.connect(_show_item_details)
		
		var char_slot = InventorySlotScene.instantiate()
		char_inv_grid.add_child(char_slot)
		char_slot.set_slot_index(i)
		# For character tab, clicking currently equips it (from previous logic)
		char_slot.item_clicked.connect(func(id):
			InventoryManager.equip(id)
			_refresh_character_tab()
		)"""

content = content.replace(old_inst, new_inst)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
