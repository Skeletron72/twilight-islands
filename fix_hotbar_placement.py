with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

old_set = """	if active_slot_index != -1:
		_animate_slot_selection(active_slot_index, true)"""

new_set = """	if active_slot_index != -1:
		_animate_slot_selection(active_slot_index, true)
		
		# Check if placeable
		var item_id = InventoryManager.ui_slots[active_slot_index]
		if item_id != "":
			var item_data = ItemDB.get_item(item_id)
			if item_data.get("placeable", false):
				PlacementManager.start_placement(item_id)
			else:
				PlacementManager.stop_placement()
		else:
			PlacementManager.stop_placement()
	else:
		PlacementManager.stop_placement()"""

content = content.replace(old_set, new_set)

# Also stop placement if inventory changes and we lose the item
old_slots_changed = """func _on_ui_slots_changed(idx: int) -> void:
	if idx < 4:
		_update_slot_visual(idx, idx == active_slot_index)"""

new_slots_changed = """func _on_ui_slots_changed(idx: int) -> void:
	if idx < 4:
		_update_slot_visual(idx, idx == active_slot_index)
		
		if idx == active_slot_index and PlacementManager.is_placing:
			var item_id = InventoryManager.ui_slots[idx]
			if item_id != PlacementManager.current_item_id or InventoryManager.get_item_amount(item_id) <= 0:
				PlacementManager.stop_placement()
				if item_id == "" or InventoryManager.get_item_amount(item_id) <= 0:
					_set_active_slot(idx) # toggle off if ran out"""

content = content.replace(old_slots_changed, new_slots_changed)

# Wait, `_set_active_slot(idx)` toggles off if it's already selected.
# If idx == active_slot_index, _set_active_slot(idx) will toggle it off!

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
