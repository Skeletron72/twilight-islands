@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Doorway_1.png")
	for row in range(6):
		var opaque = 0
		var colors = {}
		for y in range(row * 16, (row + 1) * 16):
			for x in range(32):
				var c = img.get_pixel(x, y)
				if c.a > 0.05:
					opaque += 1
					var hex = c.to_html(false)
					colors[hex] = colors.get(hex, 0) + 1
		print("Row %d (Y=%d..%d): opaque=%d/512, unique_colors=%d" % [row, row*16, (row+1)*16, opaque, colors.size()])
	quit()
