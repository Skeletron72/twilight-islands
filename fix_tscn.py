with open('scenes/characters/player/player.tscn', 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if line.startswith('[node name="Base"'):
        skip = True
        
    if skip and line.startswith('[node') and 'parent="."' in line:
        skip = False
        
    if skip:
        continue
        
    new_lines.append(line)
    
    if line.startswith('[node name="Visuals"'):
        new_lines.append('[node name="Base" type="Sprite2D" parent="Visuals"]\n')
        new_lines.append('hframes = 9\n')
        new_lines.append('vframes = 56\n')
        new_lines.append('[node name="Legs" type="Sprite2D" parent="Visuals"]\n')
        new_lines.append('hframes = 9\n')
        new_lines.append('vframes = 56\n')
        new_lines.append('[node name="Feet" type="Sprite2D" parent="Visuals"]\n')
        new_lines.append('hframes = 9\n')
        new_lines.append('vframes = 56\n')
        new_lines.append('[node name="Chest" type="Sprite2D" parent="Visuals"]\n')
        new_lines.append('hframes = 9\n')
        new_lines.append('vframes = 56\n')
        new_lines.append('[node name="Head" type="Sprite2D" parent="Visuals"]\n')
        new_lines.append('hframes = 9\n')
        new_lines.append('vframes = 56\n')
        new_lines.append('[node name="Hands" type="Sprite2D" parent="Visuals"]\n')
        new_lines.append('hframes = 9\n')
        new_lines.append('vframes = 56\n')

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.writelines(new_lines)
