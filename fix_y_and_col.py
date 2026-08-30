import re

def fix(filepath, col_y, occ_y, occ_size_y, occ_size_x):
    with open(filepath, 'r') as f:
        content = f.read()

    # Move static body shape UP so bottom edge matches 0,0
    # Search for StaticBody CollisionShape2D and add/replace position
    pattern = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"\]\nshape = [^\n]+)'
    replacement = r'\1\nposition = Vector2(0, ' + str(col_y) + ')'
    content = re.sub(pattern, replacement, content)

    # Enlarge Occluder shape and move it down
    # First, replace the sub_resource size for occluder
    content = re.sub(r'(\[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"\]\nsize = )Vector2\([^\)]+\)', r'\1Vector2(' + str(occ_size_x) + ', ' + str(occ_size_y) + ')', content)
    
    # Then replace OccluderArea position
    content = re.sub(r'(\[node name="OccluderArea" type="Area2D" parent="\."\]\nposition = )Vector2\([^\)]+\)', r'\1Vector2(0, ' + str(occ_y) + ')', content)

    with open(filepath, 'w') as f:
        f.write(content)

# Tree: static shape h=10 -> center at -5
# Occluder: cover whole tree above roots, size 40x40, pos -20
fix('scenes/objects/tree.tscn', -5, -20, 40, 40)

# Stone: static shape h=14 -> center at -7
# Occluder: size 40x30, pos -15
fix('scenes/objects/stone.tscn', -7, -15, 30, 40)
fix('scenes/levels/twilight_ore.tscn', -7, -15, 30, 40)
