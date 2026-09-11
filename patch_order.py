import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# Extract smoothing rules
smoothing_rules = """	# Убираем стены толщиной в 1 тайл
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
				grid[x][y] = 1"""

content = content.replace(smoothing_rules, "")

# Find where to insert them (AFTER the corridor is carved)
insert_target = """	# Плавный переход краев
	for dx in range(-3, 3):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0"""

content = content.replace(insert_target, insert_target + "\n\n" + smoothing_rules)

with open(file_path, "w") as f:
    f.write(content)
