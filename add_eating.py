import re

with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

eat_logic = """		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			_set_active_slot(event.keycode - KEY_1)
			
	# Handle using/eating item on left click
	if event.is_action_pressed("left_click") and active_slot_index != -1:
		var item_id = InventoryManager.ui_slots[active_slot_index]
		if item_id != "":
			var item_data = ItemDB.get_item(item_id)
			if item_data.has("hunger_restore"):
				GameStateManager.add_hunger(item_data["hunger_restore"])
				InventoryManager.remove_item(item_id, 1)
				print("Съели ", item_data["name"])"""

content = content.replace("""		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			_set_active_slot(event.keycode - KEY_1)""", eat_logic)

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
