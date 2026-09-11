extends SceneTree
func _init():
	var tex = load("res://assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Walls.png") as Texture2D
	if tex:
		print("Cave Walls size: ", tex.get_size())
	
	var floor_tex = load("res://assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Floor_1.png") as Texture2D
	if floor_tex:
		print("Cave Floor size: ", floor_tex.get_size())
	
	quit()
