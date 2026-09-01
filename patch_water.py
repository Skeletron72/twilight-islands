import re

with open("scripts/components/player.gd", "r") as f:
    content = f.read()

old_logic = """	var in_water = false
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if world_map:
		for child in world_map.get_children():
			if child is TileMapLayer:
				var map_pos = child.local_to_map(global_position + Vector2(0, -4))
				var cell_data = child.get_cell_tile_data(map_pos)
				if cell_data and cell_data.get_custom_data("is_water") == true:
					in_water = true
					break"""

new_logic = """	var in_water = false
	var current_biome = ""
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if world_map:
		# Проверяем слои сверху вниз (от верхнего грунта к океану)
		var check_layers = ["RoadsLayer", "WaterLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]
		for layer_name in check_layers:
			var layer = world_map.get_node_or_null(layer_name)
			if layer and layer is TileMapLayer:
				var map_pos = layer.local_to_map(global_position + Vector2(0, -4))
				var cell_data = layer.get_cell_tile_data(map_pos)
				if cell_data:
					# Нашли самый верхний тайл, на котором стоит игрок!
					in_water = cell_data.get_custom_data("is_water")
					
					# Если у вас есть кастомная дата "biome" (тип String), мы можем читать ее здесь:
					# current_biome = cell_data.get_custom_data("biome")
					
					break # Прерываем поиск, так как нашли поверхность под ногами"""

if old_logic in content:
    content = content.replace(old_logic, new_logic)
    with open("scripts/components/player.gd", "w") as f:
        f.write(content)
    print("Patched!")
else:
    print("Not found!")
