import re

def fix_object(filepath, offset_y, size_x, size_y, col_w, col_h):
    with open(filepath, 'r') as f:
        content = f.read()
        
    # Add occluder script if not present
    if 'id="occluder_script"' not in content:
        content = content.replace('[node name=', '[ext_resource type="Script" path="res://scripts/components/occluder.gd" id="occluder_script"]\n[node name=', 1)
        
    # Add sprite offset
    content = re.sub(r'(\[node name="Sprite2D" [^\]]*\]\ntexture = [^\n]+)', r'\1\noffset = Vector2(0, ' + str(offset_y) + ')', content)
    
    # Move interactable collision shape up to match sprite
    content = re.sub(r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="\."[^\]]*\]\nshape = [^\n]+)', r'\1\nposition = Vector2(0, ' + str(offset_y) + ')', content)

    # Add StaticBody2D for physical collision
    static_body = f"""
[node name="StaticBody" type="StaticBody2D" parent="."]
collision_layer = 1
collision_mask = 0

[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"]
shape = SubResource("RectangleShape2D_static")
"""
    if 'name="StaticBody"' not in content:
        content += static_body
        
    # Add Occluder Area2D
    occluder = f"""
[node name="OccluderArea" type="Area2D" parent="."]
position = Vector2(0, {offset_y - (size_y * 0.25)})
collision_layer = 0
collision_mask = 1
script = ExtResource("occluder_script")

[node name="CollisionShape2D" type="CollisionShape2D" parent="OccluderArea"]
shape = SubResource("RectangleShape2D_occluder")
"""
    if 'name="OccluderArea"' not in content:
        content += occluder
        
    # Add SubResources for shapes
    sub_res = f"""
[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"]
size = Vector2({col_w}, {col_h})

[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"]
size = Vector2({size_x}, {size_y * 0.5})
"""
    if 'RectangleShape2D_static' not in content:
        content = content.replace('[node name=', sub_res + '\n[node name=', 1)

    with open(filepath, 'w') as f:
        f.write(content)

fix_object('scenes/objects/tree.tscn', -17, 32, 34, 16, 10)
fix_object('scenes/objects/stone.tscn', -16, 32, 32, 24, 14)
fix_object('scenes/levels/twilight_ore.tscn', -16, 32, 32, 24, 14)

