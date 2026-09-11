import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_logic = """				# Внешние углы (ПОМЕНЯЛИ ВСЕ НА ПРОТИВОПОЛОЖНЫЕ!)
				if f_n and f_w: tile = Vector2i(6, 2)
				elif f_n and f_e: tile = Vector2i(4, 2)
				elif f_s and f_w: tile = Vector2i(6, 0)
				elif f_s and f_e: tile = Vector2i(4, 0)
				
				# Прямые края
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы
				elif f_nw: tile = Vector2i(4, 3)
				elif f_ne: tile = Vector2i(5, 3)
				elif f_sw: tile = Vector2i(4, 4)
				elif f_se: tile = Vector2i(5, 4)"""

new_logic = """				# Внешние углы (Теперь используем тайлы внутренних углов пустоты!)
				if f_n and f_w: tile = Vector2i(4, 3)
				elif f_n and f_e: tile = Vector2i(5, 3)
				elif f_s and f_w: tile = Vector2i(4, 4)
				elif f_s and f_e: tile = Vector2i(5, 4)
				
				# Прямые края
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы (Теперь используем тайлы внешних углов пустоты!)
				elif f_nw: tile = Vector2i(4, 0)
				elif f_ne: tile = Vector2i(6, 0)
				elif f_sw: tile = Vector2i(4, 2)
				elif f_se: tile = Vector2i(6, 2)"""

content = content.replace(old_logic, new_logic)

# Reduce stones
old_stones = "if randf() < 0.15:"
new_stones = "if randf() < 0.05: # Уменьшили количество камней по просьбе"
content = content.replace(old_stones, new_stones)

with open(file_path, "w") as f:
    f.write(content)
