import re

with open('scenes/levels/raid_island.tscn', 'r') as f:
    content = f.read()

# Extract GroundLayer tile_map_data
match = re.search(r'\[node name="GroundLayer".*?tile_map_data = PackedByteArray\("([^"]+)"\)', content, re.DOTALL)
if match:
    # Well, decoding Godot 4 PackedByteArray from base64 and reading the binary is hard in python.
    pass
