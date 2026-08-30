extends SceneTree

func _init():
	var img = Image.new()
	var err = img.load("res://assets/sprites/ui/inventory/Book.png")
	if err != OK:
		print("Failed to load image")
		quit()
		return
		
	var width = img.get_width()
	var height = img.get_height()
	var visited = {}
	var regions = []
	
	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y)
			if not visited.has(pos):
				var color = img.get_pixel(x, y)
				if color.a > 0.0:
					var min_x = x
					var max_x = x
					var min_y = y
					var max_y = y
					var stack = [pos]
					
					while stack.size() > 0:
						var curr = stack.pop_back()
						if visited.has(curr):
							continue
						visited[curr] = true
						
						min_x = min(min_x, int(curr.x))
						max_x = max(max_x, int(curr.x))
						min_y = min(min_y, int(curr.y))
						max_y = max(max_y, int(curr.y))
						
						var dirs = [
							Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1),
							Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1)
						]
						for dir in dirs:
							var next = curr + dir
							if next.x >= 0 and next.x < width and next.y >= 0 and next.y < height:
								if not visited.has(next):
									if img.get_pixelv(next).a > 0.0:
										stack.append(next)
					
					regions.append({"x": min_x, "y": min_y, "w": max_x - min_x + 1, "h": max_y - min_y + 1})
				else:
					visited[pos] = true

	# Sort by area
	regions.sort_custom(func(a, b): return (a.w * a.h) > (b.w * b.h))
	
	for i in range(min(15, regions.size())):
		var r = regions[i]
		print("Region ", i, ": x=", r.x, " y=", r.y, " w=", r.w, " h=", r.h)
		
	quit()
