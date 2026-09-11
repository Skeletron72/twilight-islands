import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_tilemap = """	# Переносим в TileMapLayer
	for x in range(w):
		for y in range(h):"""

new_tilemap = """	# Переносим в TileMapLayer (с большим запасом породы вокруг, чтобы не было видно пустоту)
	var padding = 30
	for x in range(-padding, w + padding):
		for y in range(-padding, h + padding):
			# Если выходим за пределы карты - это сплошная скала
			if x < 0 or x >= w or y < 0 or y >= h:
				_set_rock_tile(x, y)
				continue
				
"""

content = content.replace(old_tilemap, new_tilemap)

old_set_rock = """func _set_rock_tile(x: int, y: int):
	# Определяем соседей (пол = 0)
	var f_n = y > 0 and grid[x][y - 1] == 0
	var f_s = y < h - 1 and grid[x][y + 1] == 0
	var f_e = x < w - 1 and grid[x + 1][y] == 0
	var f_w = x > 0 and grid[x - 1][y] == 0
	
	var f_nw = x > 0 and y > 0 and grid[x - 1][y - 1] == 0
	var f_ne = x < w - 1 and y > 0 and grid[x + 1][y - 1] == 0
	var f_sw = x > 0 and y < h - 1 and grid[x - 1][y + 1] == 0
	var f_se = x < w - 1 and y < h - 1 and grid[x + 1][y + 1] == 0"""

new_set_rock = """func _set_rock_tile(x: int, y: int):
	# Определяем соседей (пол = 0)
	# За пределами сетки считаем, что там скала (1), поэтому grid возвращает 1, а сравнение с 0 дает false
	var get_grid = func(gx, gy): return grid[gx][gy] if gx >= 0 and gx < w and gy >= 0 and gy < h else 1
	
	var f_n = get_grid.call(x, y - 1) == 0
	var f_s = get_grid.call(x, y + 1) == 0
	var f_e = get_grid.call(x + 1, y) == 0
	var f_w = get_grid.call(x - 1, y) == 0
	
	var f_nw = get_grid.call(x - 1, y - 1) == 0
	var f_ne = get_grid.call(x + 1, y - 1) == 0
	var f_sw = get_grid.call(x - 1, y + 1) == 0
	var f_se = get_grid.call(x + 1, y + 1) == 0"""

content = content.replace(old_set_rock, new_set_rock)

with open(file_path, "w") as f:
    f.write(content)
