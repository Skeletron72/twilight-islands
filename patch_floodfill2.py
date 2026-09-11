import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_s_grid = """	# Расчищаем зону спавна в малом разрешении
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			s_grid[scx + dx][scy + dy] = 0
			
	# Flood-fill для удаления изолированных комнат"""

new_s_grid = """	# Расчищаем зону спавна в малом разрешении
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			s_grid[scx + dx][scy + dy] = 0
			
	# Пробиваем стартовый коридор в малом разрешении ДО flood-fill'а, чтобы соединить спавн с основной пещерой!
	for dy in range(-6, 0):
		s_grid[scx][scy + dy] = 0
			
	# Flood-fill для удаления изолированных комнат"""

content = content.replace(old_s_grid, new_s_grid)

with open(file_path, "w") as f:
    f.write(content)
