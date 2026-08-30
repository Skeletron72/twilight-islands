import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Add spruce count
content = content.replace('var tree_count = 15 if is_home else 80', 'var tree_count = 15 if is_home else 80\n\tvar spruce_count = 10 if is_home else 40')

# Spawn spruce trees
content = content.replace('_spawn_clusters(tree_count, "res://scenes/objects/tree.tscn", "SpawnedTree_", is_home, parent_node, rng, "", 6, 200.0, 32.0)', '_spawn_clusters(tree_count, "res://scenes/objects/tree.tscn", "SpawnedTree_", is_home, parent_node, rng, "", 6, 200.0, 32.0)\n\t_spawn_clusters(spruce_count, "res://scenes/objects/spruce_tree.tscn", "SpawnedSpruce_", is_home, parent_node, rng, "", 4, 200.0, 32.0)')

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
