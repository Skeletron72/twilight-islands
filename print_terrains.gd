@tool
extends EditorScript
func _run():
	var ts = load("res://resources/cute_tileset.tres") as TileSet
	if not ts: return
	for i in range(ts.get_terrains_count(0)):
		print(i, ": ", ts.get_terrain_name(0, i))
