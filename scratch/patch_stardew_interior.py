import sys

with open("scripts/components/dungeon_generator.gd", "r") as f:
    content = f.read()

target = '''	# 2. Заполняем шумом верхнюю область пещеры (до южной стены)
	for x in range(2, sw - 2):
		for y in range(2, swall_y - 2):
			if randf() > 0.44:
				s_grid[x][y] = 0
				
	# 3. Сглаживаем клеточным автоматом
	for i in range(4):
		var new_s = s_grid.duplicate(true)
		for x in range(1, sw - 1):
			for y in range(1, swall_y - 2):
				var walls = 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if s_grid[x + dx][y + dy] == 1:
							walls += 1
				if walls >= 5:
					new_s[x][y] = 1
				elif walls <= 3:
					new_s[x][y] = 0
		s_grid = new_s

	# 4. Пробиваем коридор из входа прямо на север ВНУТРЬ ПЕЩЕРЫ, пока не встретим открытый пол!
	var connected_y = 2
	for y in range(swall_y, 2, -1):
		s_grid[scx][y] = 0
		s_grid[scx][y - 1] = 0
		# Если мы поднялись выше входа и наткнулись на открытую полость пещеры
		if y < swall_y - 2 and (s_grid[scx - 1][y] == 0 or s_grid[scx + 1][y] == 0 or s_grid[scx][y - 1] == 0):
			connected_y = y
			break
			
	# Расчищаем перекресток в месте стыка коридора с пещерой, чтобы не было узких тупиков
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if connected_y + dy >= 1:
				s_grid[scx + dx][connected_y + dy] = 0'''

replacement = '''	# 2. Генерация просторных природных пещер в стиле Stardew Valley:
	# Разделяем пещеру на секторы, чтобы залы равномерно и органично заполнили всю площадь
	var cave_min_y = 2
	var cave_max_y = swall_y - 2
	var cols = 3 if sw >= 40 else 2
	var rows = 2
	var chambers: Array = []
	
	var sec_w = int((sw - 4) / cols)
	var sec_h = int((cave_max_y - cave_min_y) / rows)
	
	for c in range(cols):
		for r in range(rows):
			var min_x = 2 + c * sec_w + 2
			var max_x = 2 + (c + 1) * sec_w - 2
			var min_y = cave_min_y + r * sec_h + 1
			var max_y = cave_min_y + (r + 1) * sec_h - 1
			
			if min_x < max_x and min_y < max_y:
				var cx = randi_range(min_x, max_x)
				var cy = randi_range(min_y, max_y)
				var rx = randi_range(4, max(5, int(sec_w / 2)))
				var ry = randi_range(3, max(4, int(sec_h / 2)))
				chambers.append({"x": cx, "y": cy, "rx": rx, "ry": ry})
				
	# Гарантированный южный зал прямо перед входным коридором
	var entrance_chamber_y = swall_y - randi_range(3, 4)
	chambers.append({"x": scx, "y": entrance_chamber_y, "rx": randi_range(5, 7), "ry": randi_range(3, 4)})
	
	# Вырезаем залы органичными эллипсами с природным шумом по краям
	for ch in chambers:
		var ch_x: int = ch.x
		var ch_y: int = ch.y
		var ch_rx: float = float(ch.rx)
		var ch_ry: float = float(ch.ry)
		for x in range(max(1, ch_x - int(ch_rx) - 2), min(sw - 1, ch_x + int(ch_rx) + 3)):
			for y in range(max(1, ch_y - int(ch_ry) - 2), min(swall_y - 1, ch_y + int(ch_ry) + 3)):
				var dx = float(x - ch_x) / ch_rx
				var dy = float(y - ch_y) / ch_ry
				var dist = dx * dx + dy * dy
				var noise = (sin(x * 1.3) + cos(y * 1.5)) * 0.18
				if dist + noise < 1.05:
					s_grid[x][y] = 0

	# Соединяем залы широкими извилистыми природными туннелями
	for i in range(chambers.size()):
		var ch1 = chambers[i]
		var dists: Array = []
		for j in range(chambers.size()):
			if i != j:
				var ch2 = chambers[j]
				var d = (ch1.x - ch2.x) * (ch1.x - ch2.x) + (ch1.y - ch2.y) * (ch1.y - ch2.y)
				dists.append({"d": d, "j": j})
		dists.sort_custom(func(a, b): return a.d < b.d)
		
		# Соединяем с 2 ближайшими залами
		for k in range(min(2, dists.size())):
			var target_ch = chambers[dists[k].j]
			var cur_x = ch1.x
			var cur_y = ch1.y
			while cur_x != target_ch.x or cur_y != target_ch.y:
				# Ширина прохода в малом разрешении (после х2 будет от 4 до 6 тайлов)
				for bx in range(-1, 2):
					for by in range(-1, 2):
						var nx = cur_x + bx
						var ny = cur_y + by
						if nx >= 1 and nx < sw - 1 and ny >= 1 and ny < swall_y - 1:
							s_grid[nx][ny] = 0
				var diff_x = target_ch.x - cur_x
				var diff_y = target_ch.y - cur_y
				if abs(diff_x) > abs(diff_y):
					cur_x += 1 if diff_x > 0 else -1
					if randf() < 0.35 and diff_y != 0:
						cur_y += 1 if diff_y > 0 else -1
				else:
					cur_y += 1 if diff_y > 0 else -1
					if randf() < 0.35 and diff_x != 0:
						cur_x += 1 if diff_x > 0 else -1
				cur_x = clampi(cur_x, 2, sw - 3)
				cur_y = clampi(cur_y, 2, swall_y - 2)

	# В больших залах оставляем природные каменные колонны и островки (как в шахте Стардью)
	for ch in chambers:
		if ch.rx >= 5 and ch.ry >= 4 and randf() < 0.65:
			s_grid[ch.x][ch.y] = 1
			if randf() < 0.5 and ch.x + 1 < sw - 1:
				s_grid[ch.x + 1][ch.y] = 1

	# Сглаживание клеточным автоматом (2 прохода, чтобы скалы были округлыми и естественными)
	for p in range(2):
		var new_s = s_grid.duplicate(true)
		for x in range(1, sw - 1):
			for y in range(1, swall_y - 1):
				var walls = 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if s_grid[x + dx][y + dy] == 1:
							walls += 1
				if walls >= 6:
					new_s[x][y] = 1
				elif walls <= 2:
					new_s[x][y] = 0
		s_grid = new_s

	# 3. Соединяем коридор от входа (swall_y) до южного зала
	for y in range(swall_y, entrance_chamber_y, -1):
		s_grid[scx][y] = 0
		s_grid[scx][y - 1] = 0'''

assert target in content, "Target not found in content!"
content = content.replace(target, replacement)

with open("scripts/components/dungeon_generator.gd", "w") as f:
    f.write(content)

print("Successfully patched dungeon_generator.gd with Stardew Valley cave interior!")
