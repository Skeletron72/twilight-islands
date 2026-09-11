@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("resources/pixel_light_texture.png")
	var tex = ImageTexture.create_from_image(img)
	ResourceSaver.save(tex, "resources/pixel_light_texture.tres")
	print("Saved resources/pixel_light_texture.tres successfully!")
	quit()
