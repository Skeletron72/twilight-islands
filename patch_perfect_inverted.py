import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_map = """				# Внешние углы (углы скалы) - стандартный маппинг
				if f_n and f_w: tile = Vector2i(4, 0)
				elif f_n and f_e: tile = Vector2i(6, 0)
				elif f_s and f_w: tile = Vector2i(4, 2)
				elif f_s and f_e: tile = Vector2i(6, 2)
				
				# Прямые края
				elif f_n: tile = Vector2i(5, 0)
				elif f_s: tile = Vector2i(5, 2)
				elif f_w: tile = Vector2i(4, 1)
				elif f_e: tile = Vector2i(6, 1)
				
				# Внутренние углы (впадины в скале)
				elif f_nw: tile = Vector2i(5, 4)
				elif f_ne: tile = Vector2i(4, 4)
				elif f_sw: tile = Vector2i(5, 3)
				elif f_se: tile = Vector2i(4, 3)"""

new_map = """				# Внешние углы (ИНВЕРТИРОВАННЫЙ МАППИНГ ПО ПРОСЬБЕ ПОЛЬЗОВАТЕЛЯ)
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

content = content.replace(old_map, new_map)

# Also fix the vertical cliff faces logic for inner corners!
old_vert = """					# Inner corners
					if f_se and not f_s:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
					elif f_sw and not f_s:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)"""

new_vert = """					# Inner corners (инвертировано)
					if f_se and not f_s:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
					elif f_sw and not f_s:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)"""

content = content.replace(old_vert, new_vert)

with open(file_path, "w") as f:
    f.write(content)
