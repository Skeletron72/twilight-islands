import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

# Add ext_resources
if 'res://scenes/objects/tree.tscn' not in content:
    content = content.replace('[node name="HomeIsland"', 
                              '[ext_resource type="PackedScene" uid="uid://tree_obj_123" path="res://scenes/objects/tree.tscn" id="6_tree"]\n[ext_resource type="PackedScene" uid="uid://stone_obj_123" path="res://scenes/objects/stone.tscn" id="7_stone"]\n[ext_resource type="PackedScene" uid="uid://boat_extract123" path="res://scenes/levels/extraction_zone.tscn" id="8_boat"]\n[ext_resource type="PackedScene" uid="uid://m0b1l3ctrl5" path="res://scenes/ui/mobile_controls.tscn" id="9_mob"]\n\n[node name="HomeIsland"')

# Add nodes
nodes = """
[node name="Tree1" parent="." instance=ExtResource("6_tree")]
position = Vector2(200, 100)
is_permanent = true

[node name="Tree2" parent="." instance=ExtResource("6_tree")]
position = Vector2(250, 120)
is_permanent = true

[node name="Tree3" parent="." instance=ExtResource("6_tree")]
position = Vector2(180, 200)
is_permanent = true

[node name="Stone1" parent="." instance=ExtResource("7_stone")]
position = Vector2(400, 100)
is_permanent = true

[node name="Stone2" parent="." instance=ExtResource("7_stone")]
position = Vector2(450, 80)
is_permanent = true

[node name="Boat" parent="." instance=ExtResource("8_boat")]
position = Vector2(100, 300)
target_scene = "res://scenes/levels/raid_island.tscn"
is_raid_start = true

[node name="MobileControls" parent="." instance=ExtResource("9_mob")]
"""

# Append to end
content += nodes

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
