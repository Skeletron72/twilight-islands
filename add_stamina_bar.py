import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Add SubResource at the top
subresource = """[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_stamina"]
bg_color = Color(0.2, 0.8, 0.2, 1)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2

"""
content = content.replace('[node name="UILayer"', subresource + '[node name="UILayer"')

# Add ProgressBar after TimeLabel
timelabel_block = """[node name="TimeLabel" type="Label" parent="MarginContainer/VBoxContainer"]
layout_mode = 2
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/outline_size = 4
text = "Day 1 - Morning (Press Space to advance)"
"""

progressbar_block = """
[node name="StaminaBar" type="ProgressBar" parent="MarginContainer/VBoxContainer"]
custom_minimum_size = Vector2(150, 12)
layout_mode = 2
size_flags_horizontal = 0
theme_override_styles/fill = SubResource("StyleBoxFlat_stamina")
value = 100.0
show_percentage = false
"""

if 'StaminaBar' not in content:
    content = content.replace(timelabel_block, timelabel_block + progressbar_block)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)

