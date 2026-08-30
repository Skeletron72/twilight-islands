import re

with open('scripts/components/inventory_slot.gd', 'r') as f:
    content = f.read()

# Add signal
content = content.replace('extends Control\n', 'extends Control\n\nsignal item_clicked(item_id: String)\n')

# Add _gui_input
gui_input = """
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if slot_index >= 0 and slot_index < InventoryManager.ui_slots.size():
			var item_id = InventoryManager.ui_slots[slot_index]
			if item_id != "":
				item_clicked.emit(item_id)
"""
content = content + gui_input

with open('scripts/components/inventory_slot.gd', 'w') as f:
    f.write(content)
