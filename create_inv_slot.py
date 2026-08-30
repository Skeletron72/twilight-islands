tscn_content = """[gd_scene format=3 uid="uid://invslot123"]

[ext_resource type="Script" path="res://scripts/components/inventory_slot.gd" id="1_slot"]
[ext_resource type="Texture2D" path="res://assets/sprites/ui/inventory/UI.png" id="tex_ui"]

[sub_resource type="AtlasTexture" id="AtlasTexture_base"]
atlas = ExtResource("tex_ui")
region = Rect2(416, 272, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_shadow"]
atlas = ExtResource("tex_ui")
region = Rect2(416, 288, 16, 16)

[node name="InventorySlot" type="Control"]
custom_minimum_size = Vector2(48, 48)
layout_mode = 3
anchors_preset = 0
script = ExtResource("1_slot")

[node name="Base" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource("AtlasTexture_base")
texture_filter = 1
expand_mode = 1
stretch_mode = 5

[node name="Shadow" type="TextureRect" parent="."]
visible = false
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource("AtlasTexture_shadow")
texture_filter = 1
expand_mode = 1
stretch_mode = 5

[node name="Icon" type="TextureRect" parent="."]
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
texture_filter = 1
expand_mode = 1
stretch_mode = 5

[node name="Amount" type="Label" parent="."]
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -40.0
offset_top = -23.0
grow_horizontal = 0
grow_vertical = 0
theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)
theme_override_constants/shadow_offset_x = 1
theme_override_constants/shadow_offset_y = 1
theme_override_constants/outline_size = 2
theme_override_font_sizes/font_size = 12
text = "99"
horizontal_alignment = 2
"""
with open('scenes/ui/inventory_slot.tscn', 'w') as f:
    f.write(tscn_content)
