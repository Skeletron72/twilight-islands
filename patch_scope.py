import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# Remove the late definition
content = content.replace("	var covered_by_wall = []\n	var valid_floor_cells = []", "	var valid_floor_cells = []")

# Add it before the wall drawing loop
old_loop = "	# 5. Draw Walls using perfect 3x3 blob logic\n	for x in range(w):"
new_loop = "	# 5. Draw Walls using perfect 3x3 blob logic\n	var covered_by_wall: Array[Vector2i] = []\n	for x in range(w):"
content = content.replace(old_loop, new_loop)

with open(file_path, "w") as f:
    f.write(content)
