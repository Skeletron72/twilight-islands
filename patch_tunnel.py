import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# Replace the carving logic to carve a long, clean 5-tile wide tunnel connecting the center to somewhere
old_carve = """	# Carve a 5-tile wide vertical corridor to place the support
	var support_placed = false
	var support_pos = Vector2i(-1, -1)
	
	for y in range(6, h - 6):
		if support_placed: break
		for x in range(6, w - 10):
			# Look for a vertical 4-tile wide corridor
			var is_4_corridor = true
			for dy in range(4):
				if grid[x][y+dy] != 1 or grid[x+1][y+dy] != 0 or grid[x+2][y+dy] != 0 or grid[x+3][y+dy] != 0 or grid[x+4][y+dy] != 0 or grid[x+5][y+dy] != 1:
					is_4_corridor = false
					break
			
			if is_4_corridor:
				# Widen it to 5 tiles by making x+5 floor as well, for a length of 6 tiles
				for dy in range(-1, 5):
					grid[x+5][y+dy] = 0
				support_placed = true
				support_pos = Vector2i(x+1, y)
				break"""

new_carve = """	# Carve a dedicated 5-tile wide vertical corridor for the support
	var support_placed = true
	var support_pos = Vector2i(cx - 2, cy - 8)
	
	# Пробиваем идеальный коридор 5 шириной и 12 длиной наверх от спавна, чтобы там гарантированно стоял саппорт!
	for dy in range(-12, 0):
		for dx in range(-2, 3):
			grid[cx + dx][cy + dy] = 0
	
	# Делаем переход плавным (чтобы не было острых углов в 1 тайл)
	# Расширяем края коридора у основания и на вершине до четных значений
	for dx in range(-3, 4):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0"""

content = content.replace(old_carve, new_carve)

with open(file_path, "w") as f:
    f.write(content)
