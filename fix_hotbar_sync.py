import re

with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

# Replace hotbar_items usage with InventoryManager.ui_slots
# Remove hotbar_items array
content = re.sub(r'var hotbar_items: Array = \["", "", "", ""\]\n', '', content)

# _update_slot_visual
content = content.replace('var item_id = hotbar_items[index]', 'var item_id = InventoryManager.ui_slots[index]')

# Active item retrieval if any (not implemented yet, but good practice)
# We don't have get_active_item yet, but let's replace all hotbar_items
content = content.replace('hotbar_items[i]', 'InventoryManager.ui_slots[i]')
content = content.replace('hotbar_items.has', 'InventoryManager.ui_slots.has')

# Now for _auto_populate_hotbar!
# We don't need this anymore! Because ui_slots is managed by InventoryManager globally!
# Wait, if we want tools to go into the hotbar automatically, InventoryManager ALREADY puts new items in the first available slot!
# Which means new items naturally go into slots 0-3 first anyway!
# So _auto_populate_hotbar is completely redundant and can cause conflicts!
# Let's delete it!
content = re.sub(r'func _auto_populate_hotbar\(\) -> void:.*?# ---', '# ---', content, flags=re.DOTALL)

# Let's also remove _on_inventory_changed because we should listen to ui_slots_changed!
content = re.sub(r'func _on_inventory_changed.*?func _input', 'func _input', content, flags=re.DOTALL)

# In _ready, connect to ui_slots_changed instead of inventory_changed
old_ready = """func _ready() -> void:
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	_auto_populate_hotbar()
	
	for i in range(4):
		_update_slot_visual(i, i == active_slot_index)"""
new_ready = """func _ready() -> void:
	InventoryManager.ui_slots_changed.connect(_on_ui_slots_changed)
	
	for i in range(4):
		_update_slot_visual(i, i == active_slot_index)

func _on_ui_slots_changed(idx: int) -> void:
	if idx < 4:
		_update_slot_visual(idx, idx == active_slot_index)
"""
content = content.replace(old_ready, new_ready)

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
