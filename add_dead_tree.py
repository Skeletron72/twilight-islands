import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Add dead_tree count
content = content.replace('\tvar small_spruce_count = 10 if is_home else 30', '\tvar small_spruce_count = 10 if is_home else 30\n\tvar dead_tree_count = 5 if is_home else 20')

# Spawn dead_tree
content = content.replace('_spawn_clusters(small_spruce_count, "res://scenes/objects/small_spruce.tscn", "SpawnedSmallSpruce_", is_home, parent_node, rng, "", 4, 150.0, 24.0)', '_spawn_clusters(small_spruce_count, "res://scenes/objects/small_spruce.tscn", "SpawnedSmallSpruce_", is_home, parent_node, rng, "", 4, 150.0, 24.0)\n\t_spawn_clusters(dead_tree_count, "res://scenes/objects/dead_tree.tscn", "SpawnedDeadTree_", is_home, parent_node, rng, "", 3, 200.0, 32.0)')

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
