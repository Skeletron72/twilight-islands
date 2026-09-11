import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# We will add a post-processing step after the 2x scale:
# Scan for places where we can carve a 5-wide tunnel.
# Or simpler: find a 4-wide vertical corridor and widen it to 5!

old_scale = """	for x in range(w):
		for y in range(h):
			grid[x][y] = s_grid[x / 2][y / 2]

	var cx = w / 2"""

new_scale = """	for x in range(w):
		for y in range(h):
			grid[x][y] = s_grid[x / 2][y / 2]
			
	# Carve a 5-tile wide vertical corridor to place the support
	var support_placed = false
	var support_pos = Vector2i(-1, -1)
	
	for y in range(6, h - 6):
		if support_placed: break
		for x in range(6, w - 10):
			# Look for a vertical 4-tile wide corridor
			var is_4_corridor = true
			for dy in range(4):
				if grid[x][y+dy] != 1 or grid[x+1][y+dy] != 0 or grid[x+2][y+dy] != 0 or grid[x+3][y+dy] != 0 or grid[x+4][y+dy] != 0 or grid[x+5][y+dy] != 1:
					is_4_corridor = false
					break
			
			if is_4_corridor:
				# Widen it to 5 tiles by making x+5 floor as well, for a length of 6 tiles
				for dy in range(-1, 5):
					grid[x+5][y+dy] = 0
				support_placed = true
				support_pos = Vector2i(x+1, y)
				break

	var cx = w / 2"""

content = content.replace(old_scale, new_scale)

# Now add the support object
old_ladder = """	var ladder_up = SCENE_LADDER_UP.instantiate()"""
new_ladder = """	if support_pos != Vector2i(-1, -1):
		var support = preload("res://scenes/objects/dungeon/cave_support.tscn").instantiate()
		support.global_position = _tile_to_world(support_pos) + Vector2(-8, 8) # Align to grid
		interactables.add_child(support)

	var ladder_up = SCENE_LADDER_UP.instantiate()"""

content = content.replace(old_ladder, new_ladder)

with open(file_path, "w") as f:
    f.write(content)
