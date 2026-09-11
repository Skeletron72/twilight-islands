@tool
extends SceneTree

func _init():
	var dg = load("res://scripts/components/dungeon_generator.gd").new()
	# Let's inspect how the grid is built around spawn
	# We can copy the grid generation logic from dungeon_generator.gd and print the 20x20 area around cx, cy
	quit()
