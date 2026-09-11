import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# Make sure vertical wall logic uses the correct inner corner checks!
# In the swapped logic:
# Inner TR (5,3) is now used for f_ne (Floor is NE). 
# Inner TL (4,3) is now used for f_nw (Floor is NW).
# Inner BR (5,4) is used for f_se.
# Inner BL (4,4) is used for f_sw.
# So if f_s is true, we draw vertical wall.
# What if it's an inner corner that creates a small south-facing edge?
# In swapped logic, the small south-facing edge is when Floor is SE or SW.
# Wait, if Floor is SE (f_se), the wall cell is NW of the floor. The floor is South and East. So the wall faces South and East!
# So it STILL has a South-facing edge!
# So f_se and f_sw STILL trigger the vertical wall!

old_vert = """				if f_s or (f_s and f_w) or (f_s and f_e) or f_se or f_sw:
					var face_top = Vector2i(1, 6)
					var face_bot = Vector2i(1, 7)
					
					if f_s and f_w:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)
					elif f_s and f_e:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
						
					# Рисуем вертикальную стену, которая накладывается поверх пола!
					wall_layer.set_cell(Vector2i(x, y+1), SOURCE_WALLS, face_top)
					wall_layer.set_cell(Vector2i(x, y+2), SOURCE_WALLS, face_bot)"""

new_vert = """				if f_s or f_se or f_sw:
					var face_top = Vector2i(1, 6)
					var face_bot = Vector2i(1, 7)
					
					# Outer corners (swapped)
					# f_s and f_e -> Vector2i(4,0) -> Top-Left of cliff. The left side of the vertical wall drops here?
					# Actually, for RPG Maker outer corners, usually the center vertical wall is used, or the edge ones.
					if f_s and f_e:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)
					elif f_s and f_w:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
						
					# Inner corners (swapped)
					# f_se -> (5,4) (Inner BR). It has a small south face on the left.
					if f_se and not f_s:
						face_top = Vector2i(2, 6)
						face_bot = Vector2i(2, 7)
					elif f_sw and not f_s:
						face_top = Vector2i(0, 6)
						face_bot = Vector2i(0, 7)
						
					wall_layer.set_cell(Vector2i(x, y+1), SOURCE_WALLS, face_top)
					wall_layer.set_cell(Vector2i(x, y+2), SOURCE_WALLS, face_bot)"""

content = content.replace(old_vert, new_vert)

with open(file_path, "w") as f:
    f.write(content)
