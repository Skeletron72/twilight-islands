import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Replace the water detection logic
old_logic_pattern = r'(\t)*var in_water = false[\s\S]*?in_water = true'

new_logic = """	var in_water = false
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if world_map:
		var water_layer = world_map.get_node_or_null("WaterLayer")
		if water_layer:
			var map_pos = water_layer.local_to_map(global_position + Vector2(0, -4))
			if water_layer.get_cell_source_id(map_pos) != -1:
				in_water = true
				for child in world_map.get_children():
					if child is TileMapLayer and child != water_layer:
						if child.get_cell_source_id(map_pos) != -1:
							in_water = false
							break"""

content = re.sub(old_logic_pattern, new_logic, content)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
