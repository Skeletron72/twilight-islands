import glob
import re

for filepath in glob.glob('scenes/objects/trees/*.tscn'):
    with open(filepath, 'r') as f:
        content = f.read()
    
    is_big = "big" in filepath
    
    trunk_w = 16.0 if is_big else 10.0
    trunk_h = 8.0 if is_big else 6.0
    trunk_y = -4.0 if is_big else -3.0
    
    # 1. Replace the SubResource for CircleShape2D_base with a RectangleShape2D
    sub_circle_pattern = r'\[sub_resource type="CircleShape2D" id="CircleShape2D_base"\]\nradius = [0-9.]+\n'
    sub_rect = f'[sub_resource type="RectangleShape2D" id="RectangleShape2D_base"]\nsize = Vector2({trunk_w}, {trunk_h})\n'
    content = re.sub(sub_circle_pattern, sub_rect, content)
    
    # 2. Update the CollisionShape2D node for the base
    node_base_pattern = r'\[node name="CollisionShape2D" type="CollisionShape2D" parent="."\]\nposition = Vector2\([0-9.-]+, [0-9.-]+\)\nshape = SubResource\("CircleShape2D_base"\)\n'
    node_rect = f'[node name="CollisionShape2D" type="CollisionShape2D" parent="."]\nposition = Vector2(0, {trunk_y})\nshape = SubResource("RectangleShape2D_base")\n'
    content = re.sub(node_base_pattern, node_rect, content)
    
    # 3. Update the interaction StaticBody shape to be slightly larger than the base
    int_w = trunk_w + 6.0
    int_h = trunk_h + 4.0
    int_y = trunk_y
    
    sub_static_pattern = r'\[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"\]\nsize = Vector2\([0-9.-]+, [0-9.-]+\)\n'
    sub_static = f'[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"]\nsize = Vector2({int_w}, {int_h})\n'
    content = re.sub(sub_static_pattern, sub_static, content)
    
    node_static_pattern = r'\[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"\]\nposition = Vector2\([0-9.-]+, [0-9.-]+\)\nshape = SubResource\("RectangleShape2D_static"\)\n'
    node_static = f'[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"]\nposition = Vector2(0, {int_y})\nshape = SubResource("RectangleShape2D_static")\n'
    content = re.sub(node_static_pattern, node_static, content)

    with open(filepath, 'w') as f:
        f.write(content)
