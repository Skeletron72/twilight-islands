@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Floor_Ladder.png")
	var bg_color = Color("8a4836")
	# Flood fill or replace all outer pixels matching bg_color
	# We can do a BFS from (0,0) and the 4 corners to only remove outer background!
	var w = img.get_width()
	var h = img.get_height()
	var visited = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(false)
		visited.append(col)
		
	var q = [Vector2i(0, 0), Vector2i(w-1, 0), Vector2i(0, h-1), Vector2i(w-1, h-1)]
	for pt in q:
		visited[pt.x][pt.y] = true
		
	while q.size() > 0:
		var curr = q.pop_front()
		img.set_pixel(curr.x, curr.y, Color(0, 0, 0, 0))
		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var nx = curr.x + d.x
			var ny = curr.y + d.y
			if nx >= 0 and nx < w and ny >= 0 and ny < h:
				if not visited[nx][ny]:
					var c = img.get_pixel(nx, ny)
					# If it matches the background color
					if c.to_html(false) == "8a4836":
						visited[nx][ny] = true
						q.append(Vector2i(nx, ny))
						
	img.save_png("assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Floor_Ladder.png")
	print("Saved transparent Cave_Floor_Ladder.png")
	
	# Also export 4x for viewing
	var big = Image.create(w * 4, h * 4, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			var c = img.get_pixel(x, y)
			for dy in range(4):
				for dx in range(4):
					big.set_pixel(x * 4 + dx, y * 4 + dy, c)
	big.save_png("scratch/ladder_clean_4x.png")
	quit()
