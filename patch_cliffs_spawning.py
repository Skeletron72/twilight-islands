import sys

file_path = "scripts/components/biome_service.gd"
with open(file_path, "r") as f:
    content = f.read()

# 1. Update LAYER_PRIORITY
old_layer = 'const LAYER_PRIORITY = ["ObjectsLayer", "GroundDecorationLayer", "RoadsLayer", "WaterLayer", "GrassLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]'
new_layer = 'const LAYER_PRIORITY = ["ObjectsLayer", "GroundDecorationLayer", "RoadsLayer", "CliffsLayer", "WaterLayer", "GrassLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]'
content = content.replace(old_layer, new_layer)

# 2. Add cliffs_layer to all_coords
old_all_coords = """	if grass_layer:
		for cell in grass_layer.get_used_cells():
			all_coords[cell] = true

	for cell in all_coords.keys():"""
new_all_coords = """	if grass_layer:
		for cell in grass_layer.get_used_cells():
			all_coords[cell] = true
	if cliffs_layer:
		for cell in cliffs_layer.get_used_cells():
			all_coords[cell] = true

	for cell in all_coords.keys():"""
content = content.replace(old_all_coords, new_all_coords)

# 3. Fix the cliffs_layer blocking check
old_block = """			if houses_layer and houses_layer.get_cell_source_id(cell) != -1:
				continue
			if cliffs_layer and cliffs_layer.get_cell_source_id(cell) != -1:
				continue
			if water_layer"""
new_block = """			if houses_layer and houses_layer.get_cell_source_id(cell) != -1:
				continue
			if cliffs_layer and cliffs_layer.get_cell_source_id(cell) != -1:
				var cdata = cliffs_layer.get_cell_tile_data(cell)
				if cdata and cdata.get_collision_polygons_count(0) > 0:
					continue
			if water_layer"""
content = content.replace(old_block, new_block)

# 4. Priority extraction
old_extract = """		# Приоритет слоев: GrassLayer -> GroundLayer -> ShoreLayer
		if grass_layer and grass_layer.get_cell_source_id(cell) != -1:"""
new_extract = """		# Приоритет слоев: CliffsLayer -> GrassLayer -> GroundLayer -> ShoreLayer
		if cliffs_layer and cliffs_layer.get_cell_source_id(cell) != -1:
			var cell_data = cliffs_layer.get_cell_tile_data(cell)
			var b = _resolve_biome_from_cell(cell_data)
			if not result.has(b):
				result[b] = []
			result[b].append(cell)
		elif grass_layer and grass_layer.get_cell_source_id(cell) != -1:"""
content = content.replace(old_extract, new_extract)

with open(file_path, "w") as f:
    f.write(content)
print("Biome service patched for cliffs!")
