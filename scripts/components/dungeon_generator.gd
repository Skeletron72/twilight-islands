extends RefCounted
class_name DungeonGenerator

const SOURCE_WALLS: int = 25
const SOURCE_FLOOR: int = 32
const SOURCE_CAVE_WATER: int = 23
const SOURCE_CAVE_WATER_STILL: int = 30

const SCENE_CAVE_DOORWAY = preload("res://scenes/objects/dungeon/cave_doorway.tscn")
const SCENE_WALL_LADDER = preload("res://scenes/objects/dungeon/wall_ladder.tscn")
const SCENE_LADDER_DOWN = preload("res://scenes/objects/dungeon/ladder_down.tscn")
const SCENE_CAVE_SUPPORT = preload("res://scenes/objects/dungeon/cave_support.tscn")
const SCENE_CAVE_WALL_SUPPORT = preload("res://scenes/objects/dungeon/cave_wall_support.tscn")
const SCENE_CAVE_LANTERN = preload("res://scenes/objects/dungeon/cave_lantern.tscn")
const SCENE_CAVE_STALAGMITE = preload("res://scenes/objects/dungeon/cave_stalagmite.tscn")
const SCENE_CAVE_ORE_ROCK = preload("res://scenes/objects/dungeon/cave_ore_rock.tscn")
const SCENE_SKELETON = preload("res://scenes/characters/skeleton.tscn")
const SCENE_SLIME = preload("res://scenes/characters/slime.tscn")

const CAVE_STONES = [
	preload("res://scenes/objects/dungeon/cave_rock_1.tscn"),
	preload("res://scenes/objects/dungeon/cave_rock_2.tscn"),
	preload("res://scenes/objects/dungeon/cave_rock_3.tscn"),
	preload("res://scenes/objects/dungeon/cave_rock_4.tscn")
]

