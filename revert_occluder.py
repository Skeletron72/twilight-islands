import glob
import os
import re

for filepath in glob.glob('scenes/objects/trees/*.tscn'):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    with open(filepath, 'r') as f:
        content = f.read()
        match = re.search(r'\[node name="Sprite2D".*?position = Vector2\(0, ([0-9.-]+)\)', content, re.DOTALL)
        if match:
            sprite_pos_y = float(match.group(1))
            match2 = re.search(r'offset = Vector2\(0, ([0-9.-]+)\)', content)
            if match2:
                sprite_offset_y = float(match2.group(1))
                h = -sprite_offset_y * 2
                
                # Retrieve the original 'top' value from the dictionary we used earlier
                # We can roughly estimate it based on h and canopy_top
                # Actually, I'll just use the exact logic from apply_tree_coords.py!
                pass

tree_data = {
    'small_oak': {'w': 96, 'h': 64, 'btm': 12, 'top': 32, 'frame_w': 32},
    'medium_spruce': {'w': 96, 'h': 48, 'btm': 11, 'top': 0, 'frame_w': 32},
    'big_birch': {'w': 96, 'h': 80, 'btm': 10, 'top': 1, 'frame_w': 32},
    'medium_oak': {'w': 96, 'h': 48, 'btm': 11, 'top': 3, 'frame_w': 32},
    'big_oak': {'w': 192, 'h': 80, 'btm': 8, 'top': 9, 'frame_w': 64},
    'small_spruce': {'w': 96, 'h': 64, 'btm': 12, 'top': 33, 'frame_w': 32},
    'medium_fruit': {'w': 96, 'h': 64, 'btm': 11, 'top': 19, 'frame_w': 32},
    'small_birch': {'w': 96, 'h': 64, 'btm': 11, 'top': 31, 'frame_w': 32},
    'medium_birch': {'w': 96, 'h': 48, 'btm': 11, 'top': 0, 'frame_w': 32},
    'small_fruit': {'w': 96, 'h': 64, 'btm': 12, 'top': 30, 'frame_w': 32},
    'big_fruit': {'w': 96, 'h': 64, 'btm': 11, 'top': 7, 'frame_w': 32},
    'big_spruce': {'w': 192, 'h': 80, 'btm': 8, 'top': 3, 'frame_w': 64},
}

for filepath in glob.glob('scenes/objects/trees/*.tscn'):
    basename = os.path.basename(filepath).replace('.tscn', '')
    if basename not in tree_data: continue
    data = tree_data[basename]
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    sprite_pos_y = 2 + data['btm']
    canopy_top = sprite_pos_y - data['h'] + data['top']
    trunk_base = 2
    
    # ORIGINAL OCCLUDER LOGIC:
    occ_top = canopy_top + 8
    occ_btm = trunk_base - 12
    if occ_btm <= occ_top: occ_btm = occ_top + 10
    
    occ_h = occ_btm - occ_top
    occ_center_y = (occ_top + occ_btm) / 2.0
    
    current_node = None
    out_lines = []
    
    for i, line in enumerate(lines):
        if 'id="RectangleShape2D_occluder"' in lines[i-1] if i>0 else False:
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
