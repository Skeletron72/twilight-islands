import re

def run():
    new_terrains = {
        "TileSetAtlasSource_j1jjl": 16, # Луговые
        "TileSetAtlasSource_qw3fs": 17, # Лесные
        "TileSetAtlasSource_klc0i": 18, # Сухие
        "TileSetAtlasSource_yva2n": 19  # Волшебные
    }

    tiles_to_patch = {
        "1:3": ["right_side"],
        "2:3": ["left_side", "right_side"],
        "3:3": ["left_side"],
        "1:4": ["right_side"],
        "2:4": ["left_side", "right_side"],
        "3:4": ["left_side"],
        "1:5": ["right_side"],
        "2:5": ["left_side", "right_side"],
        "3:5": ["left_side"],
        "5:1": ["bottom_side", "left_side", "bottom_left_corner", "right_side", "bottom_right_corner", "top_side", "top_right_corner"],
        "6:1": ["bottom_side", "left_side", "bottom_left_corner", "right_side", "bottom_right_corner", "top_side", "top_left_corner"],
        "5:2": ["bottom_side", "left_side", "right_side", "bottom_right_corner", "top_side", "top_right_corner", "top_left_corner"],
        "6:2": ["bottom_side", "left_side", "bottom_left_corner", "right_side", "top_side", "top_right_corner", "top_left_corner"]
    }

    with open("resources/cute_tileset.tres", "r") as f:
        lines = f.readlines()

    # Step 1: Add terrain definitions
    terrain_defs = """terrain_set_0/terrain_16/name = "Горы (Луговые)"
terrain_set_0/terrain_16/color = Color(0.4, 0.4, 0.4, 1)
terrain_set_0/terrain_17/name = "Горы (Лесные)"
terrain_set_0/terrain_17/color = Color(0.3, 0.3, 0.3, 1)
terrain_set_0/terrain_18/name = "Горы (Сухие)"
terrain_set_0/terrain_18/color = Color(0.5, 0.4, 0.3, 1)
terrain_set_0/terrain_19/name = "Горы (Волшебные)"
terrain_set_0/terrain_19/color = Color(0.6, 0.3, 0.6, 1)
"""
    
    out_lines = []
    inserted_defs = False
    
    # We also need to strip out the old patches so they don't duplicate
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Insert terrain defs before the first custom_data_layer
        if not inserted_defs and line.startswith("custom_data_layer_0/name"):
            out_lines.extend([l + "\n" for l in terrain_defs.split("\n") if l])
            inserted_defs = True
            
        # Strip old terrain patches
        if re.match(r'^\d+:\d+/0/terrain_set = 0', line) or re.match(r'^\d+:\d+/0/terrain = ', line) or re.match(r'^\d+:\d+/0/terrains_peering_bit/', line):
            # Only strip if it's one of our patched tiles! Wait, no, we only strip what we added previously.
            # Actually, parsing this safely is hard. Let's just run it if the user confirms.
            pass
            
        i += 1

if __name__ == "__main__":
    # Just a placeholder for now until user confirms
    pass
