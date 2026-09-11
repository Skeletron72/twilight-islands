@tool
extends SceneTree

func _init():
	print("Testing generator logic...")
	# Simulate full run
	var dg = load("res://scripts/components/dungeon_generator.gd").new()
	print("Loaded successfully")
	quit()
