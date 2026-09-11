extends SceneTree
func _init():
	var script = load("res://scripts/components/dungeon_generator.gd").new()
	var w = 40
	var h = 30
	var grid = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1)
		grid.append(col)
		
	for x in range(3, w - 3):
		for y in range(4, h - 4):
			if randf() > 0.45:
				grid[x][y] = 0
				
	for i in range(5):
		var new_grid = grid.duplicate(true)
		for x in range(2, w - 2):
			for y in range(3, h - 3):
				var walls = 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if grid[x + dx][y + dy] == 1:
							walls += 1
				if walls >= 5:
					new_grid[x][y] = 1
				elif walls <= 3:
					new_grid[x][y] = 0
		grid = new_grid
		
	var cx = w / 2
	var cy = h / 2
	for dx in range(-3, 4):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0
			
	for dy in range(-12, 0):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
			
	for dx in range(-3, 3):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0
		
	# Убираем стены толщиной в 1 тайл
	for x in range(1, w - 1):
		for y in range(1, h - 1):
			if grid[x][y] == 1:
				if grid[x-1][y] == 0 and grid[x+1][y] == 0: grid[x][y] = 0
				if grid[x][y-1] == 0 and grid[x][y+1] == 0: grid[x][y] = 0
				
	# Убираем коридоры шириной в 1 тайл (расширяем их)
	for i in range(2):
		for x in range(1, w - 1):
			for y in range(1, h - 1):
				if grid[x][y] == 0:
					if grid[x-1][y] == 1 and grid[x+1][y] == 1: grid[x+1][y] = 0
					if grid[x][y-1] == 1 and grid[x][y+1] == 1: grid[x][y+1] = 0
					
	# Сглаживаем "лесенки" (диагонально касающиеся углы стен)
	for x in range(1, w - 1):
		for y in range(1, h - 1):
			if grid[x][y] == 1 and grid[x+1][y+1] == 1 and grid[x+1][y] == 0 and grid[x][y+1] == 0:
				grid[x+1][y] = 1
			if grid[x+1][y] == 1 and grid[x][y+1] == 1 and grid[x][y] == 0 and grid[x+1][y+1] == 0:
				grid[x][y] = 1

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
