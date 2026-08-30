import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

content = content.replace('position = Vector2(50, 50)', 'position = Vector2(250, 250)')
content = content.replace('position = Vector2(80, 40)', 'position = Vector2(280, 240)')
content = content.replace('position = Vector2(20, 90)', 'position = Vector2(220, 290)')

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
