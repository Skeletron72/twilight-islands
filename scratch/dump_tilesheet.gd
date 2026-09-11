@tool
extends SceneTree

func _init():
	var img: Image = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Walls.png")
	# Scale 4x for easy viewing
	var big: Image = Image.create(112 * 4, 128 * 4, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(112):
			var c = img.get_pixel(x, y)
			for dy in range(4):
				for dx in range(4):
					big.set_pixel(x * 4 + dx, y * 4 + dy, c)
	big.save_png("scratch/cave_walls_4x.png")
	print("Saved scratch/cave_walls_4x.png")
	quit()
