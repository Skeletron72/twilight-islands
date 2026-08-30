import re

with open('scenes/ui/inventory_slot.tscn', 'r') as f:
    content = f.read()

# Add font ext_resource
if 'WarmPixel.ttf' not in content:
    content = content.replace('[ext_resource type="Texture2D" path="res://assets/sprites/ui/inventory/UI.png" id="tex_ui"]', 
                              '[ext_resource type="Texture2D" path="res://assets/sprites/ui/inventory/UI.png" id="tex_ui"]\n[ext_resource type="FontFile" path="res://assets/fonts/WarmPixel.ttf" id="font_warm"]')

# Update Amount label
old_amount = """[node name="Amount" type="Label" parent="."]
mouse_filter = 2
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -40.0
offset_top = -23.0
grow_horizontal = 0
grow_vertical = 0
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 1
theme_override_constants/shadow_offset_y = 1
theme_override_constants/outline_size = 2
theme_override_font_sizes/font_size = 12
text = "99"
horizontal_alignment = 2"""

new_amount = """[node name="Amount" type="Label" parent="."]
mouse_filter = 2
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -40.0
offset_top = -23.0
grow_horizontal = 0
grow_vertical = 0
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 1
theme_override_constants/shadow_offset_y = 1
theme_override_constants/outline_size = 2
theme_override_fonts/font = ExtResource("font_warm")
theme_override_font_sizes/font_size = 12
text = "99"
horizontal_alignment = 2"""

content = content.replace(old_amount, new_amount)

with open('scenes/ui/inventory_slot.tscn', 'w') as f:
    f.write(content)
