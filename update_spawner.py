import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Add spawned_positions state
content = content.replace('func _ready() -> void:', 'var spawned_positions: Array[Vector2] = []\n\nfunc _ready() -> void:')

# Update _spawn_clusters signature and calls
old_calls = """	_spawn_clusters(tree_count, "res://scenes/objects/tree.tscn", "SpawnedTree_", is_home, parent_node, rng, "", 6, 200.0)
	_spawn_clusters(stone_count, "res://scenes/objects/stone.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4, 120.0)
	_spawn_clusters(ore_count, "res://scenes/levels/twilight_ore.tscn", "SpawnedOre_", is_home, parent_node, rng, "", 3, 100.0)
	
	# Ветки и мелкие камни просто раскидываем более-менее кучно
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedStick_", is_home, parent_node, rng, "stick", 5, 150.0)
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedSmallStone_", is_home, parent_node, rng, "stone", 5, 150.0)"""

new_calls = """	_spawn_clusters(tree_count, "res://scenes/objects/tree.tscn", "SpawnedTree_", is_home, parent_node, rng, "", 6, 200.0, 32.0)
	_spawn_clusters(stone_count, "res://scenes/objects/stone.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4, 120.0, 32.0)
	_spawn_clusters(ore_count, "res://scenes/levels/twilight_ore.tscn", "SpawnedOre_", is_home, parent_node, rng, "", 3, 100.0, 32.0)
	
	# Ветки и мелкие камни просто раскидываем более-менее кучно
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedStick_", is_home, parent_node, rng, "stick", 5, 150.0, 16.0)
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedSmallStone_", is_home, parent_node, rng, "stone", 5, 150.0, 16.0)"""

content = content.replace(old_calls, new_calls)

old_def = 'func _spawn_clusters(amount: int, scene_path: String, name_prefix: String, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, resource_id: String, cluster_count: int, cluster_radius: float) -> void:'
new_def = 'func _spawn_clusters(amount: int, scene_path: String, name_prefix: String, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, resource_id: String, cluster_count: int, cluster_radius: float, min_dist: float = 24.0) -> void:'
content = content.replace(old_def, new_def)


old_loop = """		if _is_valid_spawn(test_pos, world_map):
			var inst = obj_scene.instantiate()
			inst.name = name_prefix + str(spawned)
			inst.position = test_pos
			if "is_permanent" in inst:
				inst.is_permanent = is_home
			
			if resource_id != "" and "resource_id" in inst:
				inst.resource_id = resource_id
				
			parent_node.call_deferred("add_child", inst)
			spawned += 1"""

new_loop = """		if _is_valid_spawn(test_pos, world_map):
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
				spawned += 1"""
				
content = content.replace(old_loop, new_loop)

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
