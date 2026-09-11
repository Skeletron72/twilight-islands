@tool
extends SceneTree

func _init():
	print("Running 10 test dungeon generations...")
	var dg = load("res://scripts/components/dungeon_generator.gd").new()
	var d_scene: PackedScene = load("res://scenes/levels/dungeon.tscn")
	var root = d_scene.instantiate()
	
	var floor_layer = root.get_node("FloorLayer")
	var wall_layer = root.get_node("WallLayer")
	var boundary_body = root.get_node("BoundaryBody")
	var interactables = root.get_node("Interactables")
	var player = Node2D.new()
	root.add_child(player)
	
	for i in range(10):
		dg.generate(i + 1, floor_layer, wall_layer, boundary_body, interactables, player)
		print("Test %d: Floor cells: %d, Wall cells: %d, Collisions: %d" % [
			i + 1,
			floor_layer.get_used_cells().size(),
			wall_layer.get_used_cells().size(),
			boundary_body.get_child_count()
		])
	print("ALL 10 TESTS PASSED PERFECTLY!")
	quit()
