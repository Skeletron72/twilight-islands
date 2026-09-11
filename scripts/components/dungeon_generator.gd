extends RefCounted
class_name DungeonGenerator

const SOURCE_WALLS: int = 25
const SOURCE_FLOOR: int = 32

const SCENE_LADDER_UP = preload("res://scenes/objects/dungeon/ladder_up.tscn")
const SCENE_LADDER_DOWN = preload("res://scenes/objects/dungeon/ladder_down.tscn")
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

	# Размеры залов случайные (от компактных до огромных лабиринтов)
	var base_w = randi_range(30, 65) # w будет от 60 до 130
	var base_h = int(base_w * 0.75)  # h будет от 45 до 97
	
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
	
	# 2. Заполняем шумом верхнюю область пещеры (до южной стены)
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
				s_grid[scx + dx][connected_y + dy] = 0

	# 5. Flood-fill от входа для удаления изолированных полостей
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
				if abs(dx) == abs(dy): continue # Только ортогональные соседи
				var nx = curr.x + dx
				var ny = curr.y + dy
				if nx >= 0 and nx < sw and ny >= 0 and ny < sh:
					if s_grid[nx][ny] == 0 and not visited[nx][ny]:
						visited[nx][ny] = true
						queue.append(Vector2i(nx, ny))
						
	# Заливаем все непосещенные участки пола стенами
	for x in range(sw):
		for y in range(sh):
			if s_grid[x][y] == 0 and not visited[x][y]:
				s_grid[x][y] = 1
				
	# 6. Увеличиваем в 2 раза (ИДЕАЛЬНАЯ ГЕОМЕТРИЯ)
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
	
	# 7. Четкая геометрия входной комнаты и южной стены:
	# Очищаем комнату спавна строго под южной стеной
	for x in range(cx - 7, cx + 8):
		for y in range(wall_y + 1, min(wall_y + 8, h - 2)):
			if x >= 1 and x < w - 1 and y >= 1 and y < h - 1:
				grid[x][y] = 0
				
	# Создаем ровную, непрерывную горизонтальную южную стену (от cx-12 до cx+12)
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
			
	# Плавный широкий выход из коридора в пещеру на северном конце
	for dx in range(-3, 4):
		for dy in range(-2, 1):
			var jx = cx + dx
			var jy = wall_y - 8 + dy
			if jx >= 1 and jx < w - 1 and jy >= 1:
				grid[jx][jy] = 0

	# 8. Рисуем пол с помощью автотайлинга Terrain
	var floor_cells: Array[Vector2i] = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				floor_cells.append(Vector2i(x, y))

	if not floor_cells.is_empty():
		var terrain_id = 2 if (floor_num % 2 == 1) else 3
		if randf() < 0.2: terrain_id = (3 if terrain_id == 2 else 2)
		floor_layer.set_cells_terrain_connect(floor_cells, 1, terrain_id)

	# 9. Рисуем стены (с паддингом в 20 тайлов вокруг, чтобы не было видно пустоту)
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
					
					# Торцы фасада:
					# Если стена граничит с полом на востоке (левая стена коридора) -> правый торец скалы (2, 6)
					# Если стена граничит с полом на западе (правая стена коридора) -> левый торец скалы (0, 6)
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

	# 10. Размещение объектов
	var spawn_tile = Vector2i(cx, wall_y + 3)
	var ladder_up_tile = Vector2i(cx, wall_y + 4)
	
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

	# Саппорт ставится ровно у основания южного фасада скалы (y = wall_y + 2)
	# Его перекладина ровно на уровне wall_y, а стойки упираются в пол у основания фасада
	var support_pos = Vector2i(cx, wall_y + 2)
	var support = preload("res://scenes/objects/dungeon/cave_support.tscn").instantiate()
	support.global_position = _tile_to_world(support_pos) + Vector2(0, 8)
	interactables.add_child(support)

	var ladder_up = SCENE_LADDER_UP.instantiate()
	ladder_up.global_position = _tile_to_world(ladder_up_tile)
	interactables.add_child(ladder_up)

	if player:
		player.global_position = _tile_to_world(spawn_tile)

	var ladder_down = SCENE_LADDER_DOWN.instantiate()
	ladder_down.global_position = _tile_to_world(ladder_down_tile)
	interactables.add_child(ladder_down)

	var reserved = [spawn_tile, ladder_up_tile, ladder_down_tile, ladder_up_tile + Vector2i(0, 1)]
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
