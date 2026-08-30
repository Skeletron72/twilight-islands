import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_interact = """		if current_target is Destructible or current_target is EnemySkeleton:
			if GameStateManager.consume_stamina(15.0):
				is_acting = true
				if current_target is EnemySkeleton:
					_play_anim("attack")
				elif current_target.get("resource_id") == "wood":
					_play_anim("axe")
				else:
					_play_anim("mining")
			else:
				# Cannot swing due to no stamina
				pass"""
					
new_interact = """		if current_target is Destructible or current_target is EnemySkeleton:
			var has_tool = false
			
			if current_target is EnemySkeleton:
				if InventoryManager.get_item_amount("stone_sword") > 0:
					has_tool = true
			elif current_target.get("resource_id") == "wood":
				if InventoryManager.get_item_amount("stone_axe") > 0 or InventoryManager.get_item_amount("wooden_axe") > 0:
					has_tool = true
			else:
				if InventoryManager.get_item_amount("stone_pickaxe") > 0 or InventoryManager.get_item_amount("wooden_pickaxe") > 0:
					has_tool = true
					
			if not has_tool:
				print("Необходим инструмент для этого действия!")
				return
				
			if GameStateManager.consume_stamina(15.0):
				is_acting = true
				if current_target is EnemySkeleton:
					_play_anim("attack")
				elif current_target.get("resource_id") == "wood":
					_play_anim("axe")
				else:
					_play_anim("mining")
			else:
				# Cannot swing due to no stamina
				pass"""
					
content = content.replace(old_interact, new_interact)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
