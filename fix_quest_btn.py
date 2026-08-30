import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

quest_btn = """[node name="BtnQuest" type="TextureButton" parent="DimBackground/CenterContainer/MainVBox/Tabs"]
custom_minimum_size = Vector2(48, 48)
layout_mode = 2
texture_normal = SubResource("AtlasTexture_bookmark_inactive")
stretch_mode = 0

[node name="Icon" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/Tabs/BtnQuest"]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -16.0
offset_top = -16.0
offset_right = 16.0
offset_bottom = 16.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
texture = SubResource("AtlasTexture_icon_quest_inactive")
expand_mode = 1
stretch_mode = 5

"""

content = re.sub(r'(\[node name="BookPanel" type="TextureRect")', quest_btn + r'\1', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
