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

	# Размеры залов случайные и могут быть больше (от маленьких до очень больших)
	var base_w = randi() % 80 + 40 # от 40 до 120
	var base_h = int(base_w * 0.75)
	
	# Делаем четными для идеального скейла
	var w: int = base_w - (base_w % 2)
	var h: int = base_h - (base_h % 2)
	
	# Генерируем пещеру в 2 раза меньшем разрешении, чтобы после увеличения x2 
	# ВСЕ проходы были минимум 2 тайла, а любые выступы стен были минимум 2х2 тайла (без резких углов)
	var sw = w / 2
	var sh = h / 2
	
	var s_grid: Array = []
	for x in range(sw):
		var col = []
		col.resize(sh)
		col.fill(1)
		s_grid.append(col)
		
	# Заполняем шумом (оставляя рамку из стен)
	# Увеличен порог шума (0.47 вместо 0.42), чтобы пещеры получались более запутанными и узкими
	for x in range(2, sw - 2):
		for y in range(2, sh - 2):
			if randf() > 0.47:
				s_grid[x][y] = 0
				
	# Сглаживаем клеточным автоматом
	for i in range(4):
		var new_s = s_grid.duplicate(true)
		for x in range(1, sw - 1):
			for y in range(1, sh - 1):
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
		
	var scx = sw / 2
	var scy = sh / 2
	
	# Расчищаем зону спавна в малом разрешении
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			s_grid[scx + dx][scy + dy] = 0
			
	# Пробиваем стартовый коридор в малом разрешении ДО flood-fill'а, чтобы соединить спавн с основной пещерой!
	# Копаем прямо до центра карты, чтобы ГАРАНТИРОВАННО зацепить основную пещеру!
	for y in range(sh / 2, scy + 1):
		s_grid[scx][y] = 0
			
	# Flood-fill для удаления изолированных комнат
	var visited: Array = []
	for x in range(sw):
		var col = []
		col.resize(sh)
		col.fill(false)
		visited.append(col)
		
	var queue: Array[Vector2i] = [Vector2i(scx, scy)]
	visited[scx][scy] = true
	
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
			
	# Увеличиваем в 2 раза (ИДЕАЛЬНАЯ ГЕОМЕТРИЯ)
	var grid: Array = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1)
		grid.append(col)
		
	for x in range(w):
		for y in range(h):
			grid[x][y] = s_grid[x / 2][y / 2]
			
	var cx = w / 2
	var cy = h / 2

	# Расчищаем зону спавна (уже в увеличенном разрешении)
	for dx in range(-4, 5):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0
			
	# Создаем массивную стену на севере от спавна, чтобы гарантированно образовать ЮЖНЫЙ фасад скалы!
	for dx in range(-6, 6):
		for dy in range(-7, -4):
			grid[cx + dx][cy + dy] = 1
			
	# Пробиваем ровный коридор на север через эту стену
	for dy in range(-12, -3):
		# ИСКЛЮЧЕНИЕ: Для коридора с саппортом делаем ширину ровно 3 тайла (-1, 0, 1),
		# чтобы ножки саппорта идеально совпали со стенами по краям!
		for dx in range(-1, 2):
			grid[cx + dx][cy + dy] = 0
		# Гарантируем толщину боковых стен коридора
		grid[cx - 2][cy + dy] = 1
		grid[cx - 3][cy + dy] = 1
		grid[cx + 2][cy + dy] = 1
		grid[cx + 3][cy + dy] = 1
			
	# Плавный переход краев в дальнем конце коридора
	for dx in range(-3, 3):
		grid[cx + dx][cy - 12] = 0

	# Саппорт ставится ровно у основания южного фасада скалы (y = cy - 3)

	var floor_cells: Array[Vector2i] = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				floor_cells.append(Vector2i(x, y))

	# 4. Draw floor using Terrain
	if not floor_cells.is_empty():
		var terrain_id = 2 if (floor_num % 2 == 1) else 3
		if randf() < 0.2: terrain_id = (3 if terrain_id == 2 else 2)
		floor_layer.set_cells_terrain_connect(floor_cells, 1, terrain_id)

	# 5. Draw Walls using perfect 3x3 blob logic (с огромным паддингом, чтобы не было выхода в пустоту)
	var covered_by_wall: Array[Vector2i] = []
	var padding = 20
	for x in range(-padding, w + padding):
		for y in range(-padding, h + padding):
			# Если за пределами сетки, считаем, что там скала
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
				
				# ПРАВИЛЬНЫЙ МАППИНГ ДЛЯ RPG MAKER 3x3 (ВЕРШИНА ГОРЫ)
				
				# Внешние углы (ИНВЕРТИРОВАННЫЙ МАППИНГ + ПОМЕНЯННЫЕ МЕСТАМИ ВНЕШНИЕ И ВНУТРЕННИЕ)
				if f_n and f_w: tile = Vector2i(4, 3)
				elif f_n and f_e: tile = Vector2i(5, 3)
				elif f_s and f_w: tile = Vector2i(4, 4)
				elif f_s and f_e: tile = Vector2i(5, 4)
				
				# Прямые края (Светлая часть к полу, темная внутрь скалы)
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы (Инвертированные + ПОМЕНЯННЫЕ МЕСТАМИ)
				elif f_nw: tile = Vector2i(6, 2)
				elif f_ne: tile = Vector2i(4, 2)
				elif f_sw: tile = Vector2i(6, 0)
				elif f_se: tile = Vector2i(4, 0)
				
				if tile != Vector2i(-1, -1):
					wall_layer.set_cell(Vector2i(x, y), SOURCE_WALLS, tile)
					
				# Если это Нижний край скалы (Пол находится Снизу), мы должны нарисовать ВЕРТИКАЛЬНУЮ стену (лицо скалы)
				if f_s or f_se or f_sw:
					var face_top = Vector2i(1, 6)
					var face_bot = Vector2i(1, 7)
					
					# Outer corners (swapped)
					# f_s and f_e -> Vector2i(4,0) -> Top-Left of cliff. The left side of the vertical wall drops here?
					# Actually, for RPG Maker outer corners, usually the center vertical wall is used, or the edge ones.
					if f_s and f_e:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)
					elif f_s and f_w:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
						
					# Inner corners (инвертировано)
					if f_se and not f_s:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
					elif f_sw and not f_s:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)
						
					wall_layer.set_cell(Vector2i(x, y+1), SOURCE_WALLS, face_top)
					wall_layer.set_cell(Vector2i(x, y+2), SOURCE_WALLS, face_bot)
					
					# Добавляем клетки в список "скрытых", чтобы там не спавнились камни
					covered_by_wall.append(Vector2i(x, y+1))
					covered_by_wall.append(Vector2i(x, y+2))
					
					# Создаем коллизию для вертикальной стены (на нижнем тайле y+2)
					var col = CollisionShape2D.new()
					var shape = RectangleShape2D.new()
					shape.size = Vector2(16, 16)
					col.shape = shape
					col.position = _tile_to_world(Vector2i(x, y+2))
					boundary_body.add_child(col)

	_create_boundary_walls_from_grid(boundary_body, grid, w, h)

	var spawn_tile = Vector2i(cx, cy)
	var ladder_up_tile = Vector2i(cx, cy - 1)
	
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

	# Саппорт ставится ровно у основания южного фасада скалы (y = cy - 3)
	var support_pos = Vector2i(cx, cy - 3)
	if support_pos != Vector2i(-1, -1):
		var support = preload("res://scenes/objects/dungeon/cave_support.tscn").instantiate()
		# Так как коридор теперь 3 тайла (нечетный), он идеально центрирован по тайлу cx!
		# Сдвигаем Y на +8 (чтобы origin был на нижнем крае тайла, совпадая с физической базой скалы)
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
		if randf() < 0.05: # Уменьшили количество камней по просьбе
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
					# Коллизия находится на уровне Y стены (основание скалы)
					col.position = _tile_to_world(Vector2i(x, y)) + Vector2(0, 8)
					body.add_child(col)

func _tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * 16 + 8, tile.y * 16 + 8)
