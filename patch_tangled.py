import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_size = """	# Размеры залов случайные и могут быть больше
	var base_w = 30 + (floor_num * 2) + (randi() % 16)
	var base_h = int(base_w * 0.75)
	
	if base_w > 64: base_w = 64
	if base_h > 48: base_h = 48"""

new_size = """	# Размеры залов случайные и могут быть больше (от маленьких до очень больших)
	var base_w = randi() % 60 + 30 # от 30 до 90
	var base_h = int(base_w * 0.75)"""

content = content.replace(old_size, new_size)

old_noise = """	# Заполняем шумом (оставляя рамку из стен)
	for x in range(2, sw - 2):
		for y in range(2, sh - 2):
			if randf() > 0.42:
				s_grid[x][y] = 0"""

new_noise = """	# Заполняем шумом (оставляя рамку из стен)
	# Увеличен порог шума (0.47 вместо 0.42), чтобы пещеры получались более запутанными и узкими
	for x in range(2, sw - 2):
		for y in range(2, sh - 2):
			if randf() > 0.47:
				s_grid[x][y] = 0"""

content = content.replace(old_noise, new_noise)

with open(file_path, "w") as f:
    f.write(content)
