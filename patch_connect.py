import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_s_grid = """	# Пробиваем стартовый коридор в малом разрешении ДО flood-fill'а, чтобы соединить спавн с основной пещерой!
	for dy in range(-6, 0):
		s_grid[scx][scy + dy] = 0
			
	# Flood-fill для удаления изолированных комнат"""

new_s_grid = """	# Пробиваем стартовый коридор в малом разрешении ДО flood-fill'а, чтобы соединить спавн с основной пещерой!
	# Копаем прямо до центра карты, чтобы ГАРАНТИРОВАННО зацепить основную пещеру!
	for y in range(sh / 2, scy + 1):
		s_grid[scx][y] = 0
			
	# Flood-fill для удаления изолированных комнат"""

content = content.replace(old_s_grid, new_s_grid)

# Also let's make the caves even bigger!
old_size = """	# Размеры залов случайные и могут быть больше (от маленьких до очень больших)
	var base_w = randi() % 60 + 30 # от 30 до 90"""
new_size = """	# Размеры залов случайные и могут быть больше (от маленьких до очень больших)
	var base_w = randi() % 80 + 40 # от 40 до 120"""
content = content.replace(old_size, new_size)

with open(file_path, "w") as f:
    f.write(content)
