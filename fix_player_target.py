import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_loop = """	var closest_target = null
	var closest_dist = 9999.0
	
	if not is_acting and not is_dead:
		for area in interaction_area.get_overlapping_areas():
			var dist = global_position.distance_to(area.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_target = area"""

new_loop = """	var closest_target = null
	var closest_dist = 9999.0
	
	if not is_acting and not is_dead:
		var interactables = interaction_area.get_overlapping_areas()
		interactables.append_array(interaction_area.get_overlapping_bodies())
		for node in interactables:
			if node == self: continue
			var dist = global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_target = node"""

content = content.replace(old_loop, new_loop)

# Also update the type hint on current_target
content = content.replace('var current_target: Area2D = null', 'var current_target: Node2D = null')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
