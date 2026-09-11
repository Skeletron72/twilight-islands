import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# 1. Floor randomness
old_floor_const = "const TILE_FLOOR = Vector2i(1, 4)"
new_floor_const = "const TILE_FLOORS = [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(1, 3)]"
content = content.replace(old_floor_const, new_floor_const)

old_floor_set = "floor_layer.set_cell(Vector2i(x, y), SOURCE_FLOOR, TILE_FLOOR)"
new_floor_set = "floor_layer.set_cell(Vector2i(x, y), SOURCE_FLOOR, TILE_FLOORS[randi() % TILE_FLOORS.size()])"
content = content.replace(old_floor_set, new_floor_set)

# 2. Swap inner and outer corners
old_inner_tl = "const TILE_INNER_TL = Vector2i(4, 0)"
new_inner_tl = "const TILE_INNER_TL = Vector2i(4, 3)"
content = content.replace(old_inner_tl, new_inner_tl)

old_inner_tr = "const TILE_INNER_TR = Vector2i(6, 0)"
new_inner_tr = "const TILE_INNER_TR = Vector2i(5, 3)"
content = content.replace(old_inner_tr, new_inner_tr)

old_inner_bl = "const TILE_INNER_BL = Vector2i(4, 2)"
new_inner_bl = "const TILE_INNER_BL = Vector2i(4, 4)"
content = content.replace(old_inner_bl, new_inner_bl)

old_inner_br = "const TILE_INNER_BR = Vector2i(6, 2)"
new_inner_br = "const TILE_INNER_BR = Vector2i(5, 4)"
content = content.replace(old_inner_br, new_inner_br)

old_outer_tl = "const TILE_OUTER_TL = Vector2i(4, 3)"
new_outer_tl = "const TILE_OUTER_TL = Vector2i(4, 0)"
content = content.replace(old_outer_tl, new_outer_tl)

old_outer_tr = "const TILE_OUTER_TR = Vector2i(5, 3)"
new_outer_tr = "const TILE_OUTER_TR = Vector2i(6, 0)"
content = content.replace(old_outer_tr, new_outer_tr)

old_outer_bl = "const TILE_OUTER_BL = Vector2i(4, 4)"
new_outer_bl = "const TILE_OUTER_BL = Vector2i(4, 2)"
content = content.replace(old_outer_bl, new_outer_bl)

old_outer_br = "const TILE_OUTER_BR = Vector2i(5, 4)"
new_outer_br = "const TILE_OUTER_BR = Vector2i(6, 2)"
content = content.replace(old_outer_br, new_outer_br)

# 3. Solid walls background logic
old_solid_logic = """				# Only draw if it's a border or solid background
				if is_border or (not is_border and randf() < 0.1): # optimization: don't draw invisible solid walls
					wall_layer.set_cell(Vector2i(x, y), SOURCE_WALLS, tile)"""
new_solid_logic = """				# Only draw border walls, skip the background void completely
				if is_border:
					wall_layer.set_cell(Vector2i(x, y), SOURCE_WALLS, tile)
					
				# If we are the NORTH wall (looking at us), we need to draw the bottom half of the wall below us!
				if tile == TILE_WALL_TOP:
					# Draw the bottom part of the tall wall on the cell below us (which is a floor cell)
					# wall_layer will draw ON TOP of the floor layer!
					wall_layer.set_cell(Vector2i(x, y + 1), SOURCE_WALLS, Vector2i(1, 7))
"""
content = content.replace(old_solid_logic, new_solid_logic)

with open(file_path, "w") as f:
    f.write(content)
print("Dungeon generator patched!")
