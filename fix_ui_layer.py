import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Remove the BookButton and SubResource StyleBoxFlat_btn
content = re.sub(r'\[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_btn"\].*?text = "КНИГА \(Tab\)"', '', content, flags=re.DOTALL)

# Add our new BookToggleContainer
new_button = """[sub_resource type="AtlasTexture" id="AtlasTexture_book_closed"]
atlas = ExtResource("2_tex")
region = Rect2(928, 256, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_book_closed_hover"]
atlas = ExtResource("2_tex")
region = Rect2(992, 256, 16, 16)

[sub_resource type="LabelSettings" id="LabelSettings_warm"]
font = ExtResource("3_font")
font_color = Color(1, 1, 1, 1)
outline_size = 4
outline_color = Color(0, 0, 0, 1)

[node name="BookToggleContainer" type="VBoxContainer" parent="."]
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -80.0
offset_top = 16.0
offset_right = -16.0
offset_bottom = 96.0
grow_horizontal = 0
theme_override_constants/separation = 4
alignment = 1

[node name="BookToggleBtn" type="TextureButton" parent="BookToggleContainer"]
custom_minimum_size = Vector2(48, 48)
layout_mode = 2
size_flags_horizontal = 4
texture_normal = SubResource("AtlasTexture_book_closed")
texture_hover = SubResource("AtlasTexture_book_closed_hover")
stretch_mode = 0

[node name="KeyLabel" type="Label" parent="BookToggleContainer"]
layout_mode = 2
text = "[TAB]"
label_settings = SubResource("LabelSettings_warm")
horizontal_alignment = 1"""

content = content.replace('[node name="BookUI"', new_button + '\n\n[node name="BookUI"')

# We also need to make sure the textures and fonts are loaded!
# At the top of the file:
# [ext_resource type="Script" uid="uid://v01ll20qiani" path="res://scripts/components/ui_manager.gd" id="1_ui"]
tex_import = '[ext_resource type="Texture2D" uid="uid://texui123" path="res://resources/items/UI.png" id="2_tex"]\n'
font_import = '[ext_resource type="FontFile" uid="uid://fontwarm123" path="res://assets/fonts/WarmPixel.ttf" id="3_font"]\n'

# Find the first [ext_resource
content = re.sub(r'(\[ext_resource)', tex_import + font_import + r'\1', content, count=1)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
