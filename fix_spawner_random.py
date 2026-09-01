import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Change the call in _generate_all for stone
old_call = """	_spawn_clusters(stone_count, "res://scenes/objects/stone.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4*cl_mult, 150.0, 32.0, noise, -1)"""
new_call = """	_spawn_clusters(stone_count, "res://scenes/objects/stone_%d.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4*cl_mult, 150.0, 32.0, noise, -1)"""
content = content.replace(old_call, new_call)

# Modify _spawn_clusters to handle %d
old_spawn = """func _spawn_clusters(amount: int, scene_path: String, name_prefix: String, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, resource_id: String, cluster_count: int, cluster_radius: float, min_dist: float = 12.0, noise: FastNoiseLite = null, biome: int = 0) -> void:
	var obj_scene = ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not obj_scene: return
	
	var world_map = _get_world_map()"""

new_spawn = """func _spawn_clusters(amount: int, scene_path: String, name_prefix: String, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, resource_id: String, cluster_count: int, cluster_radius: float, min_dist: float = 12.0, noise: FastNoiseLite = null, biome: int = 0) -> void:
	var world_map = _get_world_map()
	
	var base_scene = null
	if not "%d" in scene_path:
		base_scene = ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if not base_scene: return"""

content = content.replace(old_spawn, new_spawn)

old_inst = """				spawned_positions.append(test_pos)
				var inst = obj_scene.instantiate()"""

new_inst = """				spawned_positions.append(test_pos)
				
				var actual_path = scene_path
				var current_scene_res = base_scene
				if "%d" in scene_path:
					actual_path = scene_path % rng.randi_range(1, 14)
					current_scene_res = ResourceLoader.load(actual_path, "", ResourceLoader.CACHE_MODE_IGNORE)
				
				if not current_scene_res: continue
				
				var inst = current_scene_res.instantiate()"""

content = content.replace(old_inst, new_inst)

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
