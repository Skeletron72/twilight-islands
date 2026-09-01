import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

old_spawns = """	var stone_count = int(8 * mult) if is_home else int(40 * mult)

	var noise = FastNoiseLite.new()
	noise.seed = rng.randi()
	noise.frequency = 0.003 # Large biomes

	var cl_mult = max(1, int(mult * 0.75)) # scale cluster counts too
	
	_spawn_clusters(stone_count, "res://scenes/objects/stones/stone_%d.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4*cl_mult, 150.0, 32.0, noise, -1)"""

new_spawns = """	var stone_count = int(8 * mult) if is_home else int(40 * mult)
	var tree_count = int(25 * mult) if is_home else int(150 * mult)

	var noise = FastNoiseLite.new()
	noise.seed = rng.randi()
	noise.frequency = 0.003 # Large biomes

	var cl_mult = max(1, int(mult * 0.75)) # scale cluster counts too
	
	_spawn_clusters(stone_count, "res://scenes/objects/stones/stone_%d.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4*cl_mult, 150.0, 32.0, noise, -1)
	_spawn_trees(tree_count, is_home, parent_node, rng, cl_mult, noise)"""
content = content.replace(old_spawns, new_spawns)

# Append _spawn_trees function
tree_func = """
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
"""

content += tree_func

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
