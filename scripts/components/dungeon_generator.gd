extends RefCounted
class_name DungeonGenerator

# Procedural generator for Stardew Valley-style mine/dungeon floors.

const SOURCE_WALLS: int = 25
const SOURCE_FLOOR: int = 33
const SOURCE_FLOOR_DECOR: int = 27

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

const GATHERABLE_STONES = [
	preload("res://scenes/objects/stones/stone_1.tscn"),
	preload("res://scenes/objects/stones/stone_2.tscn"),
	preload("res://scenes/objects/stones/stone_3.tscn"),
	preload("res://scenes/objects/stones/stone_4.tscn"),
	preload("res://scenes/objects/stones/stone_5.tscn"),
	preload("res://scenes/objects/stones/stone_6.tscn"),
	preload("res://scenes/objects/stones/stone_7.tscn"),
	preload("res://scenes/objects/stones/stone_8.tscn"),
	preload("res://scenes/objects/stones/stone_9.tscn")
]

func generate(
	floor_num: int,
	floor_layer: TileMapLayer,
	wall_layer: TileMapLayer,
	boundary_body: StaticBody2D,
	interactables: Node2D,
	player: Player
) -> void:
	# Deterministic seed based on dungeon_seed and floor number
	var base_seed: int = DungeonManager.get_or_create_dungeon_seed() if DungeonManager else 12345
	seed(hash(base_seed + floor_num * 10007))

	# Clear previous tiles and children
	floor_layer.clear()
	wall_layer.clear()
	for child in boundary_body.get_children():
		child.queue_free()
	for child in interactables.get_children():
		child.queue_free()

	# Room dimensions
	var width: int = 22 + (floor_num % 3) * 2
	var height: int = 16 + (floor_num % 2) * 2

	# 1. Fill Floor tiles
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			floor_layer.set_cell(Vector2i(x, y), SOURCE_FLOOR, Vector2i(0, 0))
			# Floor decor with 12% probability
			if randf() < 0.12:
				var decor_variant = randi() % 3
				floor_layer.set_cell(Vector2i(x, y), SOURCE_FLOOR_DECOR, Vector2i(decor_variant, 0))

	# 2. Build Perimeter Walls
	for x in range(1, width - 1):
		wall_layer.set_cell(Vector2i(x, 0), SOURCE_WALLS, Vector2i(1, 0)) # Top
		wall_layer.set_cell(Vector2i(x, height - 1), SOURCE_WALLS, Vector2i(1, 2)) # Bottom

	for y in range(1, height - 1):
		wall_layer.set_cell(Vector2i(0, y), SOURCE_WALLS, Vector2i(0, 1)) # Left
		wall_layer.set_cell(Vector2i(width - 1, y), SOURCE_WALLS, Vector2i(2, 1)) # Right

	# Corners
	wall_layer.set_cell(Vector2i(0, 0), SOURCE_WALLS, Vector2i(0, 0))
	wall_layer.set_cell(Vector2i(width - 1, 0), SOURCE_WALLS, Vector2i(2, 0))
	wall_layer.set_cell(Vector2i(0, height - 1), SOURCE_WALLS, Vector2i(0, 2))
	wall_layer.set_cell(Vector2i(width - 1, height - 1), SOURCE_WALLS, Vector2i(2, 2))

	# 3. Create Boundary Collisions
	_create_boundary_walls(boundary_body, width, height)

	# 4. Reserved tiles (walkway, entrance, exit)
	var ladder_up_tile = Vector2i(3, 3)
	var spawn_tile = Vector2i(3, 4)
	var ladder_down_tile = Vector2i(width - 4, height - 4)

	var reserved: Dictionary = {}
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			reserved[ladder_up_tile + Vector2i(dx, dy)] = true
			reserved[spawn_tile + Vector2i(dx, dy)] = true
			reserved[ladder_down_tile + Vector2i(dx, dy)] = true

	# 5. Place Ladder Up & Position Player
	var ladder_up = SCENE_LADDER_UP.instantiate()
	ladder_up.global_position = _tile_to_world(ladder_up_tile)
	interactables.add_child(ladder_up)

	if player:
		player.global_position = _tile_to_world(spawn_tile)
		if "lantern_light" in player and player.lantern_light:
			player.lantern_light.energy = 0.9
		var cam = player.get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.reset_smoothing()

	# 6. Place Ladder Down
	var ladder_down = SCENE_LADDER_DOWN.instantiate()
	ladder_down.global_position = _tile_to_world(ladder_down_tile)
	interactables.add_child(ladder_down)

	# 7. Add Ambient Torches along north wall
	var torch_x_positions = [5, int(width / 2), width - 6]
	for tx in torch_x_positions:
		var torch = SCENE_TORCH.instantiate()
		torch.global_position = _tile_to_world(Vector2i(tx, 1))
		interactables.add_child(torch)

	# 8. Natural Interior Cavern Pillars (1-3 small pillars)
	var pillar_count = randi_range(1, 3)
	for p in range(pillar_count):
		var px = randi_range(6, width - 7)
		var py = randi_range(4, height - 5)
		var p_tile = Vector2i(px, py)
		if reserved.has(p_tile): continue
		
		# Place a 1x1 or 2x1 rock pillar
		wall_layer.set_cell(p_tile, SOURCE_WALLS, Vector2i(1, 1))
		reserved[p_tile] = true
		
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(16, 16)
		col.shape = shape
		col.position = _tile_to_world(p_tile)
		boundary_body.add_child(col)

	# 9. Scatter Minable Rocks and Ores
	var ore_chance = clampf(0.20 + (floor_num * 0.05), 0.20, 0.65)
	for y in range(2, height - 2):
		for x in range(2, width - 2):
			var tile = Vector2i(x, y)
			if reserved.has(tile): continue

			# ~18% chance of rock spawning per tile
			if randf() < 0.18:
				# Skip if already mined during this dungeon run
				if DungeonManager and DungeonManager.is_tile_cleared(floor_num, tile):
					continue

				var world_pos = _tile_to_world(tile) + Vector2(randf_range(-2, 2), randf_range(-2, 2))
				var roll = randf()
				var inst: Node2D = null

				if roll < ore_chance:
					# Spawn Cave Ore Rock (drops twilight ore)
					inst = SCENE_ORE_ROCK.instantiate()
				elif roll < 0.70:
					# Spawn Minable Stone
					var stone_packed = MINABLE_STONES[randi() % MINABLE_STONES.size()]
					inst = stone_packed.instantiate()
				else:
					# Spawn Gatherable Rock
					var gstone_packed = GATHERABLE_STONES[randi() % GATHERABLE_STONES.size()]
					inst = gstone_packed.instantiate()

				inst.global_position = world_pos
				interactables.add_child(inst)

				var cur_node = inst
				var cur_fl = floor_num
				var cur_t = tile
				cur_node.tree_exiting.connect(func():
					if is_instance_valid(cur_node) and "is_dead" in cur_node and cur_node.is_dead:
						if DungeonManager:
							DungeonManager.mark_tile_cleared(cur_fl, cur_t)
				)

