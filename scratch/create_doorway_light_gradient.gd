@tool
extends SceneTree

func _init():
	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.35, 0.7, 1.0])
	grad.colors = PackedColorArray([
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0.75),
		Color(1, 1, 1, 0.25),
		Color(1, 1, 1, 0.0)
	])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.95, 0.95)
	tex.width = 64
	tex.height = 64
	ResourceSaver.save(tex, "resources/doorway_light_gradient.tres")
	print("Saved resources/doorway_light_gradient.tres")
	quit()
