import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 1. Update SubResources for the new icons
icons_res = """[sub_resource type="AtlasTexture" id="AtlasTexture_icon_inv_active"]
atlas = ExtResource("tex_book")
region = Rect2(368, 64, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_inv_inactive"]
atlas = ExtResource("tex_book")
region = Rect2(368, 80, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_char_active"]
atlas = ExtResource("tex_book")
region = Rect2(304, 64, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_char_inactive"]
atlas = ExtResource("tex_book")
region = Rect2(304, 80, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_craft_active"]
atlas = ExtResource("tex_book")
region = Rect2(320, 64, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_craft_inactive"]
atlas = ExtResource("tex_book")
region = Rect2(320, 80, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_quest_active"]
atlas = ExtResource("tex_book")
region = Rect2(336, 64, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_quest_inactive"]
atlas = ExtResource("tex_book")
region = Rect2(336, 80, 16, 16)
"""

# Replace old icons
content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_icon_inv"\].*?region = Rect2\(288, 32, 16, 16\)\n', icons_res, content, flags=re.DOTALL)

# Add exports to BookUI
new_exports = """bookmark_active_tex = SubResource("AtlasTexture_bookmark_active")
bookmark_inactive_tex = SubResource("AtlasTexture_bookmark_inactive")
icon_inv_active = SubResource("AtlasTexture_icon_inv_active")
icon_inv_inactive = SubResource("AtlasTexture_icon_inv_inactive")
icon_char_active = SubResource("AtlasTexture_icon_char_active")
icon_char_inactive = SubResource("AtlasTexture_icon_char_inactive")
icon_craft_active = SubResource("AtlasTexture_icon_craft_active")
icon_craft_inactive = SubResource("AtlasTexture_icon_craft_inactive")
icon_quest_active = SubResource("AtlasTexture_icon_quest_active")
icon_quest_inactive = SubResource("AtlasTexture_icon_quest_inactive")"""
content = re.sub(r'bookmark_active_tex = SubResource\("AtlasTexture_bookmark_active"\)\nbookmark_inactive_tex = SubResource\("AtlasTexture_bookmark_inactive"\)', new_exports, content)

# 2. Fix alignment of Tabs (from Center to Right side of book)
# We want the Tabs HBoxContainer to align right.
# Actually, if MainVBox is alignment = 1 (Center), the Tabs will be centered relative to the VBox width.
# If BookPanel is 480px, Tabs HBox will also be centered in 480px.
# To push Tabs to the right, we can wrap Tabs in a MarginContainer with margin_left to push it, OR just add a Spacer (Control with size_flags_horizontal = 3) as the first child of Tabs!
content = content.replace('[node name="BtnInv" type="TextureButton" parent="DimBackground/CenterContainer/MainVBox/Tabs"]',
"""[node name="Spacer" type="Control" parent="DimBackground/CenterContainer/MainVBox/Tabs"]
layout_mode = 2
size_flags_horizontal = 3

[node name="BtnInv" type="TextureButton" parent="DimBackground/CenterContainer/MainVBox/Tabs"]""")

# Also ensure Tabs HBoxContainer has size_flags_horizontal = 3 to expand fully so spacer works
content = content.replace('[node name="Tabs" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox"]\nlayout_mode = 2\nalignment = 1',
'[node name="Tabs" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox"]\nlayout_mode = 2\nsize_flags_horizontal = 3\nalignment = 1')

# 3. Fix mouse filter on Icons and Update texture references to inactive
content = content.replace('texture = SubResource("AtlasTexture_icon_inv")', 'mouse_filter = 2\ntexture = SubResource("AtlasTexture_icon_inv_inactive")')
content = content.replace('texture = SubResource("AtlasTexture_icon_char")', 'mouse_filter = 2\ntexture = SubResource("AtlasTexture_icon_char_inactive")')
content = content.replace('texture = SubResource("AtlasTexture_icon_craft")', 'mouse_filter = 2\ntexture = SubResource("AtlasTexture_icon_craft_inactive")')

# 4. Add the Quest Tab Button
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

[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox"]"""
content = content.replace('[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox"]', quest_btn)

# 5. Add Quest Tab Page
quest_page = """[node name="QuestTab" type="Control" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages"]
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
content = content + "\n" + quest_page

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
