@tool
extends EditorScript

func _run():
    var img = Image.load_from_file("res://assets/new_assets/Cute_Fantasy/Tiles/Cliff/Stone_Cliff_1_Tile.png")
    if img:
        print("Cliff Image loaded. Size: ", img.get_width(), "x", img.get_height())
    else:
        print("Failed to load cliff image.")
