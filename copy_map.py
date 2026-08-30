import re

# 1. Read home_island.tscn
with open('scenes/levels/home_island.tscn', 'r') as f:
    home_content = f.read()

# 2. Extract TileSet resource definition
ts_match = re.search(r'\[ext_resource type="TileSet"[^\]]+\]', home_content)
ts_res = ts_match.group(0) if ts_match else '[ext_resource type="TileSet" uid="uid://bbrgwvpje8t2u" path="res://resources/tileset.tres" id="5_ts"]'

# 3. Extract the entire WorldMap node and its children
# A bit tricky with regex, but we can find the start of WorldMap and end before the next root-level node
worldmap_match = re.search(r'(\[node name="WorldMap" type="Node2D"[^\]]*\].*?)\n\[node name="Interactables"', home_content, re.DOTALL)
if worldmap_match:
    worldmap_data = worldmap_match.group(1)
else:
    print("Failed to find WorldMap")
    exit(1)

# 4. Read raid_island.tscn
with open('scenes/levels/raid_island.tscn', 'r') as f:
    raid_content = f.read()

# 5. Inject TileSet resource if not exists
if 'type="TileSet"' not in raid_content:
    raid_content = raid_content.replace('[ext_resource', ts_res + '\n[ext_resource', 1)
else:
    # We might need to ensure the id matches what worldmap uses ("5_ts")
    # Actually, WorldMap nodes from home_island use "5_ts", so we should ensure "5_ts" is the ID.
    pass

# 6. Inject WorldMap into raid_island
# Find the start of the root node and insert right after
pattern = r'(\[node name="RaidIsland" type="Node2D"[^\]]*\]\n(?:y_sort_enabled = true\n)?)'
raid_content = re.sub(pattern, r'\1' + '\n' + worldmap_data + '\n\n', raid_content)

with open('scenes/levels/raid_island.tscn', 'w') as f:
    f.write(raid_content)
print("Copied successfully.")

