import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Update _update_auto_target to allow EnemySkeleton as well
# Wait, player's auto_target checks: `if area is Interactable:`
# But I removed `class_name Interactable` from some things maybe? No, `Interactable` is a class.
# Did I add `class_name EnemySkeleton`? Yes.
# So I should change it to `if area.has_method("interact"):` which is much safer and polymorphic!
old_target = """	for area in areas:
		if area is Interactable:
			var dist = global_position.distance_to(area.global_position)"""
new_target = """	for area in areas:
		if area.has_method("interact"):
			var dist = global_position.distance_to(area.global_position)"""
			
content = content.replace(old_target, new_target)

# Update _try_interact
old_interact = """		if current_target is Destructible:
			if GameStateManager.consume_stamina(15.0):
				is_acting = true
				if current_target.resource_id == "wood":
					_play_anim("axe")
				else:
					_play_anim("mining")
			else:
				# Cannot swing due to no stamina
				pass
		else:
			# Instant interact (like Boat)
			current_target.interact(self)"""

new_interact = """		if current_target is Destructible or current_target is EnemySkeleton:
			if GameStateManager.consume_stamina(15.0):
				is_acting = true
				if current_target is EnemySkeleton:
					_play_anim("axe") # Use axe for combat for now
				elif current_target.resource_id == "wood":
					_play_anim("axe")
				else:
					_play_anim("mining")
			else:
				# Cannot swing due to no stamina
				pass
		else:
			# Instant interact (like Boat)
			current_target.interact(self)"""

content = content.replace(old_interact, new_interact)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
