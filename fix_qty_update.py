import re

with open('scripts/autoloads/inventory_manager.gd', 'r') as f:
    content = f.read()

old_logic = """	if new_amount > 0:
		# If it's already in a slot, do nothing
		if ui_slots.has(item_id): return
		# Find empty slot"""

new_logic = """	if new_amount > 0:
		# If it's already in a slot, just emit update for amount label
		if ui_slots.has(item_id):
			ui_slots_changed.emit(ui_slots.find(item_id))
			return
		# Find empty slot"""
content = content.replace(old_logic, new_logic)

with open('scripts/autoloads/inventory_manager.gd', 'w') as f:
    f.write(content)
