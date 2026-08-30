import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Add HealthBar style
subresource = """[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_health_bg"]
bg_color = Color(0.1, 0.1, 0.1, 0.8)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0, 0, 0, 1)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_health"]
bg_color = Color(0.85, 0.15, 0.15, 1)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(1, 0.6, 0.6, 0.3)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4

"""
content = content.replace('[node name="UILayer"', subresource + '[node name="UILayer"')

health_block = """
[node name="HealthContainer" type="VBoxContainer" parent="MarginContainer/VBoxContainer"]
layout_mode = 2
theme_override_constants/separation = 2

[node name="HealthLabel" type="Label" parent="MarginContainer/VBoxContainer/HealthContainer"]
layout_mode = 2
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 1
theme_override_constants/shadow_offset_y = 1
theme_override_constants/outline_size = 3
theme_override_font_sizes/font_size = 14
text = "Health"

[node name="HealthBar" type="ProgressBar" parent="MarginContainer/VBoxContainer/HealthContainer"]
custom_minimum_size = Vector2(160, 16)
layout_mode = 2
size_flags_horizontal = 0
theme_override_styles/background = SubResource("StyleBoxFlat_health_bg")
theme_override_styles/fill = SubResource("StyleBoxFlat_health")
value = 100.0
show_percentage = false
"""

content = content.replace('[node name="StaminaContainer"', health_block + '\n[node name="StaminaContainer"')

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
