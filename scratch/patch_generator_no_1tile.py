with open("scripts/components/dungeon_generator.gd", "r") as f:
    content = f.read()

# 1. In s_grid, carve entrance room in half resolution
old_s_grid_part = """	# 3. Соединяем коридор от входа (swall_y) до южного зала
	for y in range(swall_y, entrance_chamber_y, -1):
		s_grid[scx][y] = 0
		s_grid[scx][y - 1] = 0"""

new_s_grid_part = """	# 3. Соединяем коридор от входа (swall_y) до южного зала
	for y in range(swall_y, entrance_chamber_y, -1):
		s_grid[scx][y] = 0
		s_grid[scx][y - 1] = 0
		
	# Формируем органичный первый входной зал в малом разрешении
	# (Благодаря генерации в s_grid после увеличения x2 ВСЕ стены и выступы будут МИНИМУМ 2 тайла!)
	var ec_x = scx
	var ec_y = swall_y + 2
	var er_x = randi_range(3, 5)
	var er_y = randi_range(2, 3)
	for x in range(1, sw - 1):
		for y in range(swall_y + 1, sh - 1):
			var dx = float(x - ec_x) / float(er_x)
			var dy = float(y - ec_y) / float(er_y)
			var dist = dx * dx + dy * dy
			var noise = (sin(x * 1.5) + cos(y * 1.8)) * 0.2
			if dist + noise < 1.05:
				s_grid[x][y] = 0
				
	# Гарантируем свободный проход перед выходом и коридором в малом разрешении
	for x in range(scx - 3, scx + 2):
		for y in range(swall_y + 1, min(sh - 1, swall_y + 3)):
			s_grid[x][y] = 0"""

assert old_s_grid_part in content, "old_s_grid_part not found!"
content = content.replace(old_s_grid_part, new_s_grid_part)

# 2. In full grid, remove the old per-tile loop and add the sanitization pass
old_grid_part = """	# 6. Геометрия входной комнаты и южной стены:
	# Формируем первый зал органичной природной формы (с шумом и неровными краями, а не коробкой)
	var ec_x = cx - 1
	var ec_y = wall_y + 4
	var er_x = randi_range(7, 10)
	var er_y = randi_range(4, 6)
	for x in range(cx - er_x - 3, cx + er_x + 4):
		for y in range(wall_y + 1, min(h - 2, wall_y + er_y * 2 + 3)):
			if x >= 1 and x < w - 1 and y >= 1 and y < h - 1:
				var dx = float(x - ec_x) / float(er_x)
				var dy = float(y - ec_y) / float(er_y)
				var dist = dx * dx + dy * dy
				var noise = (sin(x * 1.4) + cos(y * 1.6)) * 0.22
				if dist + noise < 1.05:
					grid[x][y] = 0

	# Гарантируем свободный проход перед выходом (cx - 5..cx - 3) и саппортом (cx - 2..cx + 2)
	for x in range(cx - 6, cx + 3):
		for y in range(wall_y + 1, wall_y + 4):
			if x >= 1 and x < w - 1 and y >= 1 and y < h - 1:
				grid[x][y] = 0
				
	# Непрерывная горизонтальная южная стена
	for dy in range(-3, 1):
		var wy = wall_y + dy
		for x in range(max(1, cx - 12), cx - 1):
			grid[x][wy] = 1
		for x in range(cx + 2, min(w - 1, cx + 13)):
			grid[x][wy] = 1
			
	# Ровный коридор шириной ровно 3 тайла (cx - 1, cx, cx + 1)
	for dy in range(-8, 1):
		var wy = wall_y + dy
		if wy >= 1:
			grid[cx - 1][wy] = 0
			grid[cx][wy] = 0
			grid[cx + 1][wy] = 0
			grid[cx - 2][wy] = 1
			grid[cx - 3][wy] = 1
			grid[cx + 2][wy] = 1
			grid[cx + 3][wy] = 1
			
	# Плавный выход из коридора в залы пещеры
	for dx in range(-3, 4):
		for dy in range(-2, 1):
			var jx = cx + dx
			var jy = wall_y - 8 + dy
			if jx >= 1 and jx < w - 1 and jy >= 1:
				grid[jx][jy] = 0"""

new_grid_part = """	# 6. Четкая геометрия южной стены и коридора:
	# Сплошная ровная горизонтальная южная стена
	for dy in range(-3, 1):
		var wy = wall_y + dy
		for x in range(max(1, cx - 12), cx - 1):
			grid[x][wy] = 1
		for x in range(cx + 2, min(w - 1, cx + 13)):
			grid[x][wy] = 1
			
	# Ровный коридор шириной ровно 3 тайла (cx - 1, cx, cx + 1)
	for dy in range(-8, 1):
		var wy = wall_y + dy
		if wy >= 1:
			grid[cx - 1][wy] = 0
			grid[cx][wy] = 0
			grid[cx + 1][wy] = 0
			grid[cx - 2][wy] = 1
			grid[cx - 3][wy] = 1
			grid[cx + 2][wy] = 1
			grid[cx + 3][wy] = 1
			
	# Плавный выход из коридора в залы пещеры
	for dx in range(-3, 4):
		for dy in range(-2, 1):
			var jx = cx + dx
			var jy = wall_y - 8 + dy
			if jx >= 1 and jx < w - 1 and jy >= 1:
				grid[jx][jy] = 0

	# Гарантия свободного пространства перед выходом и саппортом
	for x in range(cx - 6, cx + 3):
		for y in range(wall_y + 1, wall_y + 4):
			if x >= 1 and x < w - 1 and y >= 1 and y < h - 1:
				grid[x][y] = 0
				
	# САНИТИЗАЦИЯ ГЕОМЕТРИИ (СТРОГО МИНИМУМ 2 ТАЙЛА ДЛЯ ВСЕХ СТЕН И ВЫСТУПОВ):
	# Удаляем любые одиночные выступы, зубья и тонкие перемычки в 1 тайл,
	# чтобы автотайлинг углов никогда не ломался
	for p in range(2):
		for x in range(1, w - 1):
			for y in range(1, h - 1):
				if grid[x][y] == 1:
					# Если стена толщиной всего в 1 тайл между двумя клетками пола
					if grid[x - 1][y] == 0 and grid[x + 1][y] == 0:
						grid[x][y] = 0
					elif grid[x][y - 1] == 0 and grid[x][y + 1] == 0:
						grid[x][y] = 0
				elif grid[x][y] == 0:
					# Одиночные щели пола в 1 тайл (кроме коридора)
					if (x < cx - 2 or x > cx + 2) or y < wall_y - 8:
						if grid[x - 1][y] == 1 and grid[x + 1][y] == 1:
							grid[x][y] = 1
						elif grid[x][y - 1] == 1 and grid[x][y + 1] == 1:
							grid[x][y] = 1"""

assert old_grid_part in content, "old_grid_part not found!"
content = content.replace(old_grid_part, new_grid_part)

with open("scripts/components/dungeon_generator.gd", "w") as f:
    f.write(content)

print("Updated dungeon_generator.gd with 2-tile minimum guarantee!")