func _create_boundary_walls(body: StaticBody2D, width: int, height: int) -> void:
	body.collision_layer = 1
	body.collision_mask = 0

	var thickness: float = 24.0

	# Top Wall
	var top_col = CollisionShape2D.new()
	var top_shape = RectangleShape2D.new()
	top_shape.size = Vector2(width * 16.0 + 32.0, thickness)
	top_col.shape = top_shape
	top_col.position = Vector2((width * 16.0) / 2.0, 8.0)
	body.add_child(top_col)

	# Bottom Wall
	var bot_col = CollisionShape2D.new()
	var bot_shape = RectangleShape2D.new()
	bot_shape.size = Vector2(width * 16.0 + 32.0, thickness)
	bot_col.shape = bot_shape
	bot_col.position = Vector2((width * 16.0) / 2.0, (height - 1) * 16.0 + 8.0)
	body.add_child(bot_col)

	# Left Wall
	var left_col = CollisionShape2D.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(thickness, height * 16.0 + 32.0)
	left_col.shape = left_shape
	left_col.position = Vector2(8.0, (height * 16.0) / 2.0)
	body.add_child(left_col)

	# Right Wall
	var right_col = CollisionShape2D.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(thickness, height * 16.0 + 32.0)
	right_col.shape = right_shape
	right_col.position = Vector2((width - 1) * 16.0 + 8.0, (height * 16.0) / 2.0)
	body.add_child(right_col)

func _tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * 16 + 8, tile.y * 16 + 8)
