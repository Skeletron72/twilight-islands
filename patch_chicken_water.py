old = '''func _handle_water_avoidance() -> void:
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	var water_layer = world_map.get_node_or_null("WaterLayer") if world_map else null
	if water_layer:
		var next_pos = global_position + direction * 8.0 + Vector2(0, -2)
		var map_pos = water_layer.local_to_map(next_pos)
		if water_layer.get_cell_source_id(map_pos) != -1:
			var in_water = true
			for child in world_map.get_children():
				if child is TileMapLayer and child != water_layer:
					if child.get_cell_source_id(map_pos) != -1:
						in_water = false
						break
			if in_water:
				direction = -direction
				if current_state == State.MOVING_TO_BUSH:
					_pick_new_state()

func _ensure_water_safety() -> void:
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	var water_layer = world_map.get_node_or_null("WaterLayer") if world_map else null
	if not water_layer: return

	var map_pos = water_layer.local_to_map(global_position + Vector2(0, -2))
	var is_in_water = false
	if water_layer.get_cell_source_id(map_pos) != -1:
		is_in_water = true
		for child in world_map.get_children():
			if child is TileMapLayer and child != water_layer:
				if child.get_cell_source_id(map_pos) != -1:
					is_in_water = false
					break

	if is_in_water:
		global_position = last_safe_position
		if current_state == State.WALKING:
			direction = -direction
			_pick_new_state()
	else:
		last_safe_position = global_position'''

new = '''# Единая функция проверки воды — такая же как у игрока (через кастомную дату is_water)
func _is_water_at(pos: Vector2) -> bool:
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if not world_map: return false
	
	var check_layers = ["RoadsLayer", "WaterLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]
	for layer_name in check_layers:
		var layer = world_map.get_node_or_null(layer_name)
		if layer and layer is TileMapLayer:
			var map_pos = layer.local_to_map(pos)
			var cell_data = layer.get_cell_tile_data(map_pos)
			if cell_data:
				return cell_data.get_custom_data("is_water")
	return false # Нет тайла вообще — тоже не ходим

func _handle_water_avoidance() -> void:
	var next_pos = global_position + direction * 12.0 + Vector2(0, -4)
	if _is_water_at(next_pos):
		direction = -direction
		if current_state == State.MOVING_TO_BUSH:
			_pick_new_state()

func _ensure_water_safety() -> void:
	if _is_water_at(global_position + Vector2(0, -4)):
		global_position = last_safe_position
		if current_state == State.WALKING:
			direction = -direction
			_pick_new_state()
	else:
		last_safe_position = global_position'''

with open("scripts/components/chicken.gd", "r") as f:
    content = f.read()

if old in content:
    content = content.replace(old, new)
    with open("scripts/components/chicken.gd", "w") as f:
        f.write(content)
    print("Patched!")
else:
    print("ERROR: pattern not found")
