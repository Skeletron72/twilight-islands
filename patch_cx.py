import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

content = content.replace("	var cx = w / 2\n	var cy = h / 2\n", "")

# Insert right before we use them
target = "	# Carve a dedicated 5-tile wide vertical corridor for the support"
new_target = "	var cx = w / 2\n	var cy = h / 2\n\n	# Carve a dedicated 5-tile wide vertical corridor for the support"
content = content.replace(target, new_target)

with open(file_path, "w") as f:
    f.write(content)
