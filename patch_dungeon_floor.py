import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_floor = """	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				# Для пола берем случайный тайл с учетом координат, чтобы "булыжники" стыковались если это паттерн
				# Но так как паттерна нет, просто рандом
				floor_layer.set_cell(Vector2i(x, y), SOURCE_FLOOR, floor_options[randi() % 4])
			elif grid[x][y] == 1:"""

new_floor = """	var floor_cells: Array[Vector2i] = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				floor_cells.append(Vector2i(x, y))
			elif grid[x][y] == 1:"""

content = content.replace(old_floor, new_floor)

# Now add set_cells_terrain_connect after the loop
old_create = "_create_boundary_walls_from_grid(boundary_body, grid, w, h)"
new_create = """
	# Заливаем пол через Godot Terrains (Match Sides), как просил пользователь!
	# Предполагается, что пол настроен в terrain_set_1, terrain 2 (или другой, если 2 занят)
	if not floor_cells.is_empty():
		floor_layer.set_cells_terrain_connect(floor_cells, 1, 2)
		
	_create_boundary_walls_from_grid(boundary_body, grid, w, h)
"""
content = content.replace(old_create, new_create)

with open(file_path, "w") as f:
    f.write(content)
