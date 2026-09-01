import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

# Find the Player node
player_regex = r'\[node name="Player" parent="\.".*?instance=ExtResource\("1_plr"\)\]\nposition = Vector2\([0-9.-]+, [0-9.-]+\)\n'
match = re.search(player_regex, content)
if match:
    player_str = match.group(0)
    # Remove it from root
    content = content.replace(player_str, '')
    
    # Change parent to Interactables
    player_str = player_str.replace('parent="."', 'parent="Interactables"')
    
    # Insert it right after [node name="Interactables" ...]
    int_regex = r'\[node name="Interactables" type="Node2D" parent="\.".*?\]\ny_sort_enabled = true\n'
    int_match = re.search(int_regex, content)
    if int_match:
        content = content[:int_match.end()] + '\n' + player_str + content[int_match.end():]

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)

