@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Doorway_1.png")
	print("Size:", img.get_size())
	# Let's see rows
	# 32 x 96 = 2 columns of 16px, 6 rows of 16px
	# 8 tiles = 2 cols x 4 rows = 32 x 64!
	# Let's save the first 8 tiles (Rect2i(0, 0, 32, 64))
	var crop = Image.create(32, 64, false, Image.FORMAT_RGBA8)
	crop.blit_rect(img, Rect2i(0, 0, 32, 64), Vector2i(0, 0))
	crop.save_png("scratch/doorway_8tiles.png")
	
	var big = Image.create(32 * 4, 64 * 4, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(32):
			var c = crop.get_pixel(x, y)
			for dy in range(4):
				for dx in range(4):
					big.set_pixel(x * 4 + dx, y * 4 + dy, c)
	big.save_png("scratch/doorway_8tiles_4x.png")
	print("Saved scratch/doorway_8tiles_4x.png")
	quit()
