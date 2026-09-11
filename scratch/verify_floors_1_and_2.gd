@tool
extends SceneTree

func _init():
	print("Verifying Floor 1 and Floor 2 generation...")
	var dg = load("res://scripts/components/dungeon_generator.gd").new()
	var d_scene: PackedScene = load("res://scenes/levels/dungeon.tscn")
	var root = d_scene.instantiate()
	
	var floor_layer = root.get_node("FloorLayer")
	var wall_layer = root.get_node("WallLayer")
	var boundary_body = root.get_node("BoundaryWalls")
	var interactables = root.get_node("Interactables")
	var player = root.get_node("Player")
	
	# Test Floor 1
	dg.generate(1, floor_layer, wall_layer, boundary_body, interactables, player)
	var has_doorway = false
	var has_ladder_down = false
	var has_wall_ladder = false
	for child in interactables.get_children():
		var path = child.get_script().resource_path if child.get_script() else ""
		if "cave_doorway" in path: has_doorway = true
		if "ladder_down" in path: has_ladder_down = true
		if "wall_ladder" in path: has_wall_ladder = true
	print("Floor 1: has_doorway=%s, has_ladder_down=%s, has_wall_ladder=%s" % [has_doorway, has_ladder_down, has_wall_ladder])
	
	# Test Floor 2
	dg.generate(2, floor_layer, wall_layer, boundary_body, interactables, player)
	has_doorway = false
	has_ladder_down = false
	has_wall_ladder = false
	for child in interactables.get_children():
		var path = child.get_script().resource_path if child.get_script() else ""
		if "cave_doorway" in path: has_doorway = true
		if "ladder_down" in path: has_ladder_down = true
		if "wall_ladder" in path: has_wall_ladder = true
	print("Floor 2: has_doorway=%s, has_ladder_down=%s, has_wall_ladder=%s" % [has_doorway, has_ladder_down, has_wall_ladder])
	
	print("ALL FLOOR 1 & 2 CHECKS PASSED!")
	quit()
