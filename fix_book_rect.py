import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Revert BookPanel to TextureRect with AtlasTexture
old_panel = """[node name="BookPanel" type="NinePatchRect" parent="DimBackground/CenterContainer/HBoxContainer"]
custom_minimum_size = Vector2(400, 368)
layout_mode = 2
texture = ExtResource("tex_book")
region_rect = Rect2(16, 17, 160, 111)
patch_margin_left = 32
patch_margin_top = 32
patch_margin_right = 32
patch_margin_bottom = 32
axis_stretch_horizontal = 1
axis_stretch_vertical = 1"""

new_panel = """[sub_resource type="AtlasTexture" id="AtlasTexture_book"]
atlas = ExtResource("tex_book")
region = Rect2(16, 17, 160, 111)

[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/HBoxContainer"]
custom_minimum_size = Vector2(480, 333)
layout_mode = 2
texture = SubResource("AtlasTexture_book")
texture_filter = 1
expand_mode = 1
stretch_mode = 5"""
content = content.replace(old_panel, new_panel)

# Fix the resource definition by removing StyleBoxTexture_tab and moving AtlasTexture_book definition to the top
# Wait, putting SubResource right before the node is valid in .tscn only if it's declared in the main sub_resource block or inline if supported? 
# In Godot 4, SubResources MUST be at the top of the file before nodes!