func generate(
	floor_num: int,
	floor_layer: TileMapLayer,
	wall_layer: TileMapLayer,
	boundary_body: StaticBody2D,
	interactables: Node2D,
	player: Node2D,
	water_layer: TileMapLayer = null
) -> void:
	
	var d_seed = DungeonManager.get_or_create_dungeon_seed() if DungeonManager else 12345
	seed(d_seed + floor_num * 1000)

	if water_layer == null and floor_layer and floor_layer.get_parent():
		water_layer = floor_layer.get_parent().get_node_or_null("WaterLayer") as TileMapLayer

	floor_layer.clear()
	wall_layer.clear()
	if water_layer:
		water_layer.clear()
	for child in boundary_body.get_children():
		child.queue_free()
	for child in interactables.get_children():
		child.queue_free()

	# Компактные и удобные этажи (быстро исследуются, легко найти спуск)
	var base_w = randi_range(22, 34) # w будет от 44 до 68
	var base_h = int(base_w * 0.75)  # h будет от 33 до 51
	
	var w: int = base_w * 2
	var h: int = base_h * 2
	var sw = base_w
	var sh = base_h
	
	# 1. Сетка малого разрешения для естественной пещеры
	var s_grid: Array = []
	for x in range(sw):
		var col = []
		col.resize(sh)
		col.fill(1)
		s_grid.append(col)
		
	var scx = sw / 2
	var swall_y = sh - 5 # Позиция южной стены в малом разрешении
	
	# 2. Генерация просторных природных пещер в стиле Stardew Valley:
	var cave_min_y = 2
	var cave_max_y = swall_y - 2
	var cols = 3 if sw >= 30 else 2
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
				var cx_pos = randi_range(min_x, max_x)
				var cy_pos = randi_range(min_y, max_y)
				var rx = randi_range(3, max(4, int(sec_w / 2)))
				var ry = randi_range(3, max(3, int(sec_h / 2)))
				chambers.append({"x": cx_pos, "y": cy_pos, "rx": rx, "ry": ry})
				
	# Гарантированный южный зал прямо перед входным коридором
	var entrance_chamber_y = swall_y - randi_range(3, 4)
	var entrance_chamber = {"x": scx, "y": entrance_chamber_y, "rx": randi_range(4, 6), "ry": randi_range(3, 4)}
	chambers.append(entrance_chamber)
	
	# На 1 этаже озеро создается 100% для тестов, на остальных этажах — с вероятностью ~20%
	var has_lake: bool = (floor_num == 1) or (randf() < 0.20)
	var lake_chamber = null
	if has_lake:
		if floor_num == 1:
			# На 1 этаже озеро должно быть легко находимым: выбираем ближайший к входу зал
			var candidates = []
			for ch in chambers:
				if ch != entrance_chamber:
					var d = Vector2(ch.x, ch.y).distance_squared_to(Vector2(scx, entrance_chamber_y))
					candidates.append({"ch": ch, "d": d})
			candidates.sort_custom(func(a, b): return a.d < b.d)
			if candidates.size() > 0:
				lake_chamber = candidates[0].ch
		else:
			# На остальных этажах выбираем один из просторных залов
			var candidates = chambers.filter(func(ch): return ch != entrance_chamber)
			candidates.sort_custom(func(a, b): return (a.rx * a.ry) > (b.rx * b.ry))
			if candidates.size() > 0:
				lake_chamber = candidates[0]
				
		if lake_chamber:
			lake_chamber.rx = max(lake_chamber.rx, 5)
			lake_chamber.ry = max(lake_chamber.ry, 4)
	
	# Вырезаем залы органичными эллипсами с шумом
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

		# Если это зал с озером, гарантируем ровную площадку без зазубрин в центре
		if ch == lake_chamber:
			for dx in range(-2, 3):
				for dy in range(-2, 3):
					var cx = ch_x + dx
					var cy = ch_y + dy
					if cx >= 2 and cx < sw - 2 and cy >= 2 and cy < swall_y - 1:
						s_grid[cx][cy] = 0

	# Соединяем залы широкими извилистыми туннелями
	for i in range(chambers.size()):
		var ch1 = chambers[i]
		var dists: Array = []
		for j in range(chambers.size()):
			if i != j:
				var ch2 = chambers[j]
				var d = (ch1.x - ch2.x) * (ch1.x - ch2.x) + (ch1.y - ch2.y) * (ch1.y - ch2.y)
				dists.append({"d": d, "j": j})
		dists.sort_custom(func(a, b): return a.d < b.d)
		
		for k in range(min(2, dists.size())):
			var target_ch = chambers[dists[k].j]
			var cur_x = ch1.x
			var cur_y = ch1.y
			while cur_x != target_ch.x or cur_y != target_ch.y:
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


	# Сглаживание клеточным автоматом (2 прохода)
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
			s_grid[x][y] = 0

	# 3.5. Размещение природных колонн и островков в залах пещеры
	for ch in chambers:
		# Пропускаем входной зал перед коридором и зал с озером
		if ch.y >= swall_y - 4 and abs(ch.x - scx) <= 3:
			continue
		if ch == lake_chamber:
			continue
		
		# Форма островка: single (1x1 в s_grid -> 2x2 в grid: 32x32px), horizontal (2x1 -> 4x2: 64x32px), vertical (1x2 -> 2x4: 32x64px)
		var shape_type = "single"
		if ch.rx >= 5 and randf() < 0.5:
			shape_type = "horizontal"
		elif ch.ry >= 4 and randf() < 0.4:
			shape_type = "vertical"
			
		var cells: Array[Vector2i] = [Vector2i(ch.x, ch.y)]
		if shape_type == "horizontal":
			cells.append(Vector2i(ch.x + 1, ch.y))
		elif shape_type == "vertical":
			cells.append(Vector2i(ch.x, ch.y + 1))
			
		# Проверяем свободное пространство вокруг островка:
		# Вокруг всех клеток островка должен быть минимум 1 тайл пола во все стороны (в grid это минимум 2 тайла!),
		# а к югу минимум 2 тайла пола (в grid это 4 тайла: 2 для вертикального фасада скалы + 2 для прохода игрока)
		var valid = true
		for c_pos in cells:
			for dx in range(-1, 2):
				for dy in range(-1, 3):
					var nx = c_pos.x + dx
					var ny = c_pos.y + dy
					if nx < 1 or nx >= sw - 1 or ny < 1 or ny >= swall_y - 1:
						valid = false
						break
					if s_grid[nx][ny] != 0:
						valid = false
						break
				if not valid: break
			if not valid: break
			
		if valid:
			for c_pos in cells:
				s_grid[c_pos.x][c_pos.y] = 1

	# 4. Flood-fill от входа для гарантии 100% связности
	var visited: Array = []
	for x in range(sw):
		var col = []
		col.resize(sh)
		col.fill(false)
		visited.append(col)
		
	var queue: Array[Vector2i] = [Vector2i(scx, swall_y)]
	visited[scx][swall_y] = true
	
	while queue.size() > 0:
		var curr = queue.pop_front()
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if abs(dx) == abs(dy): continue
				var nx = curr.x + dx
				var ny = curr.y + dy
				if nx >= 0 and nx < sw and ny >= 0 and ny < sh:
					if s_grid[nx][ny] == 0 and not visited[nx][ny]:
						visited[nx][ny] = true
						queue.append(Vector2i(nx, ny))
						
	for x in range(sw):
		for y in range(sh):
			if s_grid[x][y] == 0 and not visited[x][y]:
				s_grid[x][y] = 1
				
	# 5. Увеличиваем в 2 раза (ИДЕАЛЬНАЯ ГЕОМЕТРИЯ)
	var grid: Array = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1)
		grid.append(col)
		
	for x in range(w):
		for y in range(h):
			grid[x][y] = s_grid[x / 2][y / 2]
			
	var cx = scx * 2
	var wall_y = swall_y * 2
	
	# 6. Четкая геометрия южной стены и коридора:
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
							grid[x][y] = 1

	# 7. Рисуем пол (Terrain)
	var floor_cells: Array[Vector2i] = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				floor_cells.append(Vector2i(x, y))

	if not floor_cells.is_empty():
		var terrain_id = 2 if (floor_num % 2 == 1) else 3
		if randf() < 0.2: terrain_id = (3 if terrain_id == 2 else 2)
		floor_layer.set_cells_terrain_connect(floor_cells, 1, terrain_id)

	# 8. Рисуем стены
	var covered_by_wall: Array[Vector2i] = []
	var padding = 20
	for x in range(-padding, w + padding):
		for y in range(-padding, h + padding):
			var is_wall = true
			if x >= 0 and x < w and y >= 0 and y < h:
				is_wall = (grid[x][y] == 1)
				
			if is_wall:
				var get_g = func(gx, gy): return grid[gx][gy] if gx >= 0 and gx < w and gy >= 0 and gy < h else 1
				
				var f_n = get_g.call(x, y-1) == 0
				var f_s = get_g.call(x, y+1) == 0
				var f_w = get_g.call(x-1, y) == 0
				var f_e = get_g.call(x+1, y) == 0
				
				var f_nw = get_g.call(x-1, y-1) == 0
				var f_ne = get_g.call(x+1, y-1) == 0
				var f_sw = get_g.call(x-1, y+1) == 0
				var f_se = get_g.call(x+1, y+1) == 0
				
				var tile = Vector2i(-1, -1)
				
				# Внешние углы (ИНВЕРТИРОВАННЫЙ МАППИНГ + ПОМЕНЯННЫЕ МЕСТАМИ ВНЕШНИЕ И ВНУТРЕННИЕ - ЗАФИКСИРОВАНО)
				if f_n and f_w: tile = Vector2i(4, 3)
				elif f_n and f_e: tile = Vector2i(5, 3)
				elif f_s and f_w: tile = Vector2i(4, 4)
				elif f_s and f_e: tile = Vector2i(5, 4)
				
				# Прямые края (Светлая часть к полу, темная внутрь скалы - ЗАФИКСИРОВАНО)
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы (Инвертированные + ПОМЕНЯННЫЕ МЕСТАМИ - ЗАФИКСИРОВАНО)
				elif f_nw: tile = Vector2i(6, 2)
				elif f_ne: tile = Vector2i(4, 2)
				elif f_sw: tile = Vector2i(6, 0)
				elif f_se: tile = Vector2i(4, 0)
				else:
					if x >= 0 and x < w and y >= 0 and y < h:
						tile = Vector2i(5, 1) # Сплошная каменная текстура в центре колонн/островков
				
				if tile != Vector2i(-1, -1):
					wall_layer.set_cell(Vector2i(x, y), SOURCE_WALLS, tile)
					
				# ВЕРТИКАЛЬНЫЕ СТЕНЫ (фасад скалы): рисуем ТОЛЬКО если с юга пол!
				if f_s:
					var face_top = Vector2i(1, 6)
					var face_bot = Vector2i(1, 7)
					
					if f_e:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
					elif f_w:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)
						
					wall_layer.set_cell(Vector2i(x, y + 1), SOURCE_WALLS, face_top)
					wall_layer.set_cell(Vector2i(x, y + 2), SOURCE_WALLS, face_bot)
					
					covered_by_wall.append(Vector2i(x, y + 1))
					covered_by_wall.append(Vector2i(x, y + 2))
					
					var col_top = CollisionShape2D.new()
					var shape_top = RectangleShape2D.new()
					shape_top.size = Vector2(16, 16)
					col_top.shape = shape_top
					col_top.position = _tile_to_world(Vector2i(x, y + 1))
					boundary_body.add_child(col_top)

					var col_bot = CollisionShape2D.new()
					var shape_bot = RectangleShape2D.new()
					shape_bot.size = Vector2(16, 16)
					col_bot.shape = shape_bot
					col_bot.position = _tile_to_world(Vector2i(x, y + 2))
					boundary_body.add_child(col_bot)

	_create_boundary_walls_from_grid(boundary_body, grid, w, h)

	# 9. Размещение объектов
	var spawn_tile = Vector2i(cx - 4, wall_y + 3)
	
	var covered_dict = {}
	for c in covered_by_wall:
		covered_dict[c] = true

	# 8.5. Генерация подземных пещерных озер (Cave_Water_Animation.png)
	var water_cells_dict = {}
	var lake_island_cells = {}
	var best_lake_rect: Rect2i = Rect2i()
	var best_lake_center: Vector2i = Vector2i.ZERO
	
	if water_layer:
		water_layer.clear()
		
		if has_lake and lake_chamber:
			# Генерируем органичную природную форму озера из блоков 2х2 тайла (гарантия ширины >= 2 тайлов)
			var coarse_cells: Array[Vector2i] = [
				Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)
			]
			# Возможные естественные заливы/выступы (соединяются ребром, сохраняя ширину >= 2 тайла)
			var possible_ext = [
				Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, 1), Vector2i(2, 1),
				Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)
			]
			possible_ext.shuffle()
			var num_ext = randi_range(1, 3)
			var added = 0
			for cand in possible_ext:
				if added >= num_ext: break
				var is_conn = false
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					if (cand + d) in coarse_cells:
						is_conn = true
						break
				if is_conn:
					coarse_cells.append(cand)
					added += 1

			# Вычисляем границы формы в координатах coarse
			var min_cx = 999; var max_cx = -999; var min_cy = 999; var max_cy = -999
			for c in coarse_cells:
				min_cx = min(min_cx, c.x); max_cx = max(max_cx, c.x)
				min_cy = min(min_cy, c.y); max_cy = max(max_cy, c.y)
			var coarse_w = max_cx - min_cx + 1
			var coarse_h = max_cy - min_cy + 1
			var lw = coarse_w * 2
			var lh = coarse_h * 2
			
			var local_lake_cells: Array[Vector2i] = []
			for c in coarse_cells:
				for dx in range(2):
					for dy in range(2):
						local_lake_cells.append(Vector2i((c.x - min_cx) * 2 + dx, (c.y - min_cy) * 2 + dy))

			var lcx = lake_chamber.x * 2
			var lcy = lake_chamber.y * 2
			var best_origin: Vector2i = Vector2i(-1, -1)
			
			# 1. Ищем подходящую позицию в пределах целевого зала
			for off_y in [0, -1, 1, -2, 2, -3, 3]:
				for off_x in [0, -1, 1, -2, 2, -3, 3]:
					var ox = lcx - lw / 2 + off_x
					var oy = lcy - lh / 2 + off_y
					var fits = true
					for lp in local_lake_cells:
						for dy in range(-1, 2):
							for dx in range(-1, 2):
								var tx = ox + lp.x + dx
								var ty = oy + lp.y + dy
								if tx < 2 or tx >= w - 2 or ty < 2 or ty >= h - 2:
									fits = false; break
								if grid[tx][ty] != 0 or Vector2i(tx, ty) in covered_dict:
									fits = false; break
								if Vector2(tx, ty).distance_to(Vector2(spawn_tile)) < 8.0:
									fits = false; break
							if not fits: break
						if not fits: break
					if fits:
						best_origin = Vector2i(ox, oy)
						break
				if best_origin != Vector2i(-1, -1):
					break
			
			# 2. Если в выбранном зале не нашлось, проверяем другие залы
			if best_origin == Vector2i(-1, -1):
				for ch in chambers:
					if ch == entrance_chamber: continue
					var cx_cand = ch.x * 2
					var cy_cand = ch.y * 2
					for off_y in [0, -1, 1, -2, 2]:
						for off_x in [0, -1, 1, -2, 2]:
							var ox = cx_cand - lw / 2 + off_x
							var oy = cy_cand - lh / 2 + off_y
							var fits = true
							for lp in local_lake_cells:
								for dy in range(-1, 2):
									for dx in range(-1, 2):
										var tx = ox + lp.x + dx
										var ty = oy + lp.y + dy
										if tx < 2 or tx >= w - 2 or ty < 2 or ty >= h - 2:
											fits = false; break
										if grid[tx][ty] != 0 or Vector2i(tx, ty) in covered_dict:
											fits = false; break
										if Vector2(tx, ty).distance_to(Vector2(spawn_tile)) < 8.0:
											fits = false; break
									if not fits: break
								if not fits: break
							if fits:
								best_origin = Vector2i(ox, oy)
								break
						if best_origin != Vector2i(-1, -1): break
					if best_origin != Vector2i(-1, -1): break

			# 3. 100% ГАРАНТИЯ: если всё ещё не нашли место, расчищаем площадку под форму озера
			if best_origin == Vector2i(-1, -1):
				var ox = clampi(lcx - lw / 2, 3, w - lw - 4)
				var oy = clampi(lcy - lh / 2, 3, h - lh - 6)
				for lp in local_lake_cells:
					for dy in range(-1, 2):
						for dx in range(-1, 2):
							var tx = ox + lp.x + dx
							var ty = oy + lp.y + dy
							grid[tx][ty] = 0
							covered_dict.erase(Vector2i(tx, ty))
							wall_layer.erase_cell(Vector2i(tx, ty))
				best_origin = Vector2i(ox, oy)
					
			if best_origin != Vector2i(-1, -1):
				var lake_cells: Array[Vector2i] = []
				var sum_pos = Vector2.ZERO
				for lp in local_lake_cells:
					var cell = best_origin + lp
					lake_cells.append(cell)
					water_cells_dict[cell] = true
					sum_pos += Vector2(cell)
				
				best_lake_rect = Rect2i(best_origin.x, best_origin.y, lw, lh)
				best_lake_center = Vector2i(round(sum_pos.x / lake_cells.size()), round(sum_pos.y / lake_cells.size()))
				
				# Коллизия на глубокую воду (клетки, окруженные водой со всех 4 сторон)
				var water_set = {}
				for cell in lake_cells:
					water_set[cell] = true
				for cell in lake_cells:
					if water_set.has(cell + Vector2i(1, 0)) and water_set.has(cell + Vector2i(-1, 0)) and water_set.has(cell + Vector2i(0, 1)) and water_set.has(cell + Vector2i(0, -1)):
						var col = CollisionShape2D.new()
						var shape = RectangleShape2D.new()
						shape.size = Vector2(16, 16)
						col.shape = shape
						col.position = _tile_to_world(cell)
						boundary_body.add_child(col)

				# Генерируем органичное озеро через террейн игрока (Terrain 17: "ВодаПещера", terrain_set 0)
				water_layer.set_cells_terrain_connect(lake_cells, 0, 17)
				
				# 8.6. Добавляем берег (+1 к берегу) пещерного озера (Cave_Water_Animation.png, Source 23)
				# Координаты из анимации пещерной воды:
				# Слева от воды: (5, 2)
				# Справа от воды: (3, 2)
				# Сверху от воды: (4, 3)
				# Снизу от воды: (4, 1)
				var shore_cells = {}
				for cell in lake_cells:
					for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
						var n = cell + d
						if not water_set.has(n):
							shore_cells[n] = true
				
				for sc in shore_cells:
					water_layer.erase_cell(sc)
					var r = water_set.has(sc + Vector2i(1, 0)) # Вода справа -> берег слева
					var l = water_set.has(sc + Vector2i(-1, 0)) # Вода слева -> берег справа
					var b = water_set.has(sc + Vector2i(0, 1))  # Вода снизу -> берег сверху
					var t = water_set.has(sc + Vector2i(0, -1)) # Вода сверху -> берег снизу
					
					var tile: Vector2i
					if r and b:
						tile = Vector2i(5, 3) # Угол верх-лево
					elif l and b:
						tile = Vector2i(3, 3) # Угол верх-право
					elif r and t:
						tile = Vector2i(5, 1) # Угол низ-лево
					elif l and t:
						tile = Vector2i(3, 1) # Угол низ-право
					elif r:
						tile = Vector2i(5, 2) # Слева от воды (5, 2)
					elif l:
						tile = Vector2i(3, 2) # Справа от воды (3, 2)
					elif b:
						tile = Vector2i(4, 3) # Сверху от воды (4, 3)
					elif t:
						tile = Vector2i(4, 1) # Снизу от воды (4, 1)
					else:
						tile = Vector2i(4, 2)
					
					floor_layer.set_cell(sc, SOURCE_CAVE_WATER, tile)
					water_cells_dict[sc] = true
				
				# Мягкое плавное радиальное свечение (без ступенчатых артефактов и "плюсиков")
				var lake_light = PointLight2D.new()
				lake_light.name = "LakeLight"
				lake_light.color = Color(0.18, 0.48, 0.78, 0.65)
				lake_light.energy = 0.4
				
				var grad = Gradient.new()
				grad.colors = PackedColorArray([Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.2), Color(1, 1, 1, 0.0)])
				grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
				var grad_tex = GradientTexture2D.new()
				grad_tex.gradient = grad
				grad_tex.fill = GradientTexture2D.FILL_RADIAL
				grad_tex.fill_from = Vector2(0.5, 0.5)
				grad_tex.fill_to = Vector2(0.95, 0.5)
				grad_tex.width = 64
				grad_tex.height = 64
				lake_light.texture = grad_tex
				lake_light.scale = Vector2(max(3.0, float(lw) * 0.7), max(3.0, float(lh) * 0.7))
				lake_light.position = _tile_to_world(best_lake_center)
				interactables.add_child(lake_light)
				
				print("[DungeonGenerator] Floor %d: Generated organic cave water terrain (%d cells, bounds %dx%d) at center %s" % [
					floor_num, lake_cells.size(), lw, lh, str(best_lake_center)
				])

	var valid_floor_cells = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0 and not Vector2i(x, y) in covered_dict and not Vector2i(x, y) in water_cells_dict and not Vector2i(x, y) in lake_island_cells:
				valid_floor_cells.append(Vector2i(x, y))

	# Клетки пола с гарантированным отступом минимум в 1 тайл от любых стен, обрывов и воды
	var safe_floor_cells: Array[Vector2i] = []
	for cell in valid_floor_cells:
		var is_safe = true
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var nx = cell.x + dx
				var ny = cell.y + dy
				if nx < 0 or nx >= w or ny < 0 or ny >= h:
					is_safe = false
					break
				if grid[nx][ny] == 1 or Vector2i(nx, ny) in covered_dict or Vector2i(nx, ny) in water_cells_dict or Vector2i(nx, ny) in lake_island_cells:
					is_safe = false
					break
			if not is_safe:
				break
		if is_safe:
			safe_floor_cells.append(cell)

	var ladder_down_tile = spawn_tile
	var max_dist = 0.0
	# Предпочитаем размещать спуск на безопасном расстоянии от стен
	var ladder_candidates = safe_floor_cells if safe_floor_cells.size() > 0 else valid_floor_cells
	for cell in ladder_candidates:
		var d = Vector2(cell).distance_to(Vector2(spawn_tile))
		if d > max_dist:
			max_dist = d
			ladder_down_tile = cell

	# Саппорт ставится у основания южного фасада скалы (y = wall_y + 2, x = cx)
	var support_pos = Vector2i(cx, wall_y + 2)
	var support = SCENE_CAVE_SUPPORT.instantiate()
	support.global_position = _tile_to_world(support_pos) + Vector2(0, 8)
	interactables.add_child(support)

	# ВЫХОД НАВЕРХ / НА ПОВЕРХНОСТЬ (на южной стене):
	# На 1 этаже: каменный арочный выход Cave_Doorway_1 (первые 8 тайлов)
	# На этажах 2+: пристенная лестница Desert_Ladder
	if floor_num <= 1:
		var doorway = SCENE_CAVE_DOORWAY.instantiate()
		doorway.global_position = _tile_to_world(Vector2i(cx - 4, wall_y + 2)) + Vector2(-8, 8)
		interactables.add_child(doorway)
	else:
		var wall_ladder = SCENE_WALL_LADDER.instantiate()
		wall_ladder.global_position = _tile_to_world(Vector2i(cx - 4, wall_y + 2)) + Vector2(0, 8)
		interactables.add_child(wall_ladder)

	# СПУСК ВНИЗ: люк в полу Cave_Floor_Ladder (в дальнем зале)
	var ladder_down = SCENE_LADDER_DOWN.instantiate()
	ladder_down.global_position = _tile_to_world(ladder_down_tile)
	interactables.add_child(ladder_down)
	if DungeonManager:
		DungeonManager.floor_ladder_tiles[floor_num] = ladder_down_tile

	# Игрок появляется:
	# Если поднялся по лестнице с нижнего этажа — сразу у люка спуска (ladder_down_tile), а не у выхода
	# Если вошел с поверхности или спустился сверху — у выхода/лестницы на южной стене (spawn_tile)
	if player:
		if DungeonManager and DungeonManager.spawn_at_ladder_down:
			player.global_position = _tile_to_world(ladder_down_tile) + Vector2(0, 16)
			DungeonManager.spawn_at_ladder_down = false
		else:
			player.global_position = _tile_to_world(spawn_tile)
		
		var cam = player.get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.reset_smoothing()

	var reserved = {}
	# Зона вокруг точки спавна и выхода (радиус 1 тайл)
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			reserved[spawn_tile + Vector2i(dx, dy)] = true
			reserved[ladder_down_tile + Vector2i(dx, dy)] = true
			reserved[Vector2i(cx - 4 + dx, wall_y + 2 + dy)] = true
			reserved[Vector2i(cx + dx, wall_y + 2 + dy)] = true

	# Резервируем всю площадь воды и островков от спавна любых объектов
	for w_cell in water_cells_dict:
		reserved[w_cell] = true
	for isl_cell in lake_island_cells:
		reserved[isl_cell] = true
	if best_lake_rect.size != Vector2i.ZERO:
		for dy in range(-2, best_lake_rect.size.y + 3):
			for dx in range(-2, best_lake_rect.size.x + 3):
				reserved[Vector2i(best_lake_rect.position.x + dx, best_lake_rect.position.y + dy)] = true

	# 10. Декоративные опоры южных стен с масляными фонарями (Cave_Wall_Support.png)
	var wall_support_candidates: Array[Vector2i] = []
	for y in range(2, h - 3):
		for x in range(3, w - 3):
			# Опора имеет ширину 80px (5 тайлов: x-2 .. x+2) и высоту 32px (2 тайла: y+1, y+2)
			# Проверяем, что опора полностью умещается на фасаде южной стены
			var fits = true
			for dx in range(-2, 3):
				var tx = x + dx
				if tx < 0 or tx >= w or y + 3 >= h:
					fits = false
					break
				if not Vector2i(tx, y + 1) in covered_dict or not Vector2i(tx, y + 2) in covered_dict:
					fits = false
					break
				if grid[tx][y + 3] != 0 or Vector2i(tx, y + 3) in covered_dict:
					fits = false
					break
			if not fits: continue

			# Проверяем, чтобы под опорой и перед ней не было воды
			var over_water = false
			for dx in range(-3, 4):
				for dy in range(1, 4):
					if Vector2i(x + dx, y + dy) in water_cells_dict:
						over_water = true
						break
				if over_water: break
			if over_water: continue

			# Не спавним поверх стартовой зоны входа, саппорта и люка вниз
			if y == wall_y and abs(x - cx) < 8: continue
			if Vector2(x, y + 2).distance_to(Vector2(spawn_tile)) < 4.0: continue
			if Vector2(x, y + 2).distance_to(Vector2(ladder_down_tile)) < 4.0: continue

			wall_support_candidates.append(Vector2i(x, y))

	# Предпочитаем стены с запасом ширины (чтобы опора не обрывалась на углах)
	var wide_candidates: Array[Vector2i] = []
	for c in wall_support_candidates:
		if c.x - 3 >= 0 and c.x + 3 < w and grid[c.x - 3][c.y] == 1 and grid[c.x + 3][c.y] == 1:
			wide_candidates.append(c)
	var candidates_pool = wide_candidates if wide_candidates.size() > 0 else wall_support_candidates
	candidates_pool.shuffle()

	var placed_supports: Array[Vector2i] = []
	var target_supports_count = randi_range(2, 4)
	for cand in candidates_pool:
		var too_close = false
		for placed in placed_supports:
			if Vector2(cand).distance_to(Vector2(placed)) < 6.0:
				too_close = true
				break
		if too_close: continue

		placed_supports.append(cand)
		var wall_support = SCENE_CAVE_WALL_SUPPORT.instantiate()
		wall_support.global_position = _tile_to_world(Vector2i(cand.x, cand.y + 2)) + Vector2(0, 8)
		interactables.add_child(wall_support)

		# Резервируем пространство под опорой и перед фонарем от спавна камней
		for dx in range(-3, 4):
			for dy in range(1, 4):
				reserved[Vector2i(cand.x + dx, cand.y + dy)] = true

		if placed_supports.size() >= target_supports_count:
			break

	# 11. Настенные масляные светильники (Lantern.png) для мягкого освещения темных зон
	var lantern_candidates: Array[Vector2i] = []
	for y in range(2, h - 3):
		for x in range(2, w - 2):
			if not Vector2i(x, y + 1) in covered_dict or not Vector2i(x, y + 2) in covered_dict:
				continue
			if y + 3 >= h or grid[x][y + 3] != 0 or Vector2i(x, y + 3) in covered_dict:
				continue
			if y == wall_y and abs(x - cx) < 8: continue
			if Vector2(x, y + 2).distance_to(Vector2(spawn_tile)) < 4.0: continue
			if Vector2(x, y + 2).distance_to(Vector2(ladder_down_tile)) < 4.0: continue
			if Vector2i(x, y + 2) in water_cells_dict or Vector2i(x, y + 3) in water_cells_dict or Vector2i(x, y + 2) in lake_island_cells: continue

			# Не вешать фонари на отдельно стоящие колонны/островки (чтобы сохранялись темные зоны)
			if y >= 2 and (grid[x][y - 1] == 0 or grid[x][y - 2] == 0):
				continue

			# Не вешать вплотную к опорам с фонарями
			var near_support = false
			for s in placed_supports:
				if Vector2(x, y).distance_to(Vector2(s)) < 6.0:
					near_support = true
					break
			if near_support: continue

			lantern_candidates.append(Vector2i(x, y))

	lantern_candidates.shuffle()
	var placed_lanterns: Array[Vector2i] = []
	var target_lanterns = randi_range(2, 4)
	for cand in lantern_candidates:
		var too_close = false
		for pl in placed_lanterns:
			if Vector2(cand).distance_to(Vector2(pl)) < 8.0:
				too_close = true
				break
		if too_close: continue

		placed_lanterns.append(cand)
		var lantern = SCENE_CAVE_LANTERN.instantiate()
		lantern.global_position = _tile_to_world(Vector2i(cand.x, cand.y + 2))
		interactables.add_child(lantern)

		reserved[Vector2i(cand.x, cand.y + 3)] = true
		if placed_lanterns.size() >= target_lanterns:
			break

	# 12. Декоративные сталагмиты на полу (Cave_Decorations.png)
	# Гарантия проходимости: находим маршруты от спавна к лестнице и озеру и резервируем их
	var main_paths_reserved = {}
	var get_bfs_path = func(start_pos: Vector2i, end_pos: Vector2i) -> Array[Vector2i]:
		var q = [start_pos]
		var bfs_visited = {start_pos: true}
		var parent = {}
		while q.size() > 0:
			var curr = q.pop_front()
			if curr == end_pos:
				var path: Array[Vector2i] = []
				var step = end_pos
				while step in parent:
					path.append(step)
					step = parent[step]
				return path
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n = curr + d
				if n.x >= 0 and n.x < w and n.y >= 0 and n.y < h:
					if grid[n.x][n.y] == 0 and not n in covered_dict and not n in water_cells_dict and not n in bfs_visited:
						bfs_visited[n] = true
						parent[n] = curr
						q.append(n)
		return []

	for p_tile in get_bfs_path.call(spawn_tile, ladder_down_tile):
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				main_paths_reserved[p_tile + Vector2i(dx, dy)] = true

	if best_lake_center != Vector2i.ZERO:
		for p_tile in get_bfs_path.call(spawn_tile, best_lake_center):
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					main_paths_reserved[p_tile + Vector2i(dx, dy)] = true

	var is_solid_for_stalagmite = func(gx: int, gy: int) -> bool:
		if gx < 0 or gx >= w or gy < 0 or gy >= h: return true
		return grid[gx][gy] == 1 or Vector2i(gx, gy) in covered_dict or Vector2i(gx, gy) in water_cells_dict

	var stalagmite_candidates: Array[Vector2i] = []
	for cell in valid_floor_cells:
		if cell in reserved or cell in main_paths_reserved: continue
		if Vector2(cell).distance_to(Vector2(spawn_tile)) < 4.0: continue
		if Vector2(cell).distance_to(Vector2(ladder_down_tile)) < 4.0: continue
		
		# Запрещаем спавн в узких коридорах (если стены ближе 2 тайлов с противоположных сторон)
		var h_choke = (is_solid_for_stalagmite.call(cell.x - 1, cell.y) or is_solid_for_stalagmite.call(cell.x - 2, cell.y)) and (is_solid_for_stalagmite.call(cell.x + 1, cell.y) or is_solid_for_stalagmite.call(cell.x + 2, cell.y))
		var v_choke = (is_solid_for_stalagmite.call(cell.x, cell.y - 1) or is_solid_for_stalagmite.call(cell.x, cell.y - 2)) and (is_solid_for_stalagmite.call(cell.x, cell.y + 1) or is_solid_for_stalagmite.call(cell.x, cell.y + 2))
		if h_choke or v_choke:
			continue
			
		# Проверяем свободное пространство вокруг: минимум 6 из 8 соседних клеток должны быть свободным полом
		var walkable_count = 0
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0: continue
				if not is_solid_for_stalagmite.call(cell.x + dx, cell.y + dy):
					walkable_count += 1
		if walkable_count < 6:
			continue
			
		stalagmite_candidates.append(cell)
	
	stalagmite_candidates.shuffle()
	
	var target_stalagmites = clampi(int(valid_floor_cells.size() * 0.035), 10, 16)
	var placed_stalagmites_pos: Array[Vector2i] = []
	
	for cell in stalagmite_candidates:
		# Строгая минимальная дистанция: минимум 4.0 тайла (64px) между любыми двумя сталагмитами
		var too_close = false
		for p in placed_stalagmites_pos:
			if Vector2(cell).distance_to(Vector2(p)) < 4.0:
				too_close = true
				break
		if too_close: continue
		
		var stalagmite = SCENE_CAVE_STALAGMITE.instantiate()
		stalagmite.variant = randi() % 4
		stalagmite.global_position = _tile_to_world(cell)
		interactables.add_child(stalagmite)
		
		# Резервируем саму клетку и клетки вокруг от спавна камней, чтобы не возникало непроходимых заторов
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				reserved[cell + Vector2i(dx, dy)] = true
				
		placed_stalagmites_pos.append(cell)
		if placed_stalagmites_pos.size() >= target_stalagmites:
			break

	# 13. Спавн анимированных камней и рудных жил
	# Руды и камни спавнятся в свободных безопасных клетках с сохранением состояния очистки
	for cell in safe_floor_cells:
		if cell in reserved: continue
		if randf() < 0.08:
			if DungeonManager and DungeonManager.is_tile_cleared(floor_num, cell): continue
			
			# Шанс, что вместо обычного камня появится рудная жила или камень с рудой
			# 30% от заспавненных пород — руды
			var is_ore = randf() < 0.32
			var rock_node: Node2D = null
			
			if is_ore:
				var ore_node = SCENE_CAVE_ORE_ROCK.instantiate()
				var ore_cfg = _choose_ore_for_floor(floor_num)
				ore_node.setup_ore(ore_cfg.type, ore_cfg.variant)
				rock_node = ore_node
			else:
				rock_node = CAVE_STONES[randi() % CAVE_STONES.size()].instantiate()
				
			# Минимальный джиттер (+-2 пикселя), чтобы породы не стояли строго по сетке, но не наползали на стены
			rock_node.global_position = _tile_to_world(cell) + Vector2(randf_range(-2, 2), randf_range(-2, 2))
			interactables.add_child(rock_node)
			reserved[cell] = true
			
			var c_node = rock_node
			var c_fl = floor_num
			var c_t = cell
			c_node.tree_exiting.connect(func():
				if is_instance_valid(c_node) and "is_dead" in c_node and c_node.is_dead:
					if DungeonManager: DungeonManager.mark_tile_cleared(c_fl, c_t)
			)

	# 14. Спавн врагов подземелья (Слизни и Скелеты)
	# Количество монстров плавно растет с глубиной шахты
	var enemy_count = randi_range(2, 4) if floor_num <= 4 else randi_range(3, 6)
	var enemy_candidates: Array[Vector2i] = []
	var player_tile = spawn_tile if not (DungeonManager and DungeonManager.spawn_at_ladder_down) else ladder_down_tile
	
	for cell in safe_floor_cells:
		if cell in reserved: continue
		# Не спавним врагов прямо перед носом игрока на точке появления (минимум 7 тайлов)
		if Vector2(cell).distance_to(Vector2(player_tile)) < 7.0: continue
		enemy_candidates.append(cell)
		
	enemy_candidates.shuffle()
	
	var enemies_to_spawn = min(enemy_count, enemy_candidates.size())
	for i in range(enemies_to_spawn):
		var cell = enemy_candidates[i]
		reserved[cell] = true
		
		# 60% слизни, 40% скелеты на верхних этажах, глубже — 50/50
		var spawn_skeleton = randf() < (0.35 if floor_num <= 4 else 0.50)
		var enemy_node: Node2D = null
		
		if spawn_skeleton:
			enemy_node = SCENE_SKELETON.instantiate()
		else:
			var slime = SCENE_SLIME.instantiate()
			var sz = 2 # SMALL
			var r = randf()
			if floor_num <= 3:
				sz = 2 if r < 0.65 else 1 # SMALL or MEDIUM
			elif floor_num <= 7:
				if r < 0.35: sz = 2 # SMALL
				elif r < 0.75: sz = 1 # MEDIUM
				else: sz = 0 # BIG
			else:
				if r < 0.20: sz = 2 # SMALL
				elif r < 0.55: sz = 1 # MEDIUM
				else: sz = 0 # BIG
				
			var col = randi() % 5 # SlimeColor: BLUE, GREEN, PINK, RED, YELLOW
			if slime.has_method("setup_slime"):
				slime.setup_slime(sz, col)
			enemy_node = slime
			
		enemy_node.global_position = _tile_to_world(cell)
		interactables.add_child(enemy_node)

