extends SceneTree

func _init():
	var support = preload("res://scenes/objects/dungeon/cave_support.tscn").instantiate()
	print(support.get_node("Sprite2D").region_rect)
	quit()
