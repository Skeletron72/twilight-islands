import re

files = ['scenes/objects/campfire.tscn', 'scenes/objects/storage_box.tscn']

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    content = content.replace('y_sort_enabled = true\ncollision_layer', 'collision_layer')
    
    with open(filepath, 'w') as f:
        f.write(content)

