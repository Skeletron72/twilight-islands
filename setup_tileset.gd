extends SceneTree

func _init() -> void:
	print("Starting TileSet Generation...")
	var ts = TileSet.new()
	ts.tile_size = Vector2i(16, 16)
	
	# Create atlas source
	var atlas = TileSetAtlasSource.new()
	var texture = load("res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png")
	if texture:
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(16, 16)
		
		# We don't know exactly which tiles are valid, but we can try to auto-create them.
		# For a simple setup, let's just create tiles for the whole texture based on size.
		var w = texture.get_width() / 16
		var h = texture.get_height() / 16
		for x in range(w):
			for y in range(h):
				atlas.create_tile(Vector2i(x, y))
		
		ts.add_source(atlas, 0)
		
		var err = ResourceSaver.save(ts, "res://resources/tileset.tres")
		if err == OK:
			print("TileSet successfully saved to res://resources/tileset.tres")
		else:
			print("Failed to save TileSet, error code: ", err)
	else:
		print("Failed to load texture.")
	
	quit()
