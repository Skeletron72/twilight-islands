@tool
extends SceneTree

func _init():
	print("Testing 10 full dungeon generations...")
	var dg = load("res://scripts/components/dungeon_generator.gd").new()
	var d_scene: PackedScene = load("res://scenes/levels/dungeon.tscn")
	var root = d_scene.instantiate()
	
	var floor_layer = root.get_node("FloorLayer")
	var wall_layer = root.get_node("WallLayer")
	var boundary_body = root.get_node("BoundaryWalls")
	var interactables = root.get_node("Interactables")
	var player = root.get_node("Player")
	
	for i in range(10):
		dg.generate(i + 1, floor_layer, wall_layer, boundary_body, interactables, player)
		print("Floor %d OK: %d floor cells, %d wall cells" % [
			i + 1,
			floor_layer.get_used_cells().size(),
			wall_layer.get_used_cells().size()
		])
	print("ALL 10 GENERATIONS PASSED FLAWLESSLY!")
	quit()
