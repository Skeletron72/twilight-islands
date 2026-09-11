extends SceneTree
func _init():
    var scn = load("res://scenes/levels/home_island.tscn")
    if scn:
        print("SCENE LOADED OK")
    else:
        print("SCENE FAILED TO LOAD")
    quit()
