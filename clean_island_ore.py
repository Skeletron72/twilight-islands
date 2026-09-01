with open('scenes/levels/home_island.tscn', 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if line.startswith('[node name="TwilightOre"'):
        skip = True
        
    if skip and line.startswith('[node') and not line.startswith('[node name="TwilightOre"'):
        skip = False
        
    if skip:
        continue
        
    new_lines.append(line)

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.writelines(new_lines)
