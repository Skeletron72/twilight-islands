import re

def fix(filepath, occ_y, occ_w, occ_h):
    with open(filepath, 'r') as f:
        content = f.read()

    # Fix occluder position - match [node name="OccluderArea" ... ]
    pattern2 = r'(\[node name="OccluderArea" type="Area2D"[^\]]*\]\n(?:position = [^\n]+\n)?)'
    
    # We must ensure we retain the exact [node...] line so we don't destroy the unique_id.
    # We will just replace position if it exists, or insert it.
    
    def repl(match):
        node_line = match.group(0).split('\n')[0] # The [node...] line
        return node_line + '\nposition = Vector2(0, ' + str(occ_y) + ')\n'
        
    content = re.sub(pattern2, repl, content)
    
    # Update Occluder size
    content = re.sub(r'(\[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"\]\nsize = )Vector2\([^\)]+\)', r'\1Vector2(' + str(occ_w) + ', ' + str(occ_h) + ')', content)

    with open(filepath, 'w') as f:
        f.write(content)

# Tree
fix('scenes/objects/tree.tscn', -22, 28, 24)

# Stone and Twilight Ore
fix('scenes/objects/stone.tscn', -18, 28, 20)
fix('scenes/levels/twilight_ore.tscn', -18, 28, 20)

