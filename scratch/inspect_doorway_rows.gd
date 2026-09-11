@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Doorway_1.png")
	for row in range(6):
		var crop = Image.create(32, 16, false, Image.FORMAT_RGBA8)
		crop.blit_rect(img, Rect2i(0, row * 16, 32, 16), Vector2i(0, 0))
		crop.save_png("scratch/doorway_row_%d.png" % row)
		print("Saved row %d" % row)
	quit()
