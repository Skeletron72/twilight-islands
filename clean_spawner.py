import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# We only want to keep stone_count logic
# I'll replace the block where counts are calculated and spawned
old_spawns = """	var tree_count = int(12 * mult) if is_home else int(80 * mult)
	var spruce_count = int(10 * mult) if is_home else int(60 * mult)
	var small_spruce_count = int(8 * mult) if is_home else int(40 * mult)
	var dead_tree_count = int(4 * mult) if is_home else int(20 * mult)
	var small_bush_count = int(12 * mult) if is_home else int(60 * mult)
	var stone_count = int(8 * mult) if is_home else int(40 * mult)
	var ore_count = int(3 * mult) if is_home else int(15 * mult)
	var stick_count = int(12 * mult) if is_home else int(50 * mult)
	var red_bush_count = int(8 * mult) if is_home else int(25 * mult)
	var yellow_bush_count = int(8 * mult) if is_home else int(25 * mult)

	var noise = FastNoiseLite.new()
	noise.seed = rng.randi()
	noise.frequency = 0.003 # Large biomes

	var cl_mult = max(1, int(mult * 0.75)) # scale cluster counts too
	
	# Denser clusters (smaller radius), strong min_dist, biome based
	_spawn_clusters(tree_count, "res://scenes/objects/tree.tscn", "SpawnedTree_", is_home, parent_node, rng, "", 3*cl_mult, 150.0, 32.0, noise, 1)
	_spawn_clusters(spruce_count, "res://scenes/objects/spruce_tree.tscn", "SpawnedSpruce_", is_home, parent_node, rng, "", 3*cl_mult, 150.0, 32.0, noise, 1)
	_spawn_clusters(small_spruce_count, "res://scenes/objects/small_spruce.tscn", "SpawnedSmallSpruce_", is_home, parent_node, rng, "", 3*cl_mult, 120.0, 24.0, noise, 1)
	_spawn_clusters(dead_tree_count, "res://scenes/objects/dead_tree.tscn", "SpawnedDeadTree_", is_home, parent_node, rng, "", 2*cl_mult, 120.0, 32.0, noise, 1)
	
	_spawn_clusters(small_bush_count, "res://scenes/objects/small_bush.tscn", "SpawnedSmallBush_", is_home, parent_node, rng, "", 5*cl_mult, 120.0, 20.0, noise, -1)
	_spawn_clusters(stone_count, "res://scenes/objects/stones/stone_%d.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4*cl_mult, 150.0, 32.0, noise, -1)
	_spawn_clusters(ore_count, "res://scenes/levels/twilight_ore.tscn", "SpawnedOre_", is_home, parent_node, rng, "", 3*cl_mult, 100.0, 32.0, noise, -1)
	
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedStick_", is_home, parent_node, rng, "stick", 5*cl_mult, 120.0, 16.0, noise, 0)
	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedSmallStone_", is_home, parent_node, rng, "stone", 5*cl_mult, 120.0, 16.0, noise, 0)
	
	_spawn_clusters(red_bush_count, "res://scenes/objects/berry_bush.tscn", "SpawnedRedBush_", is_home, parent_node, rng, "red_bush", 3*cl_mult, 80.0, 32.0, noise, 0)
	_spawn_clusters(yellow_bush_count, "res://scenes/objects/berry_bush.tscn", "SpawnedYellowBush_", is_home, parent_node, rng, "yellow_bush", 3*cl_mult, 80.0, 32.0, noise, 0)"""

new_spawns = """	var stone_count = int(8 * mult) if is_home else int(40 * mult)

	var noise = FastNoiseLite.new()
	noise.seed = rng.randi()
	noise.frequency = 0.003 # Large biomes

	var cl_mult = max(1, int(mult * 0.75)) # scale cluster counts too
	
	_spawn_clusters(stone_count, "res://scenes/objects/stones/stone_%d.tscn", "SpawnedStoneB_", is_home, parent_node, rng, "", 4*cl_mult, 150.0, 32.0, noise, -1)"""

content = content.replace(old_spawns, new_spawns)

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
