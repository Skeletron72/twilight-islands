import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_logic = """	# Расчищаем зону спавна в малом разрешении
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			s_grid[scx + dx][scy + dy] = 0
			
	# Увеличиваем в 2 раза (ИДЕАЛЬНАЯ ГЕОМЕТРИЯ)"""

new_logic = """	# Расчищаем зону спавна в малом разрешении
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			s_grid[scx + dx][scy + dy] = 0
			
	# Flood-fill для удаления изолированных комнат
	var visited: Array = []
	for x in range(sw):
		var col = []
		col.resize(sh)
		col.fill(false)
		visited.append(col)
		
	var queue: Array[Vector2i] = [Vector2i(scx, scy)]
	visited[scx][scy] = true
	
	while queue.size() > 0:
		var curr = queue.pop_front()
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if abs(dx) == abs(dy): continue # Только ортогональные соседи
				var nx = curr.x + dx
				var ny = curr.y + dy
				if nx >= 0 and nx < sw and ny >= 0 and ny < sh:
					if s_grid[nx][ny] == 0 and not visited[nx][ny]:
						visited[nx][ny] = true
						queue.append(Vector2i(nx, ny))
						
	# Заливаем все непосещенные участки пола стенами
	for x in range(sw):
		for y in range(sh):
			if s_grid[x][y] == 0 and not visited[x][y]:
				s_grid[x][y] = 1
			
	# Увеличиваем в 2 раза (ИДЕАЛЬНАЯ ГЕОМЕТРИЯ)"""

content = content.replace(old_logic, new_logic)

with open(file_path, "w") as f:
    f.write(content)
