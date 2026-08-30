import re

with open('scenes/ui/hotbar_ui.tscn', 'r') as f:
    content = f.read()

# Replace Shadow node order for all 4 slots
for i in range(4):
    old_order = f"""[node name="Shadow" type="TextureRect" parent="HBoxContainer/Slot{i}"]
visible = false
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource("AtlasTexture_shadow")
texture_filter = 1
expand_mode = 1
stretch_mode = 5

[node name="Base" type="TextureRect" parent="HBoxContainer/Slot{i}"]"""

    new_order = f"""[node name="Base" type="TextureRect" parent="HBoxContainer/Slot{i}"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource("AtlasTexture_slot")
texture_filter = 1
expand_mode = 1
stretch_mode = 5

[node name="Shadow" type="TextureRect" parent="HBoxContainer/Slot{i}"]
visible = false
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource("AtlasTexture_shadow")
texture_filter = 1
expand_mode = 1
stretch_mode = 5"""
    
    # We also need to remove the trailing [node name="Base" that we swapped.
    # It's easier to just swap the text blocks.
    
    # Actually, a regex is safer for this block swap:
    shadow_block = f"""\\[node name="Shadow" type="TextureRect" parent="HBoxContainer/Slot{i}"\\]
visible = false
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource\\("AtlasTexture_shadow"\\)
texture_filter = 1
expand_mode = 1
stretch_mode = 5"""

    base_block = f"""\\[node name="Base" type="TextureRect" parent="HBoxContainer/Slot{i}"\\]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource\\("AtlasTexture_slot"\\)
texture_filter = 1
expand_mode = 1
stretch_mode = 5"""

    content = re.sub(f'{shadow_block}\n\n{base_block}', base_block.replace('\\', '') + '\n\n' + shadow_block.replace('\\', ''), content)

with open('scenes/ui/hotbar_ui.tscn', 'w') as f:
    f.write(content)
