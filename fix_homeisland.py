with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

content = content.replace('[node name="HomeIsland" type="Node2D" unique_id=848174927]', '[node name="HomeIsland" type="Node2D" unique_id=848174927]\ny_sort_enabled = true')

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
