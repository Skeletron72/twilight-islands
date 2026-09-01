import os
import subprocess

types = [("oak", "Oak"), ("birch", "Birch"), ("spruce", "Spruce"), ("fruit", "Fruit")]
sizes = [("small", "Small"), ("medium", "Medium"), ("big", "Big")]

for size_id, size_name in sizes:
    for type_id, type_name in types:
        if size_name == "Big" and type_name == "Spruce":
            filename = f"Big_Spruce_tree.png"
        else:
            filename = f"{size_name}_{type_name}_Tree.png"
            
        path = f"assets/new_assets/Cute_Fantasy/Trees/{filename}"
        
        try:
            out = subprocess.check_output(["file", path]).decode('utf-8')
            # "assets/...: PNG image data, 192 x 80, ..."
            dim_str = out.split(",")[1].strip()
            w_str, h_str = dim_str.split("x")
            w = float(w_str.strip())
            h = float(h_str.strip())
        except Exception as e:
            print(f"Failed to process {path}: {e}")
            continue
            
        frame_w = w / 3.0
        frame_h = h
        
        offset_y = -frame_h / 2.0
        
        # Base Collision shape (circle)
        radius = 16.0 if frame_w > 32 else 8.0
        
        # Interaction static body (rectangle)
        rect_w = 24.0 if frame_w > 32 else 12.0
        rect_h = 6.0
        rect_y = -3.0
        
        # Occluder (top of tree)
        occ_w = frame_w * 0.7
        occ_h = frame_h * 0.6
        occ_y = -frame_h + (occ_h / 2.0)
        
        scene_content = f"""[gd_scene format=3 uid="uid://tree_{size_id}_{type_id}"]

[ext_resource type="Script" path="res://scripts/components/tree.gd" id="1_script"]
[ext_resource type="Texture2D" uid="uid://tex_{size_id}_{type_id}" path="res://{path}" id="2_tex"]

[sub_resource type="CircleShape2D" id="CircleShape2D_base"]
radius = {radius}

[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"]
size = Vector2({rect_w}, {rect_h})

[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"]
size = Vector2({occ_w}, {occ_h})

[node name="{size_name}{type_name}Tree" type="Area2D"]
y_sort_enabled = true
position = Vector2(0, 4)
collision_layer = 2
collision_mask = 0
script = ExtResource("1_script")
tree_type = "{type_id}"
tree_size = "{size_id}"

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_tex")
hframes = 3
frame = 1
offset = Vector2(0, {offset_y})

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, -6.0)
shape = SubResource("CircleShape2D_base")

[node name="StaticBody" type="StaticBody2D" parent="."]
collision_mask = 0

[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"]
position = Vector2(0, {rect_y})
shape = SubResource("RectangleShape2D_static")

[node name="OccluderArea" type="Area2D" parent="."]
position = Vector2(0, {occ_y})
collision_layer = 0
script = ExtResource("res://scripts/components/occluder.gd")

[node name="CollisionShape2D" type="CollisionShape2D" parent="OccluderArea"]
shape = SubResource("RectangleShape2D_occluder")
"""
        with open(f"scenes/objects/trees/{size_id}_{type_id}.tscn", "w") as f:
            f.write(scene_content)
