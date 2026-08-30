import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

quest_page_str = """[node name="QuestTab" type="Control" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages"]
visible = false
layout_mode = 2

[node name="Label" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/QuestTab"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Задания пока недоступны"
horizontal_alignment = 1
vertical_alignment = 1
"""

# Remove the one I appended to the end of the file
content = content.replace(quest_page_str, '')
content = content.strip() + "\n\n" + quest_page_str

# Wait, adding to the very end of the file IS correct because node order dictates child order, and Pages is just a parent container. As long as the parent path matches, Godot will assemble the tree correctly!
# BUT let's just make sure there's no trailing whitespace issue.

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
