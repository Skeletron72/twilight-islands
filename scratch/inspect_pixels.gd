@tool
extends SceneTree

func _init():
	var img: Image = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Walls.png")
	print("Loaded image size: ", img.get_size())
	for y in range(8):
		var row_str = ""
		for x in range(7):
			# Sample center pixel of 16x16 tile
			var col = img.get_pixel(x * 16 + 8, y * 16 + 8)
			var top = img.get_pixel(x * 16 + 8, y * 16 + 1)
			var bot = img.get_pixel(x * 16 + 8, y * 16 + 14)
			var left = img.get_pixel(x * 16 + 1, y * 16 + 8)
			var right = img.get_pixel(x * 16 + 14, y * 16 + 8)
			row_str += "(%d,%d):a=%.1f " % [x, y, col.a]
		print("Row ", y, ": ", row_str)
	quit()
