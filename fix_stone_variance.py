import re

with open('scenes/objects/stone.tscn', 'r') as f:
    content = f.read()

pattern = r'(max_hp = 6\n)'
content = re.sub(pattern, r'\1hp_variance = 2\n', content)

with open('scenes/objects/stone.tscn', 'w') as f:
    f.write(content)

