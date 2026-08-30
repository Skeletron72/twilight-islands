with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# I will just write a fresh ui_layer.tscn base structure with the exact order needed.
# Let's extract the pieces!

import re

# We need everything from the top down to UILayer
header = content.split('[node name="UILayer" type="CanvasLayer"]')[0] + '[node name="UILayer" type="CanvasLayer"]\nscript = ExtResource("1_ui")\n\n'

# BookToggleContainer block
btn_block = re.search(r'(\[node name="BookToggleContainer".*?horizontal_alignment = 1\n)', content, flags=re.DOTALL).group(1)

# TimeContainer block
# I will reconstruct it manually so it's perfect
time_block = """[node name="TimeContainer" type="VBoxContainer" parent="."]
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
horizontal_alignment = 1
"""

# BookUI block
book_block = '[node name="BookUI" parent="." unique_id=2141288084 instance=ExtResource("3_book")]\n'

# Rest of the file
rest_block = re.search(r'(\[node name="HotbarUI".*?)$', content, flags=re.DOTALL).group(1)

new_content = header + btn_block + "\n" + time_block + "\n" + book_block + "\n" + rest_block

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(new_content)
