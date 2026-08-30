import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# 1. Add swimming to anim_data
if '"swimming":' not in content:
    content = content.replace('"walk": {"folder": "WALK", "frames": 8, "fps": 12},', '"walk": {"folder": "WALK", "frames": 8, "fps": 12},\n\t"swimming": {"folder": "SWIMMING", "frames": 8, "fps": 10},')

# 2. Inject water detection and animation logic in _physics_process
# Let's completely replace the block from "if direction.length() > 0:" down to "else:"
# Wait, we need to be careful with indentation.

replacement_logic = """
	var in_water = false
	var current_scene = get_tree().current_scene
	var water_layer = current_scene.get_node_or_null("WorldMap/WaterLayer")
	var ground_layer = current_scene.get_node_or_null("WorldMap/GroundLayer")
	if water_layer and ground_layer:
		var map_pos = water_layer.local_to_map(global_position)
		if water_layer.get_cell_source_id(map_pos) != -1 and ground_layer.get_cell_source_id(map_pos) == -1:
			in_water = true

	if direction.length() > 0:
		if direction.x != 0:
			visuals.scale.x = -1 if direction.x < 0 else 1
			
		if in_water:
			velocity = direction.normalized() * (speed * 0.5)
			_play_anim("swimming")
		elif is_sprinting:
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")
		else:
			velocity = direction.normalized() * speed
			_play_anim("walk")
	else:
		velocity = Vector2.ZERO
		if in_water:
			_play_anim("swimming")
		else:
			_play_anim("idle")
"""

# Regex to match the old direction logic
old_logic_pattern = r'(\t)*if direction.length\(\) > 0:[\s\S]*?\telse:\n(\t)*velocity = Vector2\.ZERO\n(\t)*_play_anim\("idle"\)'

content = re.sub(old_logic_pattern, replacement_logic, content)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
