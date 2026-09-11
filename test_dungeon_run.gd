extends SceneTree

func _init():
	var scene = load("res://scenes/levels/dungeon.tscn")
	if not scene:
		print("Failed to load scene")
		quit()
		return
	
	var inst = scene.instantiate()
	if inst:
		print("Scene instantiated successfully!")
	
	quit()
