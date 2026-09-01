import glob
import os
import re

# From parse_all_pngs.py
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
        content = f.read()
        
    # 1. Sprite Position and Offset
    sprite_pos_y = 2 + data['btm']
    sprite_offset_y = -data['h'] / 2.0
    
    # Sub: offset
    content = re.sub(r'offset = Vector2\(0, [0-9.-]+\)', f'offset = Vector2(0, {sprite_offset_y})', content)
    # Sub: position (might not exist on Sprite2D, so replace or append)
    if 'position = Vector2(0, ' in content.split('[node name="Sprite2D"')[1].split('[node name="CollisionShape2D"')[0]:
        # it exists
        sprite_block = content.split('[node name="Sprite2D"')[1].split('[node name="CollisionShape2D"')[0]
        new_sprite_block = re.sub(r'position = Vector2\(0, [0-9.-]+\)', f'position = Vector2(0, {sprite_pos_y})', sprite_block)
        content = content.replace(sprite_block, new_sprite_block)
    else:
        # insert after Sprite2D line
        content = content.replace('[node name="Sprite2D" type="Sprite2D" parent="."]\n', f'[node name="Sprite2D" type="Sprite2D" parent="."]\nposition = Vector2(0, {sprite_pos_y})\n')

    # 2. Base Collision
    base_w = 16 if is_big else 12
    base_h = 8 if is_big else 6
    base_y = -6 if is_big else -4
    
    content = re.sub(r'\[sub_resource type="RectangleShape2D" id="RectangleShape2D_base"\]\nsize = Vector2\([0-9.-]+, [0-9.-]+\)', f'[sub_resource type="RectangleShape2D" id="RectangleShape2D_base"]\nsize = Vector2({base_w}, {base_h})', content)
    
    base_col_block = content.split('[node name="CollisionShape2D" type="CollisionShape2D" parent="."]')[1].split('[node name="StaticBody"')[0]
    new_base_col_block = re.sub(r'position = Vector2\(0, [0-9.-]+\)', f'position = Vector2(0, {base_y})', base_col_block)
    content = content.replace(base_col_block, new_base_col_block)
    
    # 3. Static Body Interaction
    static_w = 22 if is_big else 16
    static_h = 12 if is_big else 8
    static_y = -4 if is_big else -3
    
    content = re.sub(r'\[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"\]\nsize = Vector2\([0-9.-]+, [0-9.-]+\)', f'[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"]\nsize = Vector2({static_w}, {static_h})', content)
    
    static_col_block = content.split('[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody"]')[1].split('[node name="OccluderArea"')[0]
    new_static_col_block = re.sub(r'position = Vector2\(0, [0-9.-]+\)', f'position = Vector2(0, {static_y})', static_col_block)
    content = content.replace(static_col_block, new_static_col_block)
    
    # 4. Occluder Area
    canopy_top = sprite_pos_y - data['h'] + data['top']
    trunk_base = 2
    occ_top = canopy_top + 8
    occ_btm = trunk_base - 12
    
    # Ensure occ_btm > occ_top (for very small trees)
    if occ_btm <= occ_top:
        occ_btm = occ_top + 10
        
    occ_h = occ_btm - occ_top
    occ_center_y = (occ_top + occ_btm) / 2.0
    occ_w = data['frame_w'] * 0.7
    
    content = re.sub(r'\[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"\]\nsize = Vector2\([0-9.-]+, [0-9.-]+\)', f'[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"]\nsize = Vector2({occ_w}, {occ_h})', content)
    
    occ_area_block = content.split('[node name="OccluderArea" type="Area2D" parent="."]')[1].split('[node name="CollisionShape2D"')[0]
    new_occ_area_block = re.sub(r'position = Vector2\(0, [0-9.-]+\)', f'position = Vector2(0, {occ_center_y})', occ_area_block)
    content = content.replace(occ_area_block, new_occ_area_block)
    
    occ_col_block = content.split('[node name="CollisionShape2D" type="CollisionShape2D" parent="OccluderArea"]')[1]
    if 'position =' in occ_col_block:
        new_occ_col_block = re.sub(r'position = Vector2\(0, [0-9.-]+\)', 'position = Vector2(0, 0)', occ_col_block)
    else:
        new_occ_col_block = '\nposition = Vector2(0, 0)\n' + occ_col_block.strip() + '\n'
    content = content.replace(occ_col_block, new_occ_col_block)
    
    with open(filepath, 'w') as f:
        f.write(content)
