import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# 1. Add Chalkboard font resource
font_chalk = '[ext_resource type="FontFile" uid="uid://chalkboardfont" path="res://assets/fonts/Chalkboard.ttf" id="4_font_chalk"]\n'
content = re.sub(r'(\[ext_resource)', font_chalk + r'\1', content, count=1)

# 2. Add LabelSettings for time and day
label_settings = """
[sub_resource type="LabelSettings" id="LabelSettings_time"]
font = ExtResource("4_font_chalk")
font_size = 20
font_color = Color(1, 1, 1, 1)
outline_size = 4
outline_color = Color(0, 0, 0, 1)

[sub_resource type="LabelSettings" id="LabelSettings_day"]
font = ExtResource("4_font_chalk")
font_size = 14
font_color = Color(0.8, 0.8, 0.8, 1)
outline_size = 4
outline_color = Color(0, 0, 0, 1)
"""
content = re.sub(r'(\[node name="UILayer")', label_settings + r'\n\1', content)

# 3. Replace old MarginContainer with TimeContainer
old_margin_container = r'\[node name="MarginContainer" type="MarginContainer" parent="\.".*?text = "Day 1 - Morning \(Press Space to advance\)"'

new_time_container = """[node name="TimeContainer" type="VBoxContainer" parent="."]
offset_left = 16.0
offset_top = 16.0
offset_right = 64.0
offset_bottom = 120.0
theme_override_constants/separation = 2
alignment = 0

[node name="TimeIcon" type="TextureRect" parent="TimeContainer"]
custom_minimum_size = Vector2(48, 48)
layout_mode = 2
size_flags_horizontal = 4
stretch_mode = 2

[node name="TimeLabel" type="Label" parent="TimeContainer"]
layout_mode = 2
text = "Утро"
label_settings = SubResource("LabelSettings_time")
horizontal_alignment = 1

[node name="DayLabel" type="Label" parent="TimeContainer"]
layout_mode = 2
text = "День 1"
label_settings = SubResource("LabelSettings_day")
horizontal_alignment = 1"""

content = re.sub(old_margin_container, new_time_container, content, flags=re.DOTALL)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)

