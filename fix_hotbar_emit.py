import re

with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

old_consume = """			if consumed:
				InventoryManager.remove_item(item_id, 1)
				print("Съели ", item_data["name"])"""

new_consume = """			if consumed:
				InventoryManager.remove_item(item_id, 1)
				var p_color = item_data.get("particle_color", Color.WHITE)
				GameStateManager.item_consumed.emit(p_color)
				print("Съели ", item_data["name"])"""

content = content.replace(old_consume, new_consume)

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
