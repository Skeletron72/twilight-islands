import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_wall_loop = """	# 5. Draw Walls using perfect 3x3 blob logic
	var covered_by_wall: Array[Vector2i] = []
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 1:
				var f_n = grid[x][y-1] == 0 if y > 0 else false
				var f_s = grid[x][y+1] == 0 if y < h-1 else false
				var f_w = grid[x-1][y] == 0 if x > 0 else false
				var f_e = grid[x+1][y] == 0 if x < w-1 else false
				
				var f_nw = grid[x-1][y-1] == 0 if (x > 0 and y > 0) else false
				var f_ne = grid[x+1][y-1] == 0 if (x < w-1 and y > 0) else false
				var f_sw = grid[x-1][y+1] == 0 if (x > 0 and y < h-1) else false
				var f_se = grid[x+1][y+1] == 0 if (x < w-1 and y < h-1) else false"""

new_wall_loop = """	# 5. Draw Walls using perfect 3x3 blob logic (с огромным паддингом, чтобы не было выхода в пустоту)
	var covered_by_wall: Array[Vector2i] = []
	var padding = 20
	for x in range(-padding, w + padding):
		for y in range(-padding, h + padding):
			# Если за пределами сетки, считаем, что там скала
			var is_wall = true
			if x >= 0 and x < w and y >= 0 and y < h:
				is_wall = (grid[x][y] == 1)
				
			if is_wall:
				var get_g = func(gx, gy): return grid[gx][gy] if gx >= 0 and gx < w and gy >= 0 and gy < h else 1
				
				var f_n = get_g.call(x, y-1) == 0
				var f_s = get_g.call(x, y+1) == 0
				var f_w = get_g.call(x-1, y) == 0
				var f_e = get_g.call(x+1, y) == 0
				
				var f_nw = get_g.call(x-1, y-1) == 0
				var f_ne = get_g.call(x+1, y-1) == 0
				var f_sw = get_g.call(x-1, y+1) == 0
				var f_se = get_g.call(x+1, y+1) == 0"""

content = content.replace(old_wall_loop, new_wall_loop)

# Also fix the boundary collision generator to cover the padded area!
old_collision = """func _create_boundary_walls_from_grid(body: StaticBody2D, grid: Array, w: int, h: int) -> void:
	body.collision_layer = 1
	body.collision_mask = 0
	for x in range(w):
		for y in range(h):
			if grid[x][y] == 1:
				var adjacent_floor = false
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0: continue
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if grid[nx][ny] == 0:
								adjacent_floor = true
								break
					if adjacent_floor: break
					
				if adjacent_floor:"""

new_collision = """func _create_boundary_walls_from_grid(body: StaticBody2D, grid: Array, w: int, h: int) -> void:
	body.collision_layer = 1
	body.collision_mask = 0
	var padding = 20
	for x in range(-padding, w + padding):
		for y in range(-padding, h + padding):
			var is_wall = true
			if x >= 0 and x < w and y >= 0 and y < h:
				is_wall = (grid[x][y] == 1)
				
			if is_wall:
				var adjacent_floor = false
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0: continue
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if grid[nx][ny] == 0:
								adjacent_floor = true
								break
					if adjacent_floor: break
					
				if adjacent_floor or x < 0 or x >= w or y < 0 or y >= h:
					# Если за пределами сетки, не ставим коллизию везде, а только на границе видимости?
					# Достаточно поставить коллизию на реальных границах
					if x < 0 or x >= w or y < 0 or y >= h:
						# Не создаем тысячи коллизий для паддинга, достаточно тех, что прилегают к полу
						continue"""

content = content.replace(old_collision, new_collision)

with open(file_path, "w") as f:
    f.write(content)
