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

	var w: int = 26 + (floor_num % 5) * 2
	var h: int = 20 + (floor_num % 3) * 2
	var grid: Array = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1) # 1 = Wall
		grid.append(col)
		
	# 1. Cellular Automata - Random Fill
	for x in range(3, w - 3):
		for y in range(4, h - 4):
			if randf() > 0.42:
				grid[x][y] = 0 # 0 = Floor
				
	# 2. Cellular Automata - Smoothing
	for i in range(4):
		var new_grid = grid.duplicate(true)
		for x in range(2, w - 2):
			for y in range(3, h - 3):
				var walls = 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if grid[x + dx][y + dy] == 1:
							walls += 1
				if walls >= 5:
					new_grid[x][y] = 1
				elif walls <= 3:
					new_grid[x][y] = 0
		grid = new_grid
		
	# 3. Widen corridors (minimum 2 tiles wide)
	for i in range(2):
		var new_grid = grid.duplicate(true)
		for x in range(2, w - 2):
			for y in range(3, h - 3):
				if grid[x][y] == 0:
					# Horizontal bottleneck (Wall - Floor - Wall) -> widen to Right
					if grid[x-1][y] == 1 and grid[x+1][y] == 1:
						new_grid[x+1][y] = 0
						new_grid[x+1][y-1] = 0 # help clear corners
					# Vertical bottleneck (Wall - Floor - Wall) -> widen Down
					if grid[x][y-1] == 1 and grid[x][y+1] == 1:
						new_grid[x][y+1] = 0
						new_grid[x+1][y+1] = 0
		grid = new_grid

	var cx = w / 2
	var cy = h / 2
	for dx in range(-3, 4):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0

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

	# 5. Draw Walls using perfect 3x3 blob logic
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 1:
				var f_n = grid[x][y-1] == 0 if y > 0 else false
				var f_s = grid[x][y+1] == 0 if y < h-1 else false
				var f_w = grid[x-1][y] == 0 if x > 0 else false
				var f_e = grid[x+1][y] == 0 if x < w-1 else false
				
				var f_nw = grid[x-1][y-1] == 0 if (x > 0 and y > 0) else false
				var f_ne = grid[x+1][y-1] == 0 if (x < w-1 and y > 0) else false
				var f_sw = grid[x-1][y+1] == 0 if (x > 0 and y < h-1) else false
				var f_se = grid[x+1][y+1] == 0 if (x < w-1 and y < h-1) else false
				
				var tile = Vector2i(-1, -1)
				
				# ПРАВИЛЬНЫЙ МАППИНГ ДЛЯ RPG MAKER 3x3 (ВЕРШИНА ГОРЫ)
				
				# Внешние углы
				if f_n and f_w: tile = Vector2i(4, 0) # Floor is NW -> This is Top-Left edge of cliff
				elif f_n and f_e: tile = Vector2i(6, 0) # Floor is NE -> This is Top-Right edge of cliff
				elif f_s and f_w: tile = Vector2i(4, 2) # Floor is SW -> This is Bottom-Left edge of cliff
				elif f_s and f_e: tile = Vector2i(6, 2) # Floor is SE -> This is Bottom-Right edge of cliff
				
				# Прямые края
				elif f_n: tile = Vector2i(5, 0) # Floor is N -> This is Top edge of cliff
				elif f_s: tile = Vector2i(5, 2) # Floor is S -> This is Bottom edge of cliff
				elif f_w: tile = Vector2i(4, 1) # Floor is W -> This is Left edge of cliff
				elif f_e: tile = Vector2i(6, 1) # Floor is E -> This is Right edge of cliff
				
				# Внутренние углы (впадины в скале)
				elif f_nw: tile = Vector2i(5, 4) # Floor is NW only -> Inner BR corner of cliff
				elif f_ne: tile = Vector2i(4, 4) # Floor is NE only -> Inner BL corner of cliff
				elif f_sw: tile = Vector2i(5, 3) # Floor is SW only -> Inner TR corner of cliff
				elif f_se: tile = Vector2i(4, 3) # Floor is SE only -> Inner TL corner of cliff
				
				if tile != Vector2i(-1, -1):
					wall_layer.set_cell(Vector2i(x, y), SOURCE_WALLS, tile)
					
				# Если это Нижний край скалы (Пол находится Снизу), мы должны нарисовать ВЕРТИКАЛЬНУЮ стену (лицо скалы)
				if f_s or (f_s and f_w) or (f_s and f_e) or f_se or f_sw:
					var face_top = Vector2i(1, 6)
					var face_bot = Vector2i(1, 7)
					
					if f_s and f_w:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)
					elif f_s and f_e:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
						
					# Рисуем вертикальную стену, которая накладывается поверх пола!
					wall_layer.set_cell(Vector2i(x, y+1), SOURCE_WALLS, face_top)
					wall_layer.set_cell(Vector2i(x, y+2), SOURCE_WALLS, face_bot)

	_create_boundary_walls_from_grid(boundary_body, grid, w, h)

	var spawn_tile = Vector2i(cx, cy)
	var ladder_up_tile = Vector2i(cx, cy - 1)
	
	var valid_floor_cells = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				valid_floor_cells.append(Vector2i(x, y))
				
	var ladder_down_tile = spawn_tile
	var max_dist = 0.0
	for cell in valid_floor_cells:
		var d = Vector2(cell).distance_to(Vector2(spawn_tile))
		if d > max_dist:
			max_dist = d
			ladder_down_tile = cell

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
		if randf() < 0.15:
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
