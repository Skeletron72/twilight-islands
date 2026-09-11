extends SceneTree
func _init():
    var sun = DirectionalLight2D.new()
    print("Has height: ", "height" in sun)
    print("Has max_distance: ", "max_distance" in sun)
    quit()
