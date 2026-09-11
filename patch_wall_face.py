import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_carve = """	for dx in range(-3, 4):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0
			
	# Пробиваем коридор ровно 4 шириной (чтобы не ломать 2x2 сетку), а саппорт (5 тайлов) будет красиво врезаться в стены по 0.5 тайла!
	for dy in range(-12, 0):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
		# Гарантируем, что по бокам от коридора есть толстые стены (минимум 2 тайла), чтобы они не удалились сглаживанием!
		grid[cx - 3][cy + dy] = 1
		grid[cx - 4][cy + dy] = 1
		grid[cx + 2][cy + dy] = 1
		grid[cx + 3][cy + dy] = 1
			
	# Плавный переход краев
	for dx in range(-3, 3):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0"""

new_carve = """	# Расчищаем зону спавна
	for dx in range(-4, 5):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0
			
	# Создаем массивную стену на севере от спавна, чтобы гарантированно образовать ЮЖНЫЙ фасад скалы!
	for dx in range(-6, 6):
		for dy in range(-7, -4):
			grid[cx + dx][cy + dy] = 1
			
	# Пробиваем ровный коридор на север через эту стену
	for dy in range(-12, -3):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
		# Гарантируем толщину боковых стен коридора
		grid[cx - 3][cy + dy] = 1
		grid[cx - 4][cy + dy] = 1
		grid[cx + 2][cy + dy] = 1
		grid[cx + 3][cy + dy] = 1
			
	# Плавный переход краев в дальнем конце коридора
	for dx in range(-3, 3):
		grid[cx + dx][cy - 12] = 0"""

content = content.replace(old_carve, new_carve)

old_support = """	if support_pos != Vector2i(-1, -1):
		var support = preload("res://scenes/objects/dungeon/cave_support.tscn").instantiate()
		support.global_position = _tile_to_world(support_pos) + Vector2(-8, 0) # Сдвигаем на полтайла влево, так как коридор четный (4)"""

new_support = """	# Саппорт ставится ровно у основания южного фасада скалы (y = cy - 3)
	var support_pos = Vector2i(cx, cy - 3)
	if support_pos != Vector2i(-1, -1):
		var support = preload("res://scenes/objects/dungeon/cave_support.tscn").instantiate()
		# Сдвигаем X на -8 (т.к. ширина коридора 4 тайла, центр смещен)
		# Сдвигаем Y на +8 (чтобы origin был на нижнем крае тайла, совпадая с физической базой скалы)
		support.global_position = _tile_to_world(support_pos) + Vector2(-8, 8)"""

content = content.replace("	var support_pos = Vector2i(cx, cy - 8)\n", "")
content = content.replace(old_support, new_support)

with open(file_path, "w") as f:
    f.write(content)
