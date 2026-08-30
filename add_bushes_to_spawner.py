import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

old_vars = """	var ore_count = 2 if is_home else 15
	var stick_count = 10 if is_home else 25"""

new_vars = """	var ore_count = 2 if is_home else 15
	var stick_count = 10 if is_home else 25
	var red_bush_count = 6 if is_home else 15
	var yellow_bush_count = 6 if is_home else 15"""

old_spawn = """	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedSmallStone_", is_home, parent_node, rng, "stone", 5, 150.0, 16.0)"""

new_spawn = """	_spawn_clusters(stick_count, "res://scenes/objects/gatherable.tscn", "SpawnedSmallStone_", is_home, parent_node, rng, "stone", 5, 150.0, 16.0)
	
	_spawn_clusters(red_bush_count, "res://scenes/objects/berry_bush.tscn", "SpawnedRedBush_", is_home, parent_node, rng, "red_bush", 4, 100.0, 24.0)
	_spawn_clusters(yellow_bush_count, "res://scenes/objects/berry_bush.tscn", "SpawnedYellowBush_", is_home, parent_node, rng, "yellow_bush", 4, 100.0, 24.0)"""

content = content.replace(old_vars, new_vars)
content = content.replace(old_spawn, new_spawn)

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
