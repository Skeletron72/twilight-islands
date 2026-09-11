extends RefCounted
class_name DungeonGenerator

# Procedural generator for Stardew Valley-style mine/dungeon floors.

const SOURCE_WALLS: int = 25
const SOURCE_FLOOR: int = 32
const SOURCE_FLOOR_DECOR: int = 27

# ==============================================================================
# КООРДИНАТЫ ТАЙЛОВ СТЕН (Из слов пользователя)
# Если какой-то кусок выглядит не так, можно просто поменять X, Y здесь!
# ==============================================================================

# Пол (нижние тайлы в Cave_Floor_1)
const TILE_FLOOR = Vector2i(1, 4)

# Внутренние углы (правые верхние 9 тайлов, 3x3. Серединка 5,1 пустая)
const TILE_INNER_TL = Vector2i(4, 0)
const TILE_INNER_TR = Vector2i(6, 0)
const TILE_INNER_BL = Vector2i(4, 2)
const TILE_INNER_BR = Vector2i(6, 2)

# Внешние углы (сразу под ними 4 тайла, 2x2)
const TILE_OUTER_TL = Vector2i(4, 3)
const TILE_OUTER_TR = Vector2i(5, 3)
const TILE_OUTER_BL = Vector2i(4, 4)
const TILE_OUTER_BR = Vector2i(5, 4)

# Сами стены (Слева снизу 6 тайлов)
# Допустим, это блок 3x2: (0..2, 6..7).
const TILE_WALL_TOP = Vector2i(1, 6)    # Верхняя стена
const TILE_WALL_BOTTOM = Vector2i(1, 7) # Нижняя стена (смотрит на нас)
const TILE_WALL_LEFT = Vector2i(0, 6)   # Левая стена
const TILE_WALL_RIGHT = Vector2i(2, 6)  # Правая стена

# Сплошная заливка стены вдали
const TILE_WALL_SOLID = Vector2i(0, 7)

# ==============================================================================

const SCENE_LADDER_UP = preload("res://scenes/objects/dungeon/ladder_up.tscn")
const SCENE_LADDER_DOWN = preload("res://scenes/objects/dungeon/ladder_down.tscn")
const SCENE_ORE_ROCK = preload("res://scenes/objects/dungeon/cave_ore_rock.tscn")
const SCENE_TORCH = preload("res://scenes/objects/dungeon/cave_torch.tscn")

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
	
	# Clear previous map
	floor_layer.clear()
	wall_layer.clear()
	for child in boundary_body.get_children():
		child.queue_free()
	for child in interactables.get_children():
		child.queue_free()

	# Dimensions increase with floor number
	var w: int = 26 + (floor_num % 5) * 2
	var h: int = 20 + (floor_num % 3) * 2
	
	var grid: Array = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1) # 1 = Wall
		grid.append(col)
		
	# 1. Сellular Automata - Random Fill
	for x in range(2, w - 2):
		for y in range(2, h - 2):
			if randf() > 0.42:
				grid[x][y] = 0 # 0 = Floor
				
	# 2. Сellular Automata - Smoothing (4 iterations)
	for i in range(4):
		var new_grid = grid.duplicate(true)
		for x in range(1, w - 1):
			for y in range(1, h - 1):
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
		
	# Ensure a central clearing for spawn and ladder
	var cx = w / 2
	var cy = h / 2
	for dx in range(-3, 4):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0
			
	# Connect separate cave rooms or ensure borders are walls
	for x in range(w):
		grid[x][0] = 1
		grid[x][h-1] = 1
	for y in range(h):
		grid[0][y] = 1
		grid[w-1][y] = 1

	# 3. Draw Floor & Calculate Walls
	var valid_floor_cells = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 0:
				floor_layer.set_cell(Vector2i(x, y), SOURCE_FLOOR, TILE_FLOOR)
				valid_floor_cells.append(Vector2i(x, y))
			else:
				# It is a wall. Let's autotile it based on neighboring floors!
				var f_n = grid[x][y-1] == 0 if y > 0 else false
				var f_s = grid[x][y+1] == 0 if y < h-1 else false
				var f_w = grid[x-1][y] == 0 if x > 0 else false
				var f_e = grid[x+1][y] == 0 if x < w-1 else false
				
				var f_nw = grid[x-1][y-1] == 0 if (x > 0 and y > 0) else false
				var f_ne = grid[x+1][y-1] == 0 if (x < w-1 and y > 0) else false
				var f_sw = grid[x-1][y+1] == 0 if (x > 0 and y < h-1) else false
				var f_se = grid[x+1][y+1] == 0 if (x < w-1 and y < h-1) else false
				
				var tile = TILE_WALL_SOLID
				var is_border = false
				
				# Inner corners (Floor on two orthogonal sides)
				if f_s and f_e: tile = TILE_INNER_TL; is_border = true
				elif f_s and f_w: tile = TILE_INNER_TR; is_border = true
				elif f_n and f_e: tile = TILE_INNER_BL; is_border = true
				elif f_n and f_w: tile = TILE_INNER_BR; is_border = true
				
				# Straight edges (Floor on one side)
				elif f_s: tile = TILE_WALL_TOP; is_border = true
				elif f_n: tile = TILE_WALL_BOTTOM; is_border = true
				elif f_e: tile = TILE_WALL_LEFT; is_border = true
				elif f_w: tile = TILE_WALL_RIGHT; is_border = true
				
				# Outer corners (Floor only on diagonal)
				elif f_se: tile = TILE_OUTER_TL; is_border = true
				elif f_sw: tile = TILE_OUTER_TR; is_border = true
				elif f_ne: tile = TILE_OUTER_BL; is_border = true
				elif f_nw: tile = TILE_OUTER_BR; is_border = true
				
				# Only draw if it's a border or solid background
				if is_border or (not is_border and randf() < 0.1): # optimization: don't draw invisible solid walls
					wall_layer.set_cell(Vector2i(x, y), SOURCE_WALLS, tile)

	# 4. Generate Collider for Walls using Godot's TileMapLayer built-in collisions, 
	# but we will manually add physical bodies around the floor edges for perfect collision
	_create_boundary_walls_from_grid(boundary_body, grid, w, h)

	# 5. Place Ladders and Spawns
	var spawn_tile = Vector2i(cx, cy)
	var ladder_up_tile = Vector2i(cx, cy - 1)
	
	# Find a faraway point for the ladder down
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

	# 6. Scatter Ores and Stones
	var reserved = [spawn_tile, ladder_up_tile, ladder_down_tile, ladder_up_tile + Vector2i(0, 1)]
	for cell in valid_floor_cells:
		if cell in reserved: continue
		if randf() < 0.15:
			var stone = MINABLE_STONES[randi() % MINABLE_STONES.size()].instantiate()
			stone.global_position = _tile_to_world(cell) + Vector2(randf_range(-4, 4), randf_range(-4, 4))
			interactables.add_child(stone)

func _create_boundary_walls_from_grid(body: StaticBody2D, grid: Array, w: int, h: int) -> void:
	body.collision_layer = 1
	body.collision_mask = 0
	
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 1:
				# Only add collision if adjacent to floor
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
					col.position = _tile_to_world(Vector2i(x, y))
					body.add_child(col)

func _tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * 16 + 8, tile.y * 16 + 8)

