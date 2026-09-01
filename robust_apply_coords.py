import glob
import os
import re

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
    if basename not in tree_data:
        continue
        
    data = tree_data[basename]
    is_big = 'big' in basename
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    # Variables to track what block we are in
    current_node = None
    
    out_lines = []
    
    sprite_pos_y = 2 + data['btm']
    sprite_offset_y = -data['h'] / 2.0
    
    base_w = 16 if is_big else 12
    base_h = 8 if is_big else 6
    base_y = -6 if is_big else -4
    
    static_w = 22 if is_big else 16
    static_h = 12 if is_big else 8
    static_y = -4 if is_big else -3
    
    canopy_top = sprite_pos_y - data['h'] + data['top']
    trunk_base = 2
    occ_top = canopy_top + 8
    occ_btm = trunk_base - 12
    if occ_btm <= occ_top: occ_btm = occ_top + 10
    occ_h = occ_btm - occ_top
    occ_center_y = (occ_top + occ_btm) / 2.0
    occ_w = data['frame_w'] * 0.7
    
    for i, line in enumerate(lines):
        # Update SubResources
        if 'id="RectangleShape2D_base"' in lines[i-1] if i>0 else False:
            out_lines.append(f'size = Vector2({base_w}, {base_h})\n')
            continue
        if 'id="RectangleShape2D_static"' in lines[i-1] if i>0 else False:
            out_lines.append(f'size = Vector2({static_w}, {static_h})\n')
            continue
        if 'id="RectangleShape2D_occluder"' in lines[i-1] if i>0 else False:
            out_lines.append(f'size = Vector2({occ_w}, {occ_h})\n')
            continue
            
        # Track node block
        if line.startswith('[node'):
            if 'name="Sprite2D"' in line: current_node = "Sprite2D"
            elif 'name="CollisionShape2D" type="CollisionShape2D" parent="."' in line: current_node = "BaseCol"
            elif 'name="StaticBody"' in line: current_node = "StaticBody"
            elif 'name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"' in line: current_node = "StaticCol"
            elif 'name="OccluderArea"' in line: current_node = "OccluderArea"
            elif 'name="CollisionShape2D" type="CollisionShape2D" parent="OccluderArea"' in line: current_node = "OccluderCol"
            else: current_node = "Other"
            
            out_lines.append(line)
            
            # If Sprite2D, check if next lines have position
            if current_node == "Sprite2D":
                has_pos = False
                for j in range(i+1, min(i+6, len(lines))):
                    if lines[j].startswith('position ='): has_pos = True
                    if lines[j].startswith('['): break
                if not has_pos:
                    out_lines.append(f'position = Vector2(0, {sprite_pos_y})\n')
                    
            if current_node == "OccluderCol":
                has_pos = False
                for j in range(i+1, min(i+4, len(lines))):
                    if lines[j].startswith('position ='): has_pos = True
                    if lines[j].startswith('['): break
                if not has_pos:
                    out_lines.append(f'position = Vector2(0, 0)\n')
            continue
            
        # Modify properties inside blocks
        if line.startswith('position ='):
            if current_node == "Sprite2D": out_lines.append(f'position = Vector2(0, {sprite_pos_y})\n')
            elif current_node == "BaseCol": out_lines.append(f'position = Vector2(0, {base_y})\n')
            elif current_node == "StaticCol": out_lines.append(f'position = Vector2(0, {static_y})\n')
            elif current_node == "OccluderArea": out_lines.append(f'position = Vector2(0, {occ_center_y})\n')
            elif current_node == "OccluderCol": out_lines.append(f'position = Vector2(0, 0)\n')
            else: out_lines.append(line)
        elif line.startswith('offset =') and current_node == "Sprite2D":
            out_lines.append(f'offset = Vector2(0, {sprite_offset_y})\n')
        else:
            out_lines.append(line)
            
    with open(filepath, 'w') as f:
        f.writelines(out_lines)

