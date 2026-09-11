import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_draw = """	if not floor_cells.is_empty():
		floor_layer.set_cells_terrain_connect(floor_cells, 1, 2)"""

new_draw = """	if not floor_cells.is_empty():
		var terrain_id = 2 if (floor_num % 2 == 1) else 3 # Нечетные этажи = пол 1 (ID 2), Четные = пол 2 (ID 3)
		if randf() < 0.2: terrain_id = (3 if terrain_id == 2 else 2) # Немного рандома
		floor_layer.set_cells_terrain_connect(floor_cells, 1, terrain_id)"""

content = content.replace(old_draw, new_draw)

with open(file_path, "w") as f:
    f.write(content)
