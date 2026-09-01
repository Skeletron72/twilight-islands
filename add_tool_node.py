with open('scenes/characters/player/player.tscn', 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if line.startswith('[node name="Hands"'):
        new_lines.append('hframes = 9\n')
        new_lines.append('vframes = 56\n')
        new_lines.append('[node name="Tool" type="Sprite2D" parent="Visuals"]\n')
        new_lines.append('visible = false\n')

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.writelines(new_lines)
