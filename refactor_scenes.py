import re

def refactor_scene(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # 1. Remove IslandGround Polygon2D entirely
    content = re.sub(r'\[node name="IslandGround" type="Polygon2D".*?polygon = PackedVector2Array\([^)]*\)\n', '', content, flags=re.DOTALL)
    
    # 2. Group TileMapLayers under WorldMap
    layers = ["WaterLayer", "GroundLayer", "RoadsLayer", "ShadowsLayer", "MountainsBordersLayer", "MountainsTopsLayer", "HousesLayer", "ObjectsLayer", "CanopyLayer"]
    
    if '[node name="WorldMap"' not in content:
        # Find the first layer
        first_layer_match = re.search(r'\[node name="WaterLayer"', content)
        if first_layer_match:
            idx = first_layer_match.start()
            content = content[:idx] + '[node name="WorldMap" type="Node2D" parent="."]\n\n' + content[idx:]
    
    for layer in layers:
        # Change parent="." to parent="WorldMap"
        content = re.sub(rf'\[node name="{layer}" type="TileMapLayer" parent="\."(.*?)\]', rf'[node name="{layer}" type="TileMapLayer" parent="WorldMap"\1]', content)

    # 3. Group interactables (Trees, Stones) under Interactables
    if '[node name="Interactables"' not in content:
        # find where Player is, we can just insert Interactables Node before it or just after WorldMap
        content = content.replace('[node name="Player"', '[node name="Interactables" type="Node2D" parent="."]\n\n[node name="Player"')

    # Move Trees and Stones
    content = re.sub(r'\[node name="(Tree\d+|Stone\d+)" parent="\."(.*?)\]', rf'[node name="\1" parent="Interactables"\2]', content)

    with open(filepath, 'w') as f:
        f.write(content)

refactor_scene('scenes/levels/home_island.tscn')
refactor_scene('scenes/levels/raid_island.tscn')

