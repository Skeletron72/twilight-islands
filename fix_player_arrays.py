import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_code = """	var interactables = interaction_area.get_overlapping_areas()
	interactables.append_array(interaction_area.get_overlapping_bodies())
	var closest_target = null"""

new_code = """	var interactables: Array[Node2D] = []
	for a in interaction_area.get_overlapping_areas(): interactables.append(a)
	for b in interaction_area.get_overlapping_bodies(): interactables.append(b)
	var closest_target = null"""

content = content.replace(old_code, new_code)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
