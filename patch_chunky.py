import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# Replace the generation logic
old_gen = """	var w: int = 26 + (floor_num % 5) * 2
	var h: int = 20 + (floor_num % 3) * 2
	var grid: Array = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1) # 1 = Wall
		grid.append(col)
		
	# 1. Cellular Automata - Random Fill
	for x in range(3, w - 3):
		for y in range(4, h - 4):
			if randf() > 0.42:
				grid[x][y] = 0 # 0 = Floor
				
	# 2. Cellular Automata - Smoothing
	for i in range(4):
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
		
	# 3. Widen corridors (minimum 2 tiles wide)
	for i in range(2):
		var new_grid = grid.duplicate(true)
		for x in range(2, w - 2):
			for y in range(3, h - 3):
				if grid[x][y] == 0:
					# Horizontal bottleneck (Wall - Floor - Wall) -> widen to Right
					if grid[x-1][y] == 1 and grid[x+1][y] == 1:
						new_grid[x+1][y] = 0
						new_grid[x+1][y-1] = 0 # help clear corners
					# Vertical bottleneck (Wall - Floor - Wall) -> widen Down
					if grid[x][y-1] == 1 and grid[x][y+1] == 1:
						new_grid[x][y+1] = 0
						new_grid[x+1][y+1] = 0
		grid = new_grid

	var cx = w / 2
	var cy = h / 2
	for dx in range(-3, 4):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0"""

new_gen = """	# Размеры залов случайные и могут быть больше
	var base_w = 30 + (floor_num * 2) + (randi() % 16)
	var base_h = int(base_w * 0.75)
	
	if base_w > 64: base_w = 64
	if base_h > 48: base_h = 48
	
	# Делаем четными для идеального скейла
	var w: int = base_w - (base_w % 2)
	var h: int = base_h - (base_h % 2)
	
	# Генерируем пещеру в 2 раза меньшем разрешении, чтобы после увеличения x2 
	# ВСЕ проходы были минимум 2 тайла, а любые выступы стен были минимум 2х2 тайла (без резких углов)
	var sw = w / 2
	var sh = h / 2
	
	var s_grid: Array = []
	for x in range(sw):
		var col = []
		col.resize(sh)
		col.fill(1)
		s_grid.append(col)
		
	for x in range(2, sw - 2):
		for y in range(2, sh - 2):
			if randf() > 0.42:
				s_grid[x][y] = 0
				
	for i in range(4):
		var new_s = s_grid.duplicate(true)
		for x in range(1, sw - 1):
			for y in range(1, sh - 1):
				var walls = 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if s_grid[x + dx][y + dy] == 1:
							walls += 1
				if walls >= 5:
					new_s[x][y] = 1
				elif walls <= 3:
					new_s[x][y] = 0
		s_grid = new_s
		
	var scx = sw / 2
	var scy = sh / 2
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			s_grid[scx + dx][scy + dy] = 0
			
	# Увеличиваем в 2 раза
	var grid: Array = []
	for x in range(w):
		var col = []
		col.resize(h)
		col.fill(1)
		grid.append(col)
		
	for x in range(w):
		for y in range(h):
			grid[x][y] = s_grid[x / 2][y / 2]

	var cx = w / 2
	var cy = h / 2"""

content = content.replace(old_gen, new_gen)

with open(file_path, "w") as f:
    f.write(content)
