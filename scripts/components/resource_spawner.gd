@tool
extends Node2D
class_name ResourceSpawner

@export var spawn_area: Rect2 = Rect2(-200, -200, 1500, 1500) 

@export var generate_now: bool = false:
	set(val):
		generate_now = false
		if val:
			print("GENERATE BUTTON CLICKED! is_inside_tree: ", is_inside_tree())
			if is_inside_tree():
				print("CALLING _generate_all()")
				_generate_all()

@export var clear_now: bool = false:
	set(val):
		clear_now = false
		if val and is_inside_tree():
			_clear_all()

var spawned_positions: Array[Vector2] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		await get_tree().process_frame
		var parent = _get_parent_node()
		var has_baked = false
		if parent:
			for child in parent.get_children():
				if child.name.begins_with("Spawned"):
					has_baked = true
					break
		
		if not has_baked:
			_generate_all()

func _clear_all() -> void:
	var parent_node = _get_parent_node()
	if not parent_node: return
	
	for child in parent_node.get_children():
		if child.name.begins_with("Spawned"):
			child.queue_free()
	spawned_positions.clear()

func _get_parent_node() -> Node:
	var current_scene = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not current_scene: return null
	
	var parent_node = current_scene.get_node_or_null("Interactables")
	if not parent_node:
		parent_node = current_scene
	return parent_node

func _get_world_map() -> Node:
	var current_scene = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not current_scene: return null
	return current_scene.get_node_or_null("WorldMap")

