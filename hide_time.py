import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

content = content.replace('[node name="TimeLabel" type="Label" parent="MarginContainer/VBoxContainer" unique_id=968699069]\nlayout_mode = 2', '[node name="TimeLabel" type="Label" parent="MarginContainer/VBoxContainer" unique_id=968699069]\nvisible = false\nlayout_mode = 2')

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
