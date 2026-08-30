extends Node2D
class_name ResourceSpawner

# Границы, где вообще можно пробовать спавнить
@export var spawn_area: Rect2 = Rect2(-200, -200, 1500, 1500) 

var spawned_positions: Array[Vector2] = []

func _ready() -> void:
	await get_tree().process_frame
	
	var is_home = (get_tree().current_scene.name == "HomeIsland")
	var parent_node = get_tree().current_scene.get_node_or_null("Interactables")
	
	if not parent_node:
		parent_node = get_tree().current_scene
		
	# Динамически вычисляем spawn_area на основе нарисованной карты
	var world_map = get_tree().current_scene.get_node_or_null("WorldMap")
	if world_map:
		var ground = world_map.get_node_or_null("GroundLayer")
		if ground:
			var used_rect = ground.get_used_rect()
			var top_left = ground.map_to_local(used_rect.position)
			var bottom_right = ground.map_to_local(used_rect.end)
			spawn_area = Rect2(top_left, bottom_right - top_left)

		
	var rng = RandomNumberGenerator.new()
	if is_home:
		rng.seed = hash("home_island_seed_123")
	else:
		rng.randomize()

	# Количество ресурсов зависит от острова (на рейде всего в разы больше!)
	var tree_count = 15 if is_home else 80
	var spruce_count = 10 if is_home else 40
	var small_spruce_count = 10 if is_home else 30
	var dead_tree_count = 5 if is_home else 20
	var small_bush_count = 15 if is_home else 40
	var stone_count = 8 if is_home else 35
	var ore_count = 2 if is_home else 15
	var stick_count = 10 if is_home else 25
	var red_bush_count = 6 if is_home else 15
	var yellow_bush_count = 6 if is_home else 15

	# Спавн кластерами (кучками/областями)
	# (Количество, Путь_до_сцены, Префикс, Дом_ли, Родитель, Рандом, ID_Ресурса, Кол-во_Областей, Радиус_Области)
	_spawn_clusters(tree_count, "res://scenes/objects/tree.tscn", "SpawnedTree_", is_home, parent_node, rng, "", 6, 200.0, 32.0)
	_spawn_clusters(spruce_count, "res://scenes/objects/spruce_tree.tscn", "SpawnedSpruce_", is_home, parent_node, rng, "", 4, 200.0, 32.0)
	_spawn_clusters(small_spruce_count, "res://scenes/objects/small_spruce.tscn", "SpawnedSmallSpruce_", is_home, parent_node, rng, "", 4, 150.0, 24.0)
	_spawn_clusters(dead_tree_count, "res://scenes/objects/dead_tree.tscn", "SpawnedDeadTree_", is_home, parent_node, rng, "", 3, 200.0, 32.0)
	_spawn_clusters(small_bush_count, "res://scenes/objects/small_bush.tscn", "SpawnedSmallBush_", is_home, parent_node, rng, "", 6, 150.0, 16.0)
	_spawn_clusters(stone_count, "res://scenes/objects/stone.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4, 120.0, 32.0)
	_spawn_clusters(ore_count, "res://scenes/levels/twilight_ore.tscn", "SpawnedOre_", is_home, parent_node, rng, "", 3, 100.0, 32.0)
	
	# Ветки и мелкие камни просто раскидываем более-менее кучно
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedStick_", is_home, parent_node, rng, "stick", 5, 150.0, 16.0)
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedSmallStone_", is_home, parent_node, rng, "stone", 5, 150.0, 16.0)
	
	_spawn_clusters(red_bush_count, "res://scenes/objects/berry_bush.tscn", "SpawnedRedBush_", is_home, parent_node, rng, "red_bush", 4, 100.0, 24.0)
	_spawn_clusters(yellow_bush_count, "res://scenes/objects/berry_bush.tscn", "SpawnedYellowBush_", is_home, parent_node, rng, "yellow_bush", 4, 100.0, 24.0)


func _spawn_clusters(amount: int, scene_path: String, name_prefix: String, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, resource_id: String, cluster_count: int, cluster_radius: float, min_dist: float = 24.0) -> void:
	var obj_scene = load(scene_path)
	if not obj_scene: return
	
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	
	# Ищем центры для "областей" (лесов, рудников)
	var centers = []
	for i in range(cluster_count):
		for j in range(50):
			var center_pos = Vector2(
				spawn_area.position.x + rng.randf() * spawn_area.size.x,
				spawn_area.position.y + rng.randf() * spawn_area.size.y
			)
			if _is_valid_spawn(center_pos, world_map):
				centers.append(center_pos)
				break
				
	if centers.is_empty():
		return
		
	var spawned = 0
	var attempts = 0
	
	while spawned < amount and attempts < amount * 15:
		attempts += 1
		var center = centers[rng.randi() % centers.size()]
		
		# Случайная точка внутри радиуса от центра области
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
				var inst = obj_scene.instantiate()
				inst.name = name_prefix + str(spawned)
				inst.position = test_pos
				if "is_permanent" in inst:
					inst.is_permanent = is_home
				
				if resource_id != "" and "resource_id" in inst:
					inst.resource_id = resource_id
					
				parent_node.call_deferred("add_child", inst)
				spawned += 1

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
	
	if roads and roads.get_cell_source_id(map_pos) != -1: return false
	if objects and objects.get_cell_source_id(map_pos) != -1: return false
	if houses and houses.get_cell_source_id(map_pos) != -1: return false
	if mountains_borders and mountains_borders.get_cell_source_id(map_pos) != -1: return false
	
	var on_ground = (ground.get_cell_source_id(map_pos) != -1)
	var on_mountain = (mountains_tops and mountains_tops.get_cell_source_id(map_pos) != -1)
	
	if not on_ground and not on_mountain:
		return false
		
	if on_ground:
		var coords = ground.get_cell_atlas_coords(map_pos)
		# Черный список координат песка (X, Y)
		if coords == Vector2i(5, 1) or coords == Vector2i(7, 1) or coords == Vector2i(8, 1) or coords == Vector2i(9, 1):
			return false
			
	return true
