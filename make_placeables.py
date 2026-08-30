import os

campfire = """[gd_scene load_steps=5 format=3 uid="uid://campfire123"]

[ext_resource type="Texture2D" uid="uid://items_atlas" path="res://resources/items/Items.png" id="1_tex"]

[sub_resource type="AtlasTexture" id="AtlasTexture_campfire"]
atlas = ExtResource("1_tex")
region = Rect2(128, 304, 16, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_col"]
size = Vector2(14, 14)

[sub_resource type="CircleShape2D" id="CircleShape2D_int"]
radius = 24.0

[node name="Campfire" type="StaticBody2D" groups=["interactable"]]
y_sort_enabled = true
collision_layer = 1
collision_mask = 1

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_campfire")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, 1)
shape = SubResource("RectangleShape2D_col")

[node name="PointLight2D" type="PointLight2D" parent="."]
color = Color(1, 0.7, 0.4, 1)
energy = 0.8
texture_scale = 3.0
# Just a soft light, we can use a basic gradient or built in texture if needed
# we'll omit texture so it uses default or needs a gradient texture
"""

storage = """[gd_scene load_steps=4 format=3 uid="uid://storagebox123"]

[ext_resource type="Texture2D" uid="uid://items_atlas" path="res://resources/items/Items.png" id="1_tex"]

[sub_resource type="AtlasTexture" id="AtlasTexture_box"]
atlas = ExtResource("1_tex")
region = Rect2(112, 304, 16, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_col"]
size = Vector2(16, 14)

[node name="StorageBox" type="StaticBody2D" groups=["interactable"]]
y_sort_enabled = true
collision_layer = 1
collision_mask = 1

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_box")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, 1)
shape = SubResource("RectangleShape2D_col")
"""

with open('scenes/objects/campfire.tscn', 'w') as f:
    f.write(campfire)
    
with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(storage)
