@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Doorway_1.png")
	var crop = Image.create(32, 48, false, Image.FORMAT_RGBA8)
	crop.blit_rect(img, Rect2i(0, 0, 32, 48), Vector2i(0, 0))
	
	var big = Image.create(32 * 4, 48 * 4, false, Image.FORMAT_RGBA8)
	for y in range(48):
		for x in range(32):
			var c = crop.get_pixel(x, y)
			for dy in range(4):
				for dx in range(4):
					big.set_pixel(x * 4 + dx, y * 4 + dy, c)
	big.save_png("scratch/doorway_32x48_4x.png")
	print("Saved scratch/doorway_32x48_4x.png")
	quit()
