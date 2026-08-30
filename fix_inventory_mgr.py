import re

with open('scripts/autoloads/inventory_manager.gd', 'r') as f:
    content = f.read()

# Add ui_slots array and signals
add_code = """# UI Slot Mapping (10 slots)
var ui_slots: Array = ["", "", "", "", "", "", "", "", "", ""]
signal ui_slots_changed(index: int)"""
content = content.replace('# Safe inventory', add_code + '\n\n# Safe inventory')

# Hook into inventory_changed to populate empty slots
hook_code = """func _update_ui_slots(item_id: String, new_amount: int) -> void:
	if new_amount > 0:
		# If it's already in a slot, do nothing
		if ui_slots.has(item_id): return
		# Find empty slot
		for i in range(10):
			if ui_slots[i] == "":
				ui_slots[i] = item_id
				ui_slots_changed.emit(i)
				return
	else:
		# Item removed completely, clear its slot
		for i in range(10):
			if ui_slots[i] == item_id:
				ui_slots[i] = ""
				ui_slots_changed.emit(i)
				return"""

content = content + "\n" + hook_code

# Call the hook inside inventory_changed.emit
content = content.replace('inventory_changed.emit(item_id, get_item_amount(item_id))', 
                          '_update_ui_slots(item_id, get_item_amount(item_id))\n\tinventory_changed.emit(item_id, get_item_amount(item_id))')

# We need a function to swap slots
swap_code = """\nfunc swap_ui_slots(idx1: int, idx2: int) -> void:
	if idx1 < 0 or idx1 >= 10 or idx2 < 0 or idx2 >= 10: return
	var temp = ui_slots[idx1]
	ui_slots[idx1] = ui_slots[idx2]
	ui_slots[idx2] = temp
	ui_slots_changed.emit(idx1)
	ui_slots_changed.emit(idx2)
"""
content = content + swap_code

with open('scripts/autoloads/inventory_manager.gd', 'w') as f:
    f.write(content)
