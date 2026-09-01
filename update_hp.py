import re

with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

# Replace hardcoded hp = 5 and hp = 3 with randi_range
content = content.replace("hp = 5", "hp = randi_range(4, 7)")
content = content.replace("hp = 3", "hp = randi_range(2, 4)")

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
