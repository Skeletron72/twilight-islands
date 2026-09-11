import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# Restore the correct inner/outer mappings that work with 2x2 blocks!
old_map = """				# Внешние углы (Теперь используем тайлы внутренних углов пустоты!)
				if f_n and f_w: tile = Vector2i(4, 3)
				elif f_n and f_e: tile = Vector2i(5, 3)
				elif f_s and f_w: tile = Vector2i(4, 4)
				elif f_s and f_e: tile = Vector2i(5, 4)
				
				# Прямые края
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы (Поменяли местами по диагонали!)
				elif f_nw: tile = Vector2i(6, 2)
				elif f_ne: tile = Vector2i(4, 2)
				elif f_sw: tile = Vector2i(6, 0)
				elif f_se: tile = Vector2i(4, 0)"""

new_map = """				# Внешние углы (Правильный маппинг для 2x2 блоков, темная сторона наружу)
				if f_n and f_w: tile = Vector2i(6, 2)
				elif f_n and f_e: tile = Vector2i(4, 2)
				elif f_s and f_w: tile = Vector2i(6, 0)
				elif f_s and f_e: tile = Vector2i(4, 0)
				
				# Прямые края
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы (впадины в скале)
				elif f_nw: tile = Vector2i(4, 3)
				elif f_ne: tile = Vector2i(5, 3)
				elif f_sw: tile = Vector2i(4, 4)
				elif f_se: tile = Vector2i(5, 4)"""

content = content.replace(old_map, new_map)

# Fix the corridor carving to be 4 tiles wide (even width) so it doesn't break the 2x grid
old_carve = """	# Пробиваем идеальный коридор 5 шириной и 12 длиной наверх от спавна, чтобы там гарантированно стоял саппорт!
	for dy in range(-12, 0):
		for dx in range(-2, 3):
			grid[cx + dx][cy + dy] = 0
	
	# Делаем переход плавным (чтобы не было острых углов в 1 тайл)
	# Расширяем края коридора у основания и на вершине до четных значений
	for dx in range(-3, 4):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0"""

new_carve = """	# Пробиваем коридор ровно 4 шириной (чтобы не ломать 2x2 сетку), а саппорт (5 тайлов) будет красиво врезаться в стены по 0.5 тайла!
	for dy in range(-12, 0):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
	
	# Плавный переход краев
	for dx in range(-3, 3):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0"""

content = content.replace(old_carve, new_carve)

# Also fix the vertical wall logic for the inner corners!
old_vert = """					# Inner corners (swapped)
					# f_se -> (5,4) (Inner BR). It has a small south face on the left.
					if f_se and not f_s:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
					elif f_sw and not f_s:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)"""

new_vert = """					# Inner corners
					if f_se and not f_s:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
					elif f_sw and not f_s:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)"""

content = content.replace(old_vert, new_vert)

# Support position should shift by -8px because the corridor is 4 tiles wide (even) instead of 5
content = content.replace("support.global_position = _tile_to_world(support_pos) # Центрируем по тайлу cx", "support.global_position = _tile_to_world(support_pos) + Vector2(-8, 0) # Сдвигаем на полтайла влево, так как коридор четный (4)")

with open(file_path, "w") as f:
    f.write(content)
