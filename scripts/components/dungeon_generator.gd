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
		
	# 1. Сellular Automata - Random Fill
	for x in range(3, w - 3):
		for y in range(4, h - 4):
			if randf() > 0.42:
				grid[x][y] = 0 # 0 = Floor
				
	# 2. Сellular Automata - Smoothing
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
		
	var cx = w / 2
	var cy = h / 2
	for dx in range(-3, 4):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0
			
	var floor_options = [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(1, 3)]
	
	var floor_cells: Array[Vector2i] = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				floor_cells.append(Vector2i(x, y))
			elif grid[x][y] == 1:
				var f_n = grid[x][y-1] == 0 if y > 0 else false
				var f_s = grid[x][y+1] == 0 if y < h-1 else false
				var f_w = grid[x-1][y] == 0 if x > 0 else false
				var f_e = grid[x+1][y] == 0 if x < w-1 else false
				
				var f_nw = grid[x-1][y-1] == 0 if (x > 0 and y > 0) else false
				var f_ne = grid[x+1][y-1] == 0 if (x < w-1 and y > 0) else false
				var f_sw = grid[x-1][y+1] == 0 if (x > 0 and y < h-1) else false
				var f_se = grid[x+1][y+1] == 0 if (x < w-1 and y < h-1) else false
				
				var tile = Vector2i(-1, -1)
				
				# Прямые внешние стены (3x3 блок)
				# (4,0) (5,0) (6,0)
				# (4,1) (5,1) (6,1)
				# (4,2) (5,2) (6,2)
				
				if f_s and f_e: tile = Vector2i(4, 0) # Floor is SE -> Wall is NW Outer corner
				elif f_s and f_w: tile = Vector2i(6, 0) # Floor is SW -> Wall is NE Outer corner
				elif f_n and f_e: tile = Vector2i(4, 2) # Floor is NE -> Wall is SW Outer corner
				elif f_n and f_w: tile = Vector2i(6, 2) # Floor is NW -> Wall is SE Outer corner
				
				elif f_s: tile = Vector2i(5, 0) # Floor is S -> Wall is North Edge
				elif f_n: tile = Vector2i(5, 2) # Floor is N -> Wall is South Edge
				elif f_e: tile = Vector2i(4, 1) # Floor is E -> Wall is West Edge
				elif f_w: tile = Vector2i(6, 1) # Floor is W -> Wall is East Edge
				
				# Внутренние углы (4 тайла под 3x3)
				# Допустим (4,3) (5,3)
				#        (4,4) (5,4)
				elif f_se: tile = Vector2i(4, 3) # Floor is SE diagonal only -> Inner corner TL
				elif f_sw: tile = Vector2i(5, 3) # Floor is SW diagonal only -> Inner corner TR
				elif f_ne: tile = Vector2i(4, 4) # Floor is NE diagonal only -> Inner corner BL
				elif f_nw: tile = Vector2i(5, 4) # Floor is NW diagonal only -> Inner corner BR
				
				if tile != Vector2i(-1, -1):
					wall_layer.set_cell(Vector2i(x, y), SOURCE_WALLS, tile)
					
				# Рисуем высокую переднюю стену (если стена сверху от пола, значит это Северная стена, которая смотрит на нас)
				if f_s:
					# Высокая стена (6 тайлов слева снизу) -> (1, 6) и (1, 7)
					# Рисуем нижнюю часть высокой стены поверх пола!
					wall_layer.set_cell(Vector2i(x, y+1), SOURCE_WALLS, Vector2i(1, 6))
					wall_layer.set_cell(Vector2i(x, y+2), SOURCE_WALLS, Vector2i(1, 7))

	
	# Заливаем пол через Godot Terrains (Match Sides), как просил пользователь!
	# Предполагается, что пол настроен в terrain_set_1, terrain 2 (или другой, если 2 занят)
	if not floor_cells.is_empty():
		floor_layer.set_cells_terrain_connect(floor_cells, 1, 2)
		
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
					col.position = _tile_to_world(Vector2i(x, y)) + Vector2(0, 8)
					body.add_child(col)

func _tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * 16 + 8, tile.y * 16 + 8)
