import re

def clean_sprite(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove modulate
    content = re.sub(r'modulate = Color\([^)]+\)\n', '', content)
    
    # Remove scale
    content = re.sub(r'scale = Vector2\([^)]+\)\n', '', content)

    with open(filepath, 'w') as f:
        f.write(content)

clean_sprite('scenes/objects/tree.tscn')
clean_sprite('scenes/objects/stone.tscn')
clean_sprite('scenes/characters/slime.tscn')
clean_sprite('scenes/levels/extraction_zone.tscn')
