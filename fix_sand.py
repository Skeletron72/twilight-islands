import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# I will inject the sand check right after checking if on_ground
old_check = """	var on_ground = (ground.get_cell_source_id(map_pos) != -1)
	var on_mountain = (mountains_tops and mountains_tops.get_cell_source_id(map_pos) != -1)
	
	if not on_ground and not on_mountain:
		return false
		
	return true"""

new_check = """	var on_ground = (ground.get_cell_source_id(map_pos) != -1)
	var on_mountain = (mountains_tops and mountains_tops.get_cell_source_id(map_pos) != -1)
	
	if not on_ground and not on_mountain:
		return false
		
	if on_ground:
		var coords = ground.get_cell_atlas_coords(map_pos)
		# Черный список координат песка (X, Y)
		if coords == Vector2i(5, 1) or coords == Vector2i(7, 1) or coords == Vector2i(8, 1) or coords == Vector2i(9, 1):
			return false
			
	return true"""

content = content.replace(old_check, new_check)

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
