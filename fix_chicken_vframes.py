import re

with open('scenes/characters/chicken.tscn', 'r') as f:
    content = f.read()

content = content.replace('hframes = 4', 'hframes = 4\nvframes = 2')

with open('scenes/characters/chicken.tscn', 'w') as f:
    f.write(content)
