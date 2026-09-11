import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# 1. Swap Inner corners (concave corners of the rock)
old_inner = """				# Внутренние углы (Теперь используем тайлы внешних углов пустоты!)
				elif f_nw: tile = Vector2i(4, 0)
				elif f_ne: tile = Vector2i(6, 0)
				elif f_sw: tile = Vector2i(4, 2)
				elif f_se: tile = Vector2i(6, 2)"""

# Swapping diagonally
new_inner = """				# Внутренние углы (Поменяли местами по диагонали!)
				elif f_nw: tile = Vector2i(6, 2)
				elif f_ne: tile = Vector2i(4, 2)
				elif f_sw: tile = Vector2i(6, 0)
				elif f_se: tile = Vector2i(4, 0)"""

content = content.replace(old_inner, new_inner)

# 2. Fix collisions and prevent stones on vertical walls
# We need to collect tiles that are covered by the vertical wall so we don't spawn stones there.
# And we need to add a collision shape for the vertical wall.
old_vert = """					wall_layer.set_cell(Vector2i(x, y+1), SOURCE_WALLS, face_top)
					wall_layer.set_cell(Vector2i(x, y+2), SOURCE_WALLS, face_bot)"""

new_vert = """					wall_layer.set_cell(Vector2i(x, y+1), SOURCE_WALLS, face_top)
					wall_layer.set_cell(Vector2i(x, y+2), SOURCE_WALLS, face_bot)
					
					# Добавляем клетки в список "скрытых", чтобы там не спавнились камни
					covered_by_wall.append(Vector2i(x, y+1))
					covered_by_wall.append(Vector2i(x, y+2))
					
					# Создаем коллизию для вертикальной стены (на нижнем тайле y+2)
					var col = CollisionShape2D.new()
					var shape = RectangleShape2D.new()
					shape.size = Vector2(16, 16)
					col.shape = shape
					col.position = _tile_to_world(Vector2i(x, y+2))
					boundary_body.add_child(col)"""

# We need to define covered_by_wall at the top of the function
old_valid = "	var valid_floor_cells = []"
new_valid = "	var covered_by_wall = []\n	var valid_floor_cells = []"

content = content.replace(old_valid, new_valid)
content = content.replace(old_vert, new_vert)

# Remove covered from valid_floor_cells
old_loop = """	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				valid_floor_cells.append(Vector2i(x, y))"""

new_loop = """	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				if not Vector2i(x, y) in covered_by_wall:
					valid_floor_cells.append(Vector2i(x, y))"""

content = content.replace(old_loop, new_loop)


with open(file_path, "w") as f:
    f.write(content)
