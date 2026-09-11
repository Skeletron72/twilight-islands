@tool
extends SceneTree

func _init():
	var size = 64
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var pixel_step = 2 # 2x2 chunky pixels
	var bands = 4.0
	
	for py in range(0, size, pixel_step):
		for px in range(0, size, pixel_step):
			# Center of the 2x2 block
			var cx = (px + 1.0) / float(size) - 0.5
			var cy = (py + 1.0) / float(size) - 0.5
			var dist = sqrt(cx * cx + cy * cy) * 2.0 # 0 at center, 1 at circle edge
			
			var alpha = 0.0
			if dist < 1.0:
				var raw = pow(1.0 - dist, 1.3)
				var stepped = ceil(raw * bands) / bands
				alpha = clamp(stepped, 0.0, 1.0)
				
			var c = Color(1.0, 1.0, 1.0, alpha)
			for dy in range(pixel_step):
				for dx in range(pixel_step):
					if px + dx < size and py + dy < size:
						img.set_pixel(px + dx, py + dy, c)
						
	img.save_png("resources/pixel_light_texture.png")
	print("Saved resources/pixel_light_texture.png")
	
	# Also export 4x for viewing
	var big = Image.create(size * 4, size * 4, false, Image.FORMAT_RGBA8)
	for y in range(size):
		for x in range(size):
			var c = img.get_pixel(x, y)
			for dy in range(4):
				for dx in range(4):
					big.set_pixel(x * 4 + dx, y * 4 + dy, c)
	big.save_png("scratch/pixel_light_4x.png")
	quit()
