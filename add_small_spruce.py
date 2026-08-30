import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Add small_spruce count
content = content.replace('\tvar spruce_count = 10 if is_home else 40', '\tvar spruce_count = 10 if is_home else 40\n\tvar small_spruce_count = 10 if is_home else 30')

# Spawn small_spruce trees
content = content.replace('_spawn_clusters(spruce_count, "res://scenes/objects/spruce_tree.tscn", "SpawnedSpruce_", is_home, parent_node, rng, "", 4, 200.0, 32.0)', '_spawn_clusters(spruce_count, "res://scenes/objects/spruce_tree.tscn", "SpawnedSpruce_", is_home, parent_node, rng, "", 4, 200.0, 32.0)\n\t_spawn_clusters(small_spruce_count, "res://scenes/objects/small_spruce.tscn", "SpawnedSmallSpruce_", is_home, parent_node, rng, "", 4, 150.0, 24.0)')

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
