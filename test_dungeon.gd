extends SceneTree

func _init():
	var script = load("res://scripts/components/dungeon_generator.gd").new()
	var w = 40
	var h = 30
	var s_grid = []
	for x in range(w/2):
		var col = []
		col.resize(h/2)
		col.fill(1)
		s_grid.append(col)
		
	for x in range(2, w/2 - 2):
		for y in range(2, h/2 - 2):
			if randf() > 0.42:
				s_grid[x][y] = 0
				
	for i in range(4):
		var new_s = s_grid.duplicate(true)
		for x in range(1, w/2 - 1):
			for y in range(1, h/2 - 1):
				var walls = 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if s_grid[x + dx][y + dy] == 1: walls += 1
				if walls >= 5: new_s[x][y] = 1
				elif walls <= 3: new_s[x][y] = 0
		s_grid = new_s
		
	var grid = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1)
		grid.append(col)
	
	for x in range(w):
		for y in range(h):
			grid[x][y] = s_grid[x/2][y/2]
			
	var cx = w/2
	var cy = h/2
	for dy in range(-12, 0):
		for dx in range(-2, 2):
			grid[cx+dx][cy+dy] = 0
			
	# Print the grid to see what the walls look like!
	var out = ""
	for y in range(h):
		var line = ""
		for x in range(w):
			if grid[x][y] == 1:
				line += "#"
			else:
				line += "."
		out += line + "\n"
	print(out)
	quit()
