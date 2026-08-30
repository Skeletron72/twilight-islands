import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_func = """func _update_auto_target() -> void:
	var areas = interaction_area.get_overlapping_areas()
	var closest_target: Area2D = null
	var closest_dist: float = INF
	
	for area in areas:
		if area.has_method("interact"):
			var dist = global_position.distance_to(area.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_target = area"""

new_func = """func _update_auto_target() -> void:
	var interactables = interaction_area.get_overlapping_areas()
	interactables.append_array(interaction_area.get_overlapping_bodies())
	var closest_target = null
	var closest_dist: float = INF
	
	for node in interactables:
		if node == self: continue
		if node.has_method("interact"):
			var dist = global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_target = node"""

content = content.replace(old_func, new_func)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
