@tool
extends SceneTree

func _init():
	var ts: TileSet = load("res://resources/cute_tileset.tres")
	var source: TileSetAtlasSource = ts.get_source(25)
	print("Source 25 tile count:", source.get_tiles_count())
	var tiles = []
	for i in range(source.get_tiles_count()):
		tiles.append(source.get_tile_id(i))
	print("All tiles in source 25:")
	for t in tiles:
		print(t)
	quit()
