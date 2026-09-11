import re
import sys

def run():
    target_sources = {
        "TileSetAtlasSource_j1jjl": 7,
        "TileSetAtlasSource_qw3fs": 8,
        "TileSetAtlasSource_klc0i": 14,
        "TileSetAtlasSource_yva2n": 15
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
        "3:5": ["left_side"]
    }

    with open("resources/cute_tileset.tres", "r") as f:
        lines = f.readlines()

    out_lines = []
    current_source = None
    terrain_id = None
    
    # We want to insert properties immediately after `X:Y/0 = 0` if it's our target source.
    # But wait, Godot might already have physics_layer properties there. We can just append them after the `X:Y/0 = 0` line.
    
    i = 0
    while i < len(lines):
        line = lines[i]
        out_lines.append(line)
        
        # Check if we entered a sub_resource
        m_sub = re.match(r'\[sub_resource type="TileSetAtlasSource" id="([^"]+)"\]', line)
        if m_sub:
            sid = m_sub.group(1)
            if sid in target_sources:
                current_source = sid
                terrain_id = target_sources[sid]
            else:
                current_source = None
                terrain_id = None
        
        # If we hit another block or another sub_resource, we might exit the current block. 
        # But `TileSetAtlasSource` spans until the next `[sub_resource]` or `[resource]`.
        if line.startswith("[") and not m_sub:
            if line.startswith("[resource]") or line.startswith("[sub_resource"):
                current_source = None
                
        # If we are in a target source, and we see a tile definition:
        if current_source and terrain_id is not None:
            m_tile = re.match(r'^(\d+:\d+)/0 = 0\s*$', line)
            if m_tile:
                coords = m_tile.group(1)
                if coords in tiles_to_patch:
                    # Insert the terrain and peering bits
                    out_lines.append(f"{coords}/0/terrain_set = 0\n")
                    out_lines.append(f"{coords}/0/terrain = {terrain_id}\n")
                    for bit in tiles_to_patch[coords]:
                        out_lines.append(f"{coords}/0/terrains_peering_bit/{bit} = {terrain_id}\n")
        
        i += 1

    with open("resources/cute_tileset.tres", "w") as f:
        f.writelines(out_lines)

    print("Patch applied successfully.")

if __name__ == "__main__":
    run()
