import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# 1. Add background stylebox for stamina
bg_style = """[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_stamina_bg"]
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

"""
content = content.replace('[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_stamina"]', bg_style + '[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_stamina"]')

# 2. Modify Stamina fill stylebox to have matching borders/radius
old_fill = """[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_stamina"]
bg_color = Color(0.2, 0.8, 0.2, 1)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2"""

new_fill = """[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_stamina"]
bg_color = Color(0.15, 0.85, 0.25, 1)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.8, 1, 0.8, 0.3)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4"""

content = content.replace(old_fill, new_fill)

# 3. Replace StaminaBar node with StaminaContainer + Label + StaminaBar
old_node = """[node name="StaminaBar" type="ProgressBar" parent="MarginContainer/VBoxContainer"]
custom_minimum_size = Vector2(150, 12)
layout_mode = 2
size_flags_horizontal = 0
theme_override_styles/fill = SubResource("StyleBoxFlat_stamina")
value = 100.0
show_percentage = false"""

new_node = """[node name="StaminaContainer" type="VBoxContainer" parent="MarginContainer/VBoxContainer"]
layout_mode = 2
theme_override_constants/separation = 2

[node name="StaminaLabel" type="Label" parent="MarginContainer/VBoxContainer/StaminaContainer"]
layout_mode = 2
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 1
theme_override_constants/shadow_offset_y = 1
theme_override_constants/outline_size = 3
theme_override_font_sizes/font_size = 14
text = "Stamina"

[node name="StaminaBar" type="ProgressBar" parent="MarginContainer/VBoxContainer/StaminaContainer"]
custom_minimum_size = Vector2(160, 16)
layout_mode = 2
size_flags_horizontal = 0
theme_override_styles/background = SubResource("StyleBoxFlat_stamina_bg")
theme_override_styles/fill = SubResource("StyleBoxFlat_stamina")
value = 100.0
show_percentage = false"""

content = content.replace(old_node, new_node)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
