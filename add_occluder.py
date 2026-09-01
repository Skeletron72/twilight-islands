import glob

for filepath in glob.glob('scenes/objects/stones/stone_*.tscn'):
    with open(filepath, 'r') as f:
        content = f.read()
    
    if "OccluderArea" in content:
        continue
        
    ext_resource = '[ext_resource type="Script" path="res://scripts/components/occluder.gd" id="3_occ"]\n'
    content = content.replace('[ext_resource type="Script"', ext_resource + '[ext_resource type="Script"', 1)
    
    # Get the rock index from the filename
    idx = int(filepath.split('_')[-1].split('.')[0])
    is_large = idx >= 11
    
    occ_y = -18.0 if is_large else -12.0
    occ_w = 28.0 if is_large else 16.0
    occ_h = 20.0 if is_large else 12.0
    
    occluder_nodes = f"""
[node name="OccluderArea" type="Area2D" parent="."]
position = Vector2(0, {occ_y})
collision_layer = 0
script = ExtResource("3_occ")

[node name="CollisionShape2D" type="CollisionShape2D" parent="OccluderArea"]
shape = SubResource("RectangleShape2D_occluder")
"""
    
    # Add the SubResource for RectangleShape2D_occluder at the top
    sub_res = f"""[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"]
size = Vector2({occ_w}, {occ_h})

[node"""
    content = content.replace('[node', sub_res, 1)
    
    # Append the nodes at the end
    content += occluder_nodes
    
    with open(filepath, 'w') as f:
        f.write(content)
