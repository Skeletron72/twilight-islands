@tool
extends SceneTree

func _init():
	var img: Image = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Walls.png")
	for y in range(8):
		for x in range(7):
			var c = img.get_pixel(x * 16 + 8, y * 16 + 8)
			if c.a > 0.1:
				print("(%d,%d): r=%.2f g=%.2f b=%.2f" % [x, y, c.r, c.g, c.b])
	quit()
