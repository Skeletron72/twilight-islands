import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_map = """				# Внешние углы (ИНВЕРТИРОВАННЫЙ МАППИНГ ПО ПРОСЬБЕ ПОЛЬЗОВАТЕЛЯ)
				if f_n and f_w: tile = Vector2i(6, 2)
				elif f_n and f_e: tile = Vector2i(4, 2)
				elif f_s and f_w: tile = Vector2i(6, 0)
				elif f_s and f_e: tile = Vector2i(4, 0)
				
				# Прямые края (Светлая часть к полу, темная внутрь скалы)
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы (Инвертированные)
				elif f_nw: tile = Vector2i(4, 3)
				elif f_ne: tile = Vector2i(5, 3)
				elif f_sw: tile = Vector2i(4, 4)
				elif f_se: tile = Vector2i(5, 4)"""

new_map = """				# Внешние углы (ИНВЕРТИРОВАННЫЙ МАППИНГ + ПОМЕНЯННЫЕ МЕСТАМИ ВНЕШНИЕ И ВНУТРЕННИЕ)
				if f_n and f_w: tile = Vector2i(5, 4) # Было 6,2 (внешний), стало 5,4 (внутренний)
				elif f_n and f_e: tile = Vector2i(4, 4)
				elif f_s and f_w: tile = Vector2i(5, 3)
				elif f_s and f_e: tile = Vector2i(4, 3)
				
				# Прямые края (Светлая часть к полу, темная внутрь скалы)
				elif f_n: tile = Vector2i(5, 2)
				elif f_s: tile = Vector2i(5, 0)
				elif f_w: tile = Vector2i(6, 1)
				elif f_e: tile = Vector2i(4, 1)
				
				# Внутренние углы (Инвертированные + ПОМЕНЯННЫЕ МЕСТАМИ)
				elif f_nw: tile = Vector2i(6, 2) # Было 4,3 (внутренний), стало 6,2 (внешний)
				elif f_ne: tile = Vector2i(4, 2)
				elif f_sw: tile = Vector2i(6, 0)
				elif f_se: tile = Vector2i(4, 0)"""

content = content.replace(old_map, new_map)

with open(file_path, "w") as f:
    f.write(content)
