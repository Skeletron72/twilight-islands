@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Floor_Ladder.png")
	for y in range(img.get_height()):
		var line = ""
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			line += c.to_html(false) + " "
		print(line)
	quit()
