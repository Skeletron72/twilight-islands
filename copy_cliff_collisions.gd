@tool
extends SceneTree

func _init():
	var ts = load("res://resources/cute_tileset.tres") as TileSet
	if not ts:
		print("Failed to load tileset!")
		quit()
		return
		
	var source_src = ts.get_source(16) as TileSetAtlasSource # Cliff 1
	var targets = [
		ts.get_source(11) as TileSetAtlasSource, # Cliff 2
		ts.get_source(10) as TileSetAtlasSource, # Cliff 3
		ts.get_source(13) as TileSetAtlasSource  # Cliff 4
	]
	
	if not source_src:
		print("Source 16 not found!")
		quit()
		return
		
	var copy_count = 0
	
	# Iterate over all tiles in source 16
	for y in range(0, 16):
		for x in range(0, 16):
			var coords = Vector2i(x, y)
			if source_src.has_tile(coords):
				var src_data = source_src.get_tile_data(coords, 0)
				# Physics layer 0 is where collisions are usually painted
				var poly_count = src_data.get_collision_polygons_count(0)
				
				# If this tile has collision polygons
				for target_src in targets:
					if target_src and target_src.has_tile(coords):
						var target_data = target_src.get_tile_data(coords, 0)
						
						# Clear existing polygons on target
						for i in range(target_data.get_collision_polygons_count(0)):
							target_data.remove_collision_polygon(0, 0)
							
						# Add polygons from source
						for i in range(poly_count):
							target_data.add_collision_polygon(0)
							var points = src_data.get_collision_polygon_points(0, i)
							target_data.set_collision_polygon_points(0, i, points)
							var one_way = src_data.is_collision_polygon_one_way(0, i)
							target_data.set_collision_polygon_one_way(0, i, one_way)
							var one_way_margin = src_data.get_collision_polygon_one_way_margin(0, i)
							target_data.set_collision_polygon_one_way_margin(0, i, one_way_margin)
							
				if poly_count > 0:
					copy_count += 1
					
	print("Copied collisions for ", copy_count, " tiles to the other 3 cliff atlases.")
	
	ResourceSaver.save(ts, "res://resources/cute_tileset.tres")
	print("Saved cute_tileset.tres")
	quit()
