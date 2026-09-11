import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_carve = """	for dy in range(-12, 0):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
			
	for dx in range(-3, 3):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0"""

new_carve = """	for dy in range(-12, 0):
		for dx in range(-2, 2):
			grid[cx + dx][cy + dy] = 0
		# Гарантируем, что по бокам от коридора есть толстые стены (минимум 2 тайла), чтобы они не удалились сглаживанием!
		grid[cx - 3][cy + dy] = 1
		grid[cx - 4][cy + dy] = 1
		grid[cx + 2][cy + dy] = 1
		grid[cx + 3][cy + dy] = 1
			
	for dx in range(-3, 3):
		grid[cx + dx][cy] = 0
		grid[cx + dx][cy - 12] = 0"""

content = content.replace(old_carve, new_carve)

with open(file_path, "w") as f:
    f.write(content)
