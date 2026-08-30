import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    lines = f.readlines()

new_lines = []
ext_resources = []

for line in lines:
    if line.startswith('[ext_resource') and ('id="tex_' in line):
        ext_resources.append(line)
    else:
        new_lines.append(line)

# find the last ext_resource in the clean file
insert_idx = 0
for i, line in enumerate(new_lines):
    if line.startswith('[ext_resource'):
        insert_idx = i + 1

new_lines = new_lines[:insert_idx] + ext_resources + new_lines[insert_idx:]

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.writelines(new_lines)
