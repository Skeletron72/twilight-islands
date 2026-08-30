import re

with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

old_consume = """			if item_data.has("hunger_restore"):
				GameStateManager.add_hunger(item_data["hunger_restore"])
				InventoryManager.remove_item(item_id, 1)
				print("Съели ", item_data["name"])"""

new_consume = """			var consumed = false
			if item_data.has("hunger_restore"):
				GameStateManager.add_hunger(item_data["hunger_restore"])
				consumed = true
			if item_data.has("health_restore"):
				GameStateManager.heal(item_data["health_restore"])
				consumed = true
			if item_data.has("stamina_restore"):
				GameStateManager.add_stamina(item_data["stamina_restore"])
				consumed = true
				
			if consumed:
				InventoryManager.remove_item(item_id, 1)
				print("Съели ", item_data["name"])"""

content = content.replace(old_consume, new_consume)

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
