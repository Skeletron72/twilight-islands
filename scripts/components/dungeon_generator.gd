extends RefCounted
class_name DungeonGenerator

const SOURCE_WALLS: int = 25
const SOURCE_FLOOR: int = 32

const SCENE_CAVE_DOORWAY = preload("res://scenes/objects/dungeon/cave_doorway.tscn")
const SCENE_WALL_LADDER = preload("res://scenes/objects/dungeon/wall_ladder.tscn")
const SCENE_LADDER_DOWN = preload("res://scenes/objects/dungeon/ladder_down.tscn")
const SCENE_CAVE_SUPPORT = preload("res://scenes/objects/dungeon/cave_support.tscn")

const MINABLE_STONES = [
	preload("res://scenes/objects/stones/stone_10.tscn"),
	preload("res://scenes/objects/stones/stone_11.tscn"),
	preload("res://scenes/objects/stones/stone_12.tscn"),
	preload("res://scenes/objects/stones/stone_13.tscn"),
	preload("res://scenes/objects/stones/stone_14.tscn")
]

func generate(
	floor_num: int,
	floor_layer: TileMapLayer,
	wall_layer: TileMapLayer,
	boundary_body: StaticBody2D,
	interactables: Node2D,
	player: Node2D
) -> void:
	
	floor_layer.clear()
	wall_layer.clear()
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
	chambers.append({"x": scx, "y": entrance_chamber_y, "rx": randi_range(4, 6), "ry": randi_range(3, 4)})
	
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

	# В залах оставляем природные каменные колонны
	for ch in chambers:
		if ch.rx >= 4 and ch.ry >= 3 and randf() < 0.5:
			s_grid[ch.x][ch.y] = 1

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
	
	# 6. Геометрия входной комнаты и южной стены:
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
				grid[jx][jy] = 0

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
					
					var col = CollisionShape2D.new()
					var shape = RectangleShape2D.new()
					shape.size = Vector2(16, 16)
					col.shape = shape
					col.position = _tile_to_world(Vector2i(x, y + 2))
					boundary_body.add_child(col)

	_create_boundary_walls_from_grid(boundary_body, grid, w, h)

	# 9. Размещение объектов
	var spawn_tile = Vector2i(cx - 4, wall_y + 3)
	
	var valid_floor_cells = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				if not Vector2i(x, y) in covered_by_wall:
					valid_floor_cells.append(Vector2i(x, y))
				
	var ladder_down_tile = spawn_tile
	var max_dist = 0.0
	for cell in valid_floor_cells:
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

	# Игрок появляется перед выходом на южной стене
	if player:
		player.global_position = _tile_to_world(spawn_tile)

	# СПУСК ВНИЗ: люк в полу Cave_Floor_Ladder (в дальнем зале)
	var ladder_down = SCENE_LADDER_DOWN.instantiate()
	ladder_down.global_position = _tile_to_world(ladder_down_tile)
	interactables.add_child(ladder_down)

	# 10. Спавн камней и руд (не спавним у выхода, саппорта и люка)
	var reserved = [
		spawn_tile,
		Vector2i(cx - 4, wall_y + 2),
		Vector2i(cx - 5, wall_y + 2),
		ladder_down_tile,
		Vector2i(cx, wall_y + 2),
		Vector2i(cx, wall_y + 1),
		Vector2i(cx, wall_y)
	]
	for cell in valid_floor_cells:
		if cell in reserved: continue
		if randf() < 0.05:
			if DungeonManager and DungeonManager.is_tile_cleared(floor_num, cell): continue
			var stone = MINABLE_STONES[randi() % MINABLE_STONES.size()].instantiate()
			stone.global_position = _tile_to_world(cell) + Vector2(randf_range(-4, 4), randf_range(-4, 4))
			interactables.add_child(stone)
			var c_node = stone
			var c_fl = floor_num
			var c_t = cell
			c_node.tree_exiting.connect(func():
				if is_instance_valid(c_node) and "is_dead" in c_node and c_node.is_dead:
					if DungeonManager: DungeonManager.mark_tile_cleared(c_fl, c_t)
			)

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
