import re

with open('scenes/objects/berry_bush.tscn', 'r') as f:
    content = f.read()

content = content.replace('groups=["interactable"]', 'groups=["interactable"]\ny_sort_enabled = true')

with open('scenes/objects/berry_bush.tscn', 'w') as f:
    f.write(content)
