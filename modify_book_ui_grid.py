import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Load slot scene
slot_preload = """const InventorySlotScene = preload("res://scenes/ui/inventory_slot.tscn")\n\n@export var closed_book_tex"""
content = content.replace('@export var closed_book_tex', slot_preload)

# In _ready, instance 10 slots
old_ready = """func _ready() -> void:
	hide()
	
	# Connect tab buttons"""

new_ready = """func _ready() -> void:
	hide()
	
	# Setup Inventory Grid
	inventory_grid.columns = 5
	for i in range(10):
		var slot = InventorySlotScene.instantiate()
		inventory_grid.add_child(slot)
		slot.set_slot_index(i)
		
	# Listen to UI slot changes
	InventoryManager.ui_slots_changed.connect(_on_ui_slots_changed)
	
	# Connect tab buttons"""
content = content.replace(old_ready, new_ready)

# Add callback
callback = """func _on_ui_slots_changed(idx: int) -> void:
	if inventory_grid.get_child_count() > idx:
		var slot = inventory_grid.get_child(idx)
		if slot.has_method("_refresh"):
			slot._refresh()
"""
content = content + "\n" + callback

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
