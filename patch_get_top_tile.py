import re

file_path = "scripts/components/biome_service.gd"
with open(file_path, "r") as f:
    content = f.read()

# We want to replace everything from `if layer_name == "RoadsLayer":`
# down to the end of the `for layer_name in LAYER_PRIORITY:` block.

start_pattern = r'# Если мы наткнулись на дорогу — отмечаем поверхность как камень/дорога,\n\t\t# но продолжаем искать под ней биом грунта для underlying_biome!'
end_pattern = r'\treturn result\n\n## Быстрое'

start_idx = content.find('# Если мы наткнулись на дорогу — отмечаем поверхность как камень/дорога,')
end_idx = content.find('return result\n\n## Быстрое', start_idx)

if start_idx != -1 and end_idx != -1:
    new_loop = """# Слой дорог - если мы тут, значит мы стоим на мосту или дороге
		if layer_name == "RoadsLayer":
			result["is_road"] = true
			if result["surface"] == SurfaceType.VOID:
				result["surface"] = SurfaceType.STONE
			if result["layer_name"] == "":
				result["layer_name"] = "RoadsLayer"
				result["layer"] = layer
				result["map_pos"] = map_pos
				result["source_id"] = source_id
				result["cell_data"] = cell_data
			continue # Идем глубже, чтобы понять биом

		# Ниже идет логика для остальных слоев
		var current_layer_biome = "void"
		var current_is_water = false
		var current_surface_type = SurfaceType.VOID
		var current_can_hoe = false
		
		if layer_name == "WaterLayer":
			current_is_water = true
			current_surface_type = SurfaceType.WATER
			current_layer_biome = "water"
		elif layer_name == "OceanLayer":
			current_is_water = true
			current_surface_type = SurfaceType.WATER
			current_layer_biome = "ocean"
		else:
			current_layer_biome = _resolve_biome_from_cell(cell_data)
			if layer_name == "ShoreLayer" and (current_layer_biome == "clearing" or current_layer_biome == "void"):
				current_layer_biome = "beach"
			
			if current_layer_biome == "beach":
				current_is_water = false
			else:
				current_is_water = cell_data.get_custom_data("is_water") == true
				
			current_can_hoe = cell_data.get_custom_data("can_hoe") == true
			current_surface_type = SurfaceType.WATER if current_is_water else (SurfaceType.GRASS if layer_name != "ShoreLayer" else SurfaceType.DIRT)

		# Если мы уже стоим на дороге/мосту, мы просто обновляем биом и возвращаем результат
		if result["is_road"]:
			result["underlying_biome"] = current_layer_biome
			result["biome"] = current_layer_biome
			return result
			
		# Иначе, это и есть наш топовый слой!
		result["biome"] = current_layer_biome
		result["is_water"] = current_is_water
		result["surface"] = current_surface_type
		result["can_hoe"] = current_can_hoe
		result["layer_name"] = layer_name
		result["layer"] = layer
		result["map_pos"] = map_pos
		result["source_id"] = source_id
		result["cell_data"] = cell_data
		return result

	"""
    content = content[:start_idx] + new_loop + content[end_idx:]
    with open(file_path, "w") as f:
        f.write(content)
    print("Patched get_top_tile_info successfully.")
else:
    print("Could not find the start or end index.")
