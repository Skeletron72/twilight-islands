extends RefCounted
class_name DungeonGenerator

# ==============================================================================
# ID ТЕРРЕЙНОВ (ОБЯЗАТЕЛЬНО ПОМЕНЯЙ ИХ НА ТЕ, ЧТО ПОЛУЧИЛИСЬ В ТАЙЛСЕТЕ!)
# ==============================================================================
const TERRAIN_SET_WALLS = 0
const TERRAIN_WALLS = 17 

const TERRAIN_SET_FLOOR = 1
const TERRAIN_FLOOR = 2

const TERRAIN_SET_WATER = 0
const TERRAIN_WATER = 18
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
		for y in range(3, h - 3):
			if randf() > 0.42:
				grid[x][y] = 0 # 0 = Floor
				
	# 2. Сellular Automata - Smoothing
	for i in range(4):
		var new_grid = grid.duplicate(true)
		for x in range(2, w - 2):
			for y in range(2, h - 2):
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
			
	# Add some water pools
	for x in range(4, w - 4):
		for y in range(4, h - 4):
			if grid[x][y] == 0 and randf() < 0.02:
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if grid[x+dx][y+dy] == 0:
							grid[x+dx][y+dy] = 2 # 2 = Water

	# 3. Collect cells for Terrains
	var floor_cells: Array[Vector2i] = []
	var wall_cells: Array[Vector2i] = []
	var water_cells: Array[Vector2i] = []
	var valid_floor_cells: Array[Vector2i] = []
	
	for x in range(w):
		for y in range(h):
			var pos = Vector2i(x, y)
			if grid[x][y] == 0:
				floor_cells.append(pos)
				valid_floor_cells.append(pos)
			elif grid[x][y] == 2:
				water_cells.append(pos)
			elif grid[x][y] == 1:
				# Для стен добавляем толщину 2-3 тайла вокруг пола, чтобы автотайлинг сработал идеально
				var near = false
				for dx in range(-3, 4):
					for dy in range(-3, 4):
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if grid[nx][ny] == 0 or grid[nx][ny] == 2:
								near = true
								break
					if near: break
				
				if near:
					wall_cells.append(pos)

	# 4. Запрашиваем у Godot отрисовку Террейнов!
	if not floor_cells.is_empty():
		floor_layer.set_cells_terrain_connect(floor_cells, TERRAIN_SET_FLOOR, TERRAIN_FLOOR)
	if not water_cells.is_empty():
		floor_layer.set_cells_terrain_connect(water_cells, TERRAIN_SET_WATER, TERRAIN_WATER)
	if not wall_cells.is_empty():
		wall_layer.set_cells_terrain_connect(wall_cells, TERRAIN_SET_WALLS, TERRAIN_WALLS)

	# 5. Generate Collider for Walls
	_create_boundary_walls_from_grid(boundary_body, grid, w, h)

	# 6. Place Ladders and Spawns
	var spawn_tile = Vector2i(cx, cy)
	var ladder_up_tile = Vector2i(cx, cy - 1)
	
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

	# 7. Scatter Ores and Stones
	var reserved = [spawn_tile, ladder_up_tile, ladder_down_tile, ladder_up_tile + Vector2i(0, 1)]
	for cell in valid_floor_cells:
		if cell in reserved: continue
		if randf() < 0.15:
			# Skip if already mined
			if DungeonManager and DungeonManager.is_tile_cleared(floor_num, cell):
				continue
				
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
							if grid[nx][ny] == 0 or grid[nx][ny] == 2:
								adjacent_floor = true
								break
					if adjacent_floor: break
					
				if adjacent_floor:
					var col = CollisionShape2D.new()
					var shape = RectangleShape2D.new()
					shape.size = Vector2(16, 16)
					col.shape = shape
					# Offset collision slightly down to allow player to overlap the top wall visually
					col.position = _tile_to_world(Vector2i(x, y)) + Vector2(0, 4)
					body.add_child(col)

func _tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * 16 + 8, tile.y * 16 + 8)
