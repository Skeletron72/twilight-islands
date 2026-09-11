import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

old_logic = """				# Внешние углы
				if f_n and f_w: tile = Vector2i(4, 0) # Floor is NW -> This is Top-Left edge of cliff
				elif f_n and f_e: tile = Vector2i(6, 0) # Floor is NE -> This is Top-Right edge of cliff
				elif f_s and f_w: tile = Vector2i(4, 2) # Floor is SW -> This is Bottom-Left edge of cliff
				elif f_s and f_e: tile = Vector2i(6, 2) # Floor is SE -> This is Bottom-Right edge of cliff
				
				# Прямые края
				elif f_n: tile = Vector2i(5, 0) # Floor is N -> This is Top edge of cliff
				elif f_s: tile = Vector2i(5, 2) # Floor is S -> This is Bottom edge of cliff
				elif f_w: tile = Vector2i(4, 1) # Floor is W -> This is Left edge of cliff
				elif f_e: tile = Vector2i(6, 1) # Floor is E -> This is Right edge of cliff
				
				# Внутренние углы (впадины в скале)
				elif f_nw: tile = Vector2i(5, 4) # Floor is NW only -> Inner BR corner of cliff
				elif f_ne: tile = Vector2i(4, 4) # Floor is NE only -> Inner BL corner of cliff
				elif f_sw: tile = Vector2i(5, 3) # Floor is SW only -> Inner TR corner of cliff
				elif f_se: tile = Vector2i(4, 3) # Floor is SE only -> Inner TL corner of cliff"""

new_logic = """				# Внешние углы (ПОМЕНЯЛИ ВСЕ НА ПРОТИВОПОЛОЖНЫЕ!)
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

content = content.replace(old_logic, new_logic)

with open(file_path, "w") as f:
    f.write(content)
