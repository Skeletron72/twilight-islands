import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_end = """	# Саппорт ставится ровно у основания южного фасада скалы (y = cy - 3)
	var support_pos = Vector2i(cx, cy - 3)

	var floor_cells: Array[Vector2i] = []"""

new_end = """	# Саппорт ставится ровно у основания южного фасада скалы (y = cy - 3)
	var support_pos = Vector2i(cx, cy - 3)
	
	if support_pos != Vector2i(-1, -1):
		var support = preload("res://scenes/objects/dungeon/cave_support.tscn").instantiate()
		# Сдвигаем X на -8 (т.к. ширина коридора 4 тайла, центр смещен)
		# Сдвигаем Y на +8 (чтобы origin был на нижнем крае тайла, совпадая с физической базой скалы)
		support.global_position = _tile_to_world(support_pos) + Vector2(-8, 8)
		interactables.add_child(support)

	var floor_cells: Array[Vector2i] = []"""

content = content.replace(old_end, new_end)

with open(file_path, "w") as f:
    f.write(content)
