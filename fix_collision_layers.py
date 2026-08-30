import re

files = ['scenes/objects/campfire.tscn', 'scenes/objects/storage_box.tscn']

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    content = content.replace('collision_layer = 1\ncollision_mask = 1', 'collision_layer = 5\ncollision_mask = 1')
    
    with open(filepath, 'w') as f:
        f.write(content)
