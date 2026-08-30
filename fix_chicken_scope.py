import re

with open('scripts/components/chicken.gd', 'r') as f:
    content = f.read()

# Replace the problematic scope block
old_block = """		var current_scene = get_tree().current_scene
		var world_map = current_scene.get_node_or_null("WorldMap")
		if world_map:
			var water_layer = world_map.get_node_or_null("WaterLayer")
			if water_layer:"""

new_block = """		var current_scene = get_tree().current_scene
		var world_map = current_scene.get_node_or_null("WorldMap")
		var water_layer = world_map.get_node_or_null("WaterLayer") if world_map else null
		
		if water_layer:"""

content = content.replace(old_block, new_block)

# Since I used 'if water_layer:' it's now in the scope of `if direction != Vector2.ZERO:`.
# Line 57 is `if water_layer:`, which is exactly right because `water_layer` is now defined under `if direction != Vector2.ZERO:`.
with open('scripts/components/chicken.gd', 'w') as f:
    f.write(content)

