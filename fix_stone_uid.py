import glob
import re

for filepath in glob.glob('scenes/objects/stones/stone_*.tscn'):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Remove the invalid UID from the script resource line
    # Godot will use the path and regenerate the correct UID automatically
    content = re.sub(r'uid="uid://dfy8fnudi0laq" ', '', content)
    
    with open(filepath, 'w') as f:
        f.write(content)
