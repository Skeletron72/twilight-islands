import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Add small_bush count
content = content.replace('\tvar small_spruce_count = 10 if is_home else 30', '\tvar small_spruce_count = 10 if is_home else 30\n\tvar small_bush_count = 15 if is_home else 40')

# Spawn small_bush
content = content.replace('_spawn_clusters(small_spruce_count, "res://scenes/objects/small_spruce.tscn", "SpawnedSmallSpruce_", is_home, parent_node, rng, "", 4, 150.0, 24.0)', '_spawn_clusters(small_spruce_count, "res://scenes/objects/small_spruce.tscn", "SpawnedSmallSpruce_", is_home, parent_node, rng, "", 4, 150.0, 24.0)\n\t_spawn_clusters(small_bush_count, "res://scenes/objects/small_bush.tscn", "SpawnedSmallBush_", is_home, parent_node, rng, "", 6, 150.0, 16.0)')

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
