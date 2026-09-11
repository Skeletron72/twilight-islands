import sys

scene_content = """[gd_scene load_steps=2 format=3 uid="uid://cavesupport01"]

[ext_resource type="Texture2D" uid="uid://bmr5bjqhgglcx" path="res://assets/new_assets/Cute_Fantasy/Tiles/Cave/Cave_Walls.png" id="1_tex"]

[node name="CaveSupport" type="Node2D"]
y_sort_enabled = true

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("1_tex")
region_enabled = true
region_rect = Rect2(0, 0, 80, 48)
offset = Vector2(40, -8)
"""

with open("scenes/objects/dungeon/cave_support.tscn", "w") as f:
    f.write(scene_content)
