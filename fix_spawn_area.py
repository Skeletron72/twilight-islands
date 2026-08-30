import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Locate _ready() and inject dynamic spawn_area calculation
old_ready = """func _ready() -> void:
	await get_tree().process_frame
	
	var is_home = (get_tree().current_scene.name == "HomeIsland")
	var parent_node = get_tree().current_scene.get_node_or_null("Interactables")
	
	if not parent_node:
		parent_node = get_tree().current_scene"""

new_ready = """func _ready() -> void:
	await get_tree().process_frame
	
	var is_home = (get_tree().current_scene.name == "HomeIsland")
	var parent_node = get_tree().current_scene.get_node_or_null("Interactables")
	
	if not parent_node:
		parent_node = get_tree().current_scene
		
	# Динамически вычисляем spawn_area на основе нарисованной карты
	var world_map = get_tree().current_scene.get_node_or_null("WorldMap")
	if world_map:
		var ground = world_map.get_node_or_null("GroundLayer")
		if ground:
			var used_rect = ground.get_used_rect()
			var top_left = ground.map_to_local(used_rect.position)
			var bottom_right = ground.map_to_local(used_rect.end)
			spawn_area = Rect2(top_left, bottom_right - top_left)
"""

content = content.replace(old_ready, new_ready)

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)

