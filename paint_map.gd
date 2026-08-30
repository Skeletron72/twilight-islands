extends SceneTree

func _init() -> void:
	print("Painting map...")
	var scene_path = "res://scenes/levels/home_island.tscn"
	var packed = load(scene_path)
	if not packed:
		print("Failed to load scene")
		quit()
		return
		
	var root = packed.instantiate()
	
	var water_layer = root.get_node("WorldMap/WaterLayer") as TileMapLayer
	var ground_layer = root.get_node("WorldMap/GroundLayer") as TileMapLayer
	
	if not water_layer or not ground_layer:
		print("Failed to find layers")
		quit()
		return
		
	# Clear existing
	water_layer.clear()
	ground_layer.clear()
	
	# Fill water (-10 to 40, -10 to 30)
	for x in range(-10, 45):
		for y in range(-10, 35):
			water_layer.set_cell(Vector2i(x, y), 0, Vector2i(4, 1))
			
	# Fill grass (5 to 30, 5 to 20)
	for x in range(5, 35):
		for y in range(5, 25):
			ground_layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 1))
			
	var err = PackedScene.new()
	err.pack(root)
	ResourceSaver.save(err, scene_path)
	print("Map painted successfully!")
	quit()