func _generate_all() -> void:
	print("STARTING _generate_all")
	_clear_all()
	
	var current_scene = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	print("CURRENT SCENE: ", current_scene)
	if not current_scene: return
	var is_home = (current_scene.name == "HomeIsland")
	print("IS HOME: ", is_home)
	
	var parent_node = _get_parent_node()
	var world_map = _get_world_map()
	
	if world_map:
		var ground = world_map.get_node_or_null("GroundLayer")
		if ground:
			var used_rect = ground.get_used_rect()
			var top_left = ground.map_to_local(used_rect.position)
			var bottom_right = ground.map_to_local(used_rect.end)
			spawn_area = Rect2(top_left, bottom_right - top_left)

	var rng = RandomNumberGenerator.new()
	if is_home:
		rng.randomize()
	else:
		rng.randomize()

		# Scale by area (assuming home island is roughly 500x500 = 250000)
	var area = spawn_area.size.x * spawn_area.size.y
	var mult = max(1.0, area / 250000.0) if not is_home else 1.0

	var stone_count = int(8 * mult) if is_home else int(40 * mult)
	var tree_count = int(25 * mult) if is_home else int(150 * mult)

	var noise = FastNoiseLite.new()
	noise.seed = rng.randi()
	noise.frequency = 0.003 # Large biomes

	var cl_mult = max(1, int(mult * 0.75)) # scale cluster counts too
	
	_spawn_clusters(stone_count, "res://scenes/objects/stones/stone_%d.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4*cl_mult, 150.0, 32.0, noise, -1)
	_spawn_trees(tree_count, is_home, parent_node, rng, cl_mult, noise)

func _spawn_clusters(amount: int, scene_path: String, name_prefix: String, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, resource_id: String, cluster_count: int, cluster_radius: float, min_dist: float = 12.0, noise: FastNoiseLite = null, biome: int = 0) -> void:
	var world_map = _get_world_map()
	
	var base_scene = null
	if not "%d" in scene_path:
		base_scene = ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if not base_scene: return
	
	var centers = []
	for i in range(cluster_count):
		for j in range(500):
			var center_pos = Vector2(
				spawn_area.position.x + rng.randf() * spawn_area.size.x,
				spawn_area.position.y + rng.randf() * spawn_area.size.y
			)
			if _is_valid_spawn(center_pos, world_map):
				if noise != null:
					var n_val = noise.get_noise_2d(center_pos.x, center_pos.y)
					if biome == 1 and n_val < 0.1: continue # Forest
					if biome == -1 and n_val > -0.1: continue # Plains/Rocks
				centers.append(center_pos)
				break
				
	if centers.is_empty():
		centers.append(spawn_area.position + spawn_area.size / 2.0)
		
	var spawned = 0
	var attempts = 0
	
	while spawned < amount and attempts < amount * 50:
		attempts += 1
		var center = centers[rng.randi() % centers.size()]
		
		var angle = rng.randf() * PI * 2.0
		var radius = rng.randf() * cluster_radius
		var test_pos = center + Vector2(cos(angle), sin(angle)) * radius
		
		if _is_valid_spawn(test_pos, world_map):
			var too_close = false
			for p in spawned_positions:
				if p.distance_to(test_pos) < min_dist:
					too_close = true
					break
			if not too_close:
				spawned_positions.append(test_pos)
				
				var actual_path = scene_path
				var current_scene_res = base_scene
				if "%d" in scene_path:
					actual_path = scene_path % rng.randi_range(1, 14)
					current_scene_res = ResourceLoader.load(actual_path, "", ResourceLoader.CACHE_MODE_IGNORE)
				
				if not current_scene_res: continue
				
				var inst = current_scene_res.instantiate()
				inst.name = name_prefix + str(spawned)
				inst.position = test_pos
				if "is_permanent" in inst:
					inst.is_permanent = is_home
				
				if resource_id != "":
					inst.set("resource_id", resource_id)
					
				parent_node.add_child(inst)
				
				# Very important: set owner so they get saved to the scene in editor
				if Engine.is_editor_hint():
					inst.owner = get_tree().edited_scene_root
					
				spawned += 1
	if spawned == 0 and attempts > 0:
		print("Spawned 0 of ", name_prefix, " | Last fail reason: ", _last_fail_reason)
	else:
		print("Spawned ", spawned, " of ", name_prefix)

var _last_fail_reason = ""

func _is_valid_spawn(pos: Vector2, world_map: Node) -> bool:
	if not world_map: return true 
	
	var ground = world_map.get_node_or_null("GroundLayer")
	var water = world_map.get_node_or_null("WaterLayer")
	var roads = world_map.get_node_or_null("RoadsLayer")
	var objects = world_map.get_node_or_null("ObjectsLayer")
	var houses = world_map.get_node_or_null("HousesLayer")
	var mountains_tops = world_map.get_node_or_null("MountainsTopsLayer")
	var mountains_borders = world_map.get_node_or_null("MountainsBordersLayer")
	
	if not ground: return true
	
	var map_pos = ground.local_to_map(pos)
	
	# removed water check to avoid background fill blocking everything
	if roads and roads.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "roads"
		return false
	if objects and objects.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "objects"
		return false
	if houses and houses.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "houses"
		return false
	if mountains_borders and mountains_borders.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "mountains_borders"
		return false
	
	var on_ground = (ground.get_cell_source_id(map_pos) != -1)
	var on_mountain = (mountains_tops and mountains_tops.get_cell_source_id(map_pos) != -1)
	
	if not on_ground and not on_mountain:
		_last_fail_reason = "not on ground or mountain"
		return false
		
	if on_ground:
		var coords = ground.get_cell_atlas_coords(map_pos)
		if coords == Vector2i(5, 1) or coords == Vector2i(7, 1) or coords == Vector2i(8, 1) or coords == Vector2i(9, 1):
			_last_fail_reason = "sand tile " + str(coords)
			return false
			
	return true

func _spawn_trees(amount: int, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, cl_mult: int, noise: FastNoiseLite) -> void:
	var tree_types = ["oak", "birch", "spruce", "fruit"]
	var tree_sizes = ["small", "medium", "big"]
	var world_map = _get_world_map()
	
	var centers = []
	for i in range(12 * cl_mult):
		for j in range(500):
			var center_pos = Vector2(
				spawn_area.position.x + rng.randf() * spawn_area.size.x,
				spawn_area.position.y + rng.randf() * spawn_area.size.y
			)
			if _is_valid_spawn(center_pos, world_map):
				var n_val = noise.get_noise_2d(center_pos.x, center_pos.y)
				if n_val < 0.1: continue # Only spawn in forests
				centers.append(center_pos)
				break
				
	if centers.is_empty():
		centers.append(spawn_area.position + spawn_area.size / 2.0)
		
	var spawned = 0
	var attempts = 0
	
	while spawned < amount and attempts < amount * 50:
		attempts += 1
		var center = centers[rng.randi() % centers.size()]
		
		var angle = rng.randf() * PI * 2.0
		var radius = rng.randf() * 180.0
		var test_pos = center + Vector2(cos(angle), sin(angle)) * radius
		
		if _is_valid_spawn(test_pos, world_map):
			var too_close = false
			for p in spawned_positions:
				if p.distance_to(test_pos) < 24.0:
					too_close = true
					break
			if not too_close:
				spawned_positions.append(test_pos)
				
				var t_type = tree_types[rng.randi() % tree_types.size()]
				var t_size = tree_sizes[rng.randi() % tree_sizes.size()]
				var scene_path = "res://scenes/objects/trees/" + t_size + "_" + t_type + ".tscn"
				
				var obj_scene = ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
				if not obj_scene: continue
				
				var inst = obj_scene.instantiate()
				inst.name = "SpawnedTree_" + str(spawned)
				inst.position = test_pos
				parent_node.add_child(inst)
				
				if Engine.is_editor_hint():
					inst.owner = get_tree().edited_scene_root
					
				spawned += 1
	print("Spawned ", spawned, " Trees")
