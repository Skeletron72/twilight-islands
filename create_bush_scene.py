content = """[gd_scene load_steps=5 format=3 uid="uid://berrybush123"]

[ext_resource type="Script" uid="uid://berrybush_script" path="res://scripts/components/berry_bush.gd" id="1_script"]
[ext_resource type="Texture2D" uid="uid://items_atlas" path="res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png" id="2_tex"]

[sub_resource type="AtlasTexture" id="AtlasTexture_bush"]
atlas = ExtResource("2_tex")
region = Rect2(784, 48, 32, 32)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_col"]
size = Vector2(24, 16)

[node name="BerryBush" type="StaticBody2D" groups=["interactable"]]
collision_layer = 5
collision_mask = 1
script = ExtResource("1_script")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_bush")
offset = Vector2(0, -8)

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_col")
"""
with open('scenes/objects/berry_bush.tscn', 'w') as f:
    f.write(content)