func _choose_ore_for_floor(floor_num: int) -> Dictionary:
	# Выбор типа руды и варианта жилы в зависимости от глубины подземелья
	# 8 типов (row 0..7):
	# 0: Сталь, 1: Железо, 2: Золото, 3: Малахит, 4: Сапфир, 5: Топаз, 6: Рубин, 7: Сумрак
	# 5 вариантов (col 0..4):
	# 0: Камень с рудой (частый на верхних уровнях)
	# 1: Большая жила (редкая)
	# 2: Средняя жила
	# 3, 4: Маленькие жилы
	
	var ore_type: int = 0
	var variant: int = 0
	
	# 1. Определение типа руды / минерала
	if floor_num <= 5:
		# Верхние этажи: в основном сталь и железо, редкое золото, ультраредкий сумрак
		var r = randf()
		if r < 0.005: # 0.5% шанс сумрака на этажах 1-5
			ore_type = CaveOreRock.OreType.DUSK
		elif r < 0.08:
			ore_type = CaveOreRock.OreType.GOLD
		elif r < 0.52:
			ore_type = CaveOreRock.OreType.STEEL
		else:
			ore_type = CaveOreRock.OreType.IRON
			
		# На верхних уровнях преобладают камни с рудой (вариант 0) и малые жилы
		var vr = randf()
		if vr < 0.55:
			variant = CaveOreRock.VeinVariant.STONE_WITH_ORE
		elif vr < 0.85:
			variant = CaveOreRock.VeinVariant.SMALL_VEIN_1 if randf() < 0.5 else CaveOreRock.VeinVariant.SMALL_VEIN_2
		elif vr < 0.95:
			variant = CaveOreRock.VeinVariant.MEDIUM_VEIN
		else:
			variant = CaveOreRock.VeinVariant.LARGE_VEIN
			
	elif floor_num <= 10:
		# Средние этажи: железо, сталь, золото, первые кристаллы (малахит, сапфир)
		var r = randf()
		if r < 0.012: # 1.2% шанс сумрака на этажах 6-10
			ore_type = CaveOreRock.OreType.DUSK
		elif r < 0.12:
			ore_type = CaveOreRock.OreType.MALACHITE if randf() < 0.6 else CaveOreRock.OreType.SAPPHIRE
		elif r < 0.35:
			ore_type = CaveOreRock.OreType.GOLD
		elif r < 0.68:
			ore_type = CaveOreRock.OreType.IRON
		else:
			ore_type = CaveOreRock.OreType.STEEL
			
		var vr = randf()
		if vr < 0.30:
			variant = CaveOreRock.VeinVariant.STONE_WITH_ORE
		elif vr < 0.55:
			variant = CaveOreRock.VeinVariant.MEDIUM_VEIN
		elif vr < 0.85:
			variant = CaveOreRock.VeinVariant.SMALL_VEIN_1 if randf() < 0.5 else CaveOreRock.VeinVariant.SMALL_VEIN_2
		else:
			variant = CaveOreRock.VeinVariant.LARGE_VEIN
			
	else:
		# Глубинные этажи (11+): золото, драгоценные самоцветы, сумрак встречается чаще
		var r = randf()
		if r < 0.05: # ~5% шанс сумрака
			ore_type = CaveOreRock.OreType.DUSK
		elif r < 0.40:
			# Драгоценные камни (малахит, сапфир, топаз, рубин)
			var gems = [
				CaveOreRock.OreType.MALACHITE,
				CaveOreRock.OreType.SAPPHIRE,
				CaveOreRock.OreType.TOPAZ,
				CaveOreRock.OreType.RUBY
			]
			ore_type = gems[randi() % gems.size()]
		elif r < 0.70:
			ore_type = CaveOreRock.OreType.GOLD
		elif r < 0.85:
			ore_type = CaveOreRock.OreType.IRON
		else:
			ore_type = CaveOreRock.OreType.STEEL
			
		var vr = randf()
		if vr < 0.18:
			variant = CaveOreRock.VeinVariant.STONE_WITH_ORE
		elif vr < 0.48:
			variant = CaveOreRock.VeinVariant.MEDIUM_VEIN
		elif vr < 0.78:
			variant = CaveOreRock.VeinVariant.LARGE_VEIN
		else:
			variant = CaveOreRock.VeinVariant.SMALL_VEIN_1 if randf() < 0.5 else CaveOreRock.VeinVariant.SMALL_VEIN_2
			
	return {"type": ore_type, "variant": variant}

func _create_boundary_walls_from_grid(body: StaticBody2D, grid: Array, w: int, h: int) -> void:
	body.collision_layer = 1
	body.collision_mask = 0
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 1:
				var adjacent_floor = false
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0: continue
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if grid[nx][ny] == 0:
								adjacent_floor = true
								break
					if adjacent_floor: break
					
				if adjacent_floor:
					var col = CollisionShape2D.new()
					var shape = RectangleShape2D.new()
					shape.size = Vector2(16, 16)
					col.shape = shape
					col.position = _tile_to_world(Vector2i(x, y)) + Vector2(0, 8)
					body.add_child(col)

func _tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * 16 + 8, tile.y * 16 + 8)
