import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

# Add ext_resource for tileset if not present
if 'res://resources/tileset.tres' not in content:
    content = content.replace('[node name="HomeIsland"', 
                              '[ext_resource type="TileSet" uid="uid://bbrgwvpje8t2u" path="res://resources/tileset.tres" id="5_ts"]\n\n[node name="HomeIsland"')

# The new layers string
layers = """[node name="WaterLayer" type="TileMapLayer" parent="."]
z_index = -1
tile_set = ExtResource("5_ts")

[node name="GroundLayer" type="TileMapLayer" parent="."]
tile_set = ExtResource("5_ts")

[node name="RoadsLayer" type="TileMapLayer" parent="."]
tile_set = ExtResource("5_ts")

[node name="ShadowsLayer" type="TileMapLayer" parent="."]
modulate = Color(0, 0, 0, 0.392157)
tile_set = ExtResource("5_ts")

[node name="MountainsBordersLayer" type="TileMapLayer" parent="."]
y_sort_enabled = true
tile_set = ExtResource("5_ts")

[node name="MountainsTopsLayer" type="TileMapLayer" parent="."]
y_sort_enabled = true
z_index = 1
tile_set = ExtResource("5_ts")

[node name="HousesLayer" type="TileMapLayer" parent="."]
y_sort_enabled = true
tile_set = ExtResource("5_ts")

[node name="ObjectsLayer" type="TileMapLayer" parent="."]
y_sort_enabled = true
tile_set = ExtResource("5_ts")

[node name="CanopyLayer" type="TileMapLayer" parent="."]
z_index = 2
tile_set = ExtResource("5_ts")
"""

# Replace old layers
pattern = r'\[node name="GroundLayer".*?(?=\[node name="Player")'
content = re.sub(pattern, layers + '\n', content, flags=re.DOTALL)

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
