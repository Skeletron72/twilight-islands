@tool
extends SceneTree

func _scale_and_save(path_in: String, path_out: String):
	var img = Image.load_from_file(path_in)
	var w = img.get_width()
	var h = img.get_height()
	var big = Image.create(w * 4, h * 4, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			var c = img.get_pixel(x, y)
			for dy in range(4):
				for dx in range(4):
					big.set_pixel(x * 4 + dx, y * 4 + dy, c)
	big.save_png(path_out)

func _init():
	_scale_and_save("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Floor_Ladder.png", "scratch/floor_ladder_4x.png")
	_scale_and_save("assets/new_assets/Cute_Fantasy_Desert/Props/Desert_Ladder.png", "scratch/desert_ladder_4x.png")
	_scale_and_save("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Doorway_1.png", "scratch/cave_doorway_4x.png")
	quit()
