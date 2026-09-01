with open('scenes/characters/player/player.tscn', 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.startswith('[node name="Visuals"'):
        new_lines.append(line)
        new_lines.append('position = Vector2(0, -16)\n')
    elif line == 'position = Vector2(0, -16)\n':
        continue
    else:
        new_lines.append(line)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.writelines(new_lines)
