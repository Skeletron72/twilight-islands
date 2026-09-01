import os

# Clean up the old stone.tscn
if os.path.exists('scenes/objects/stone.tscn'):
    os.remove('scenes/objects/stone.tscn')

# Generate 14 stone scenes
for i in range(1, 15):
    is_large = i >= 11
    
    # 1. Base properties
    radius = 24.0 if is_large else 16.0
    col_y = -16.0 if is_large else -8.0
    
    rect_w = 24.0 if is_large else 12.0
    rect_h = 10.0 if is_large else 6.0
    rect_y = -5.0 if is_large else -3.0
    
    offset_y = -16.0 if is_large else -8.0
    
    # We create unique UID strings (fake but Godot will regenerate them)
    uid = f"uid://stone_variant_{i}"
    
    scene_content = f"""[gd_scene format=3 uid="{uid}"]

[ext_resource type="Script" uid="uid://dfy8fnudi0laq" path="res://scripts/components/stone.gd" id="1_dest"]
[ext_resource type="Texture2D" uid="uid://rock{i}tex" path="res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Rock_Animations/Rock_{i}_Anim.png" id="2_tex"]

[sub_resource type="CircleShape2D" id="CircleShape2D_stone"]
radius = {radius}

[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"]
size = Vector2({rect_w}, {rect_h})

[node name="Stone_{i}" type="Area2D"]
y_sort_enabled = true
position = Vector2(0, 4)
collision_layer = 2
collision_mask = 0
script = ExtResource("1_dest")
rock_type = {i}

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_tex")
hframes = 8
offset = Vector2(0, {offset_y})

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, {col_y})
shape = SubResource("CircleShape2D_stone")

[node name="StaticBody" type="StaticBody2D" parent="."]
collision_mask = 0

[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"]
position = Vector2(0, {rect_y})
shape = SubResource("RectangleShape2D_static")
"""
    with open(f'scenes/objects/stone_{i}.tscn', 'w') as f:
        f.write(scene_content)
