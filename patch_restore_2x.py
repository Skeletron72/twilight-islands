import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# We will completely rewrite the cellular automata and smoothing section
# up to the point of "var floor_cells: Array[Vector2i] = []"

target_start_str = "	# Размеры залов случайные и могут быть больше"
target_end_str = "	var floor_cells: Array[Vector2i] = []"

start_idx = content.find(target_start_str)
end_idx = content.find(target_end_str)

if start_idx == -1 or end_idx == -1:
    print("Could not find targets!")
    sys.exit(1)

new_generation_logic = """	# Размеры залов случайные и могут быть больше
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
		
	# Заполняем шумом (оставляя рамку из стен)
	for x in range(2, sw - 2):
		for y in range(2, sh - 2):
			if randf() > 0.42:
				s_grid[x][y] = 0
				
	# Сглаживаем клеточным автоматом
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
	
	# Расчищаем зону спавна в малом разрешении
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			s_grid[scx + dx][scy + dy] = 0
			
	# Увеличиваем в 2 раза (ИДЕАЛЬНАЯ ГЕОМЕТРИЯ)
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
	var cy = h / 2

	# Расчищаем зону спавна (уже в увеличенном разрешении)
	for dx in range(-4, 5):
		for dy in range(-3, 4):
			grid[cx + dx][cy + dy] = 0
			
	# Создаем массивную стену на севере от спавна, чтобы гарантированно образовать ЮЖНЫЙ фасад скалы!
	for dx in range(-6, 6):
		for dy in range(-7, -4):
			grid[cx + dx][cy + dy] = 1
			
	# Пробиваем ровный коридор на север через эту стену
	for dy in range(-12, -3):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
		# Гарантируем толщину боковых стен коридора
		grid[cx - 3][cy + dy] = 1
		grid[cx - 4][cy + dy] = 1
		grid[cx + 2][cy + dy] = 1
		grid[cx + 3][cy + dy] = 1
			
	# Плавный переход краев в дальнем конце коридора
	for dx in range(-3, 3):
		grid[cx + dx][cy - 12] = 0

	# Саппорт ставится ровно у основания южного фасада скалы (y = cy - 3)
	var support_pos = Vector2i(cx, cy - 3)

"""

# Reconstruct the file
new_content = content[:start_idx] + new_generation_logic + content[end_idx:]

with open(file_path, "w") as f:
    f.write(new_content)
