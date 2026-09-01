import glob
import os
import re

for filepath in glob.glob('scenes/objects/trees/*.tscn'):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    is_big = 'big' in filepath
    static_y = -4 if is_big else -3
    static_h = 12 if is_big else 8
    tree_static_top = static_y - static_h / 2.0
    
    # Gap is between tree_static_top (-10) and player_top_when_in_front (-2)
    # We set occ_btm to exactly in the middle of the gap
    occ_btm = -6.0
    
    # Read the canopy top from the file to calculate occ_top
    occ_top = -59.0 # Default fallback
    
    with open(filepath, 'r') as f:
        content = f.read()
        match = re.search(r'\[node name="Sprite2D".*?position = Vector2\(0, ([0-9.-]+)\)', content, re.DOTALL)
        if match:
            sprite_pos_y = float(match.group(1))
            # Find the texture to get height
            match2 = re.search(r'offset = Vector2\(0, ([0-9.-]+)\)', content)
            if match2:
                sprite_offset_y = float(match2.group(1))
                h = -sprite_offset_y * 2
                canopy_top = sprite_pos_y - h
                occ_top = canopy_top + 4
                
    occ_h = occ_btm - occ_top
    occ_center_y = (occ_top + occ_btm) / 2.0
    
    current_node = None
    out_lines = []
    
    for i, line in enumerate(lines):
        if 'id="RectangleShape2D_occluder"' in lines[i-1] if i>0 else False:
            # Keep w, change h
            w = line.split('Vector2(')[1].split(',')[0]
            out_lines.append(f'size = Vector2({w}, {occ_h})\n')
            continue
            
        if line.startswith('[node'):
            if 'name="OccluderArea"' in line: current_node = "OccluderArea"
            else: current_node = "Other"
            out_lines.append(line)
            continue
            
        if line.startswith('position =') and current_node == "OccluderArea":
            out_lines.append(f'position = Vector2(0, {occ_center_y})\n')
        else:
            out_lines.append(line)
            
    with open(filepath, 'w') as f:
        f.writelines(out_lines)
