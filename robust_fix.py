import re

def fix(filepath, col_y, occ_y, occ_w, occ_h):
    with open(filepath, 'r') as f:
        content = f.read()

    # Fix static body position
    # find [node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody" ...]
    # and replace/add position
    pattern1 = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"[^\]]*\]\n(?:position = [^\n]+\n)?)shape = SubResource\("RectangleShape2D_static"\)'
    content = re.sub(pattern1, r'[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"]\nposition = Vector2(0, ' + str(col_y) + r')\nshape = SubResource("RectangleShape2D_static")', content)

    # Fix occluder position
    pattern2 = r'(\[node name="OccluderArea" type="Area2D" parent="\."[^\]]*\]\n(?:position = [^\n]+\n)?)'
    content = re.sub(pattern2, r'[node name="OccluderArea" type="Area2D" parent="."]\nposition = Vector2(0, ' + str(occ_y) + r')\n', content)
    
    # Also clean up the collision shape inside OccluderArea to have no position offset
    pattern3 = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="OccluderArea"[^\]]*\]\n(?:position = [^\n]+\n)?)shape = SubResource\("RectangleShape2D_occluder"\)'
    content = re.sub(pattern3, r'[node name="CollisionShape2D" type="CollisionShape2D" parent="OccluderArea"]\nshape = SubResource("RectangleShape2D_occluder")', content)

    # Update Occluder size
    content = re.sub(r'(\[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"\]\nsize = )Vector2\([^\)]+\)', r'\1Vector2(' + str(occ_w) + ', ' + str(occ_h) + ')', content)

    # Update Occluder script to make the tree MORE transparent (0.3 instead of 0.5)
    # Wait, the script has export var fade_alpha. We can just set it in the scene, or change the script.

    with open(filepath, 'w') as f:
        f.write(content)

fix('scenes/objects/tree.tscn', -5, -20, 50, 50)
fix('scenes/objects/stone.tscn', -7, -15, 40, 40)
fix('scenes/levels/twilight_ore.tscn', -7, -15, 40, 40)

# Change fade_alpha default in script
with open('scripts/components/occluder.gd', 'r') as f:
    s = f.read()
s = s.replace('fade_alpha: float = 0.5', 'fade_alpha: float = 0.25')
with open('scripts/components/occluder.gd', 'w') as f:
    f.write(s)

