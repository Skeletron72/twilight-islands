import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_carve = """	# Пробиваем ровный коридор на север через эту стену
	for dy in range(-12, -3):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
		# Гарантируем толщину боковых стен коридора
		grid[cx - 3][cy + dy] = 1
		grid[cx - 4][cy + dy] = 1
		grid[cx + 2][cy + dy] = 1
		grid[cx + 3][cy + dy] = 1"""

new_carve = """	# Пробиваем ровный коридор на север через эту стену
	for dy in range(-12, -3):
		# ИСКЛЮЧЕНИЕ: Для коридора с саппортом делаем ширину ровно 3 тайла (-1, 0, 1),
		# чтобы ножки саппорта идеально совпали со стенами по краям!
		for dx in range(-1, 2):
			grid[cx + dx][cy + dy] = 0
		# Гарантируем толщину боковых стен коридора
		grid[cx - 2][cy + dy] = 1
		grid[cx - 3][cy + dy] = 1
		grid[cx + 2][cy + dy] = 1
		grid[cx + 3][cy + dy] = 1"""

content = content.replace(old_carve, new_carve)

old_support = """		# Сдвигаем X на -8 (т.к. ширина коридора 4 тайла, центр смещен)
		# Сдвигаем Y на +8 (чтобы origin был на нижнем крае тайла, совпадая с физической базой скалы)
		support.global_position = _tile_to_world(support_pos) + Vector2(-8, 8)"""

new_support = """		# Так как коридор теперь 3 тайла (нечетный), он идеально центрирован по тайлу cx!
		# Сдвигаем Y на +8 (чтобы origin был на нижнем крае тайла, совпадая с физической базой скалы)
		support.global_position = _tile_to_world(support_pos) + Vector2(0, 8)"""

content = content.replace(old_support, new_support)

with open(file_path, "w") as f:
    f.write(content)
