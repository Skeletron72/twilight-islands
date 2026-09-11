@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Floor_Ladder.png")
	print("Size:", img.get_size())
	for y in range(img.get_height()):
		var line = ""
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			# print hex or marker
			if c.to_html(false) == "8c4f3e":
				line += " B"
			else:
				line += " ."
		print(line)
	quit()
