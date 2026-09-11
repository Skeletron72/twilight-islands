@tool
extends EditorScript

func _run():
	var ts = load("res://resources/cute_tileset.tres") as TileSet
	if not ts:
		print("Failed to load tileset")
		return
		
	var source = ts.get_source(16) as TileSetAtlasSource
	if not source:
		print("Source 16 not found")
		return
		
	var tiles_to_check = [Vector2i(1,3), Vector2i(2,3), Vector2i(1,5)]
	for coords in tiles_to_check:
		if source.has_tile(coords):
			var tile_data = source.get_tile_data(coords, 0)
			print("Tile ", coords, " terrain_set: ", tile_data.terrain_set, ", terrain: ", tile_data.terrain)
		else:
			print("Tile ", coords, " does not exist")
