tscn_content = """[gd_scene format=3 uid="uid://bookui123"]

[ext_resource type="Script" path="res://scripts/components/book_ui.gd" id="1_book"]
[ext_resource type="Texture2D" path="res://assets/sprites/ui/inventory/Book.png" id="tex_book"]

[sub_resource type="AtlasTexture" id="AtlasTexture_book"]
atlas = ExtResource("tex_book")
region = Rect2(16, 17, 160, 111)

[sub_resource type="AtlasTexture" id="AtlasTexture_closed_book"]
atlas = ExtResource("tex_book")
region = Rect2(208, 16, 128, 144)

[sub_resource type="AtlasTexture" id="AtlasTexture_bookmark_red"]
atlas = ExtResource("tex_book")
region = Rect2(110, 16, 20, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_inv"]
atlas = ExtResource("tex_book")
region = Rect2(304, 32, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_char"]
atlas = ExtResource("tex_book")
region = Rect2(272, 32, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_icon_craft"]
atlas = ExtResource("tex_book")
region = Rect2(288, 32, 16, 16)

[node name="BookUI" type="Control"]
process_mode = 3
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_book")
closed_book_tex = SubResource("AtlasTexture_closed_book")
open_book_tex = SubResource("AtlasTexture_book")

[node name="DimBackground" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0, 0, 0, 0.5)

[node name="CenterContainer" type="CenterContainer" parent="DimBackground"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="MainVBox" type="VBoxContainer" parent="DimBackground/CenterContainer"]
layout_mode = 2
theme_override_constants/separation = -8
alignment = 1

[node name="Tabs" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox"]
layout_mode = 2
alignment = 1
theme_override_constants/separation = 16

[node name="BtnInv" type="TextureButton" parent="DimBackground/CenterContainer/MainVBox/Tabs"]
custom_minimum_size = Vector2(60, 48)
layout_mode = 2
texture_normal = SubResource("AtlasTexture_bookmark_red")
stretch_mode = 0

[node name="Icon" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/Tabs/BtnInv"]
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
texture = SubResource("AtlasTexture_icon_inv")
expand_mode = 1
stretch_mode = 5

[node name="BtnChar" type="TextureButton" parent="DimBackground/CenterContainer/MainVBox/Tabs"]
custom_minimum_size = Vector2(60, 48)
layout_mode = 2
texture_normal = SubResource("AtlasTexture_bookmark_red")
stretch_mode = 0

[node name="Icon" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/Tabs/BtnChar"]
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
texture = SubResource("AtlasTexture_icon_char")
expand_mode = 1
stretch_mode = 5

[node name="BtnCraft" type="TextureButton" parent="DimBackground/CenterContainer/MainVBox/Tabs"]
custom_minimum_size = Vector2(60, 48)
layout_mode = 2
texture_normal = SubResource("AtlasTexture_bookmark_red")
stretch_mode = 0

[node name="Icon" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/Tabs/BtnCraft"]
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
texture = SubResource("AtlasTexture_icon_craft")
expand_mode = 1
stretch_mode = 5

[node name="BookPanel" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox"]
custom_minimum_size = Vector2(480, 333)
layout_mode = 2
texture = SubResource("AtlasTexture_book")
texture_filter = 1
expand_mode = 1
stretch_mode = 5

[node name="Pages" type="MarginContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/margin_left = 40
theme_override_constants/margin_top = 25
theme_override_constants/margin_right = 40
theme_override_constants/margin_bottom = 25

[node name="InventoryTab" type="Control" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages"]
layout_mode = 2

[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="LeftPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Рюкзак"
horizontal_alignment = 1

[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/ScrollContainer"]
layout_mode = 2
columns = 4

[node name="Divider" type="ColorRect" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer"]
custom_minimum_size = Vector2(2, 0)
layout_mode = 2
color = Color(0, 0, 0, 0)

[node name="RightPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Детали"
horizontal_alignment = 1

[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3
alignment = 1

[node name="IconRect" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/Details"]
custom_minimum_size = Vector2(64, 64)
layout_mode = 2
stretch_mode = 5

[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0, 0, 1)
text = "Выберите предмет"
horizontal_alignment = 1

[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.2, 0.2, 1)
theme_override_font_sizes/font_size = 12
text = ""
horizontal_alignment = 1
autowrap_mode = 3

[node name="CharacterTab" type="Control" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages"]
visible = false
layout_mode = 2

[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="LeftPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Экипировка"
horizontal_alignment = 1

[node name="EquipGrid" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage"]
layout_mode = 2
size_flags_vertical = 3
columns = 2

[node name="Divider" type="ColorRect" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer"]
custom_minimum_size = Vector2(2, 0)
layout_mode = 2
color = Color(0, 0, 0, 0)

[node name="RightPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Гардероб"
horizontal_alignment = 1

[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer"]
layout_mode = 2
columns = 4

[node name="CraftTab" type="Control" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages"]
visible = false
layout_mode = 2

[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="LeftPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Чертежи"
horizontal_alignment = 1

[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="RecipeList" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Divider" type="ColorRect" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer"]
custom_minimum_size = Vector2(2, 0)
layout_mode = 2
color = Color(0, 0, 0, 0)

[node name="RightPage" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3

[node name="Title" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.1, 0.05, 1)
text = "Создание"
horizontal_alignment = 1

[node name="Details" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage"]
layout_mode = 2
size_flags_vertical = 3

[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2

[node name="IconRect" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer"]
custom_minimum_size = Vector2(48, 48)
layout_mode = 2
stretch_mode = 5

[node name="NameLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0, 0, 1)
text = "Выберите чертеж"

[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.2, 0.2, 0.2, 1)
theme_override_font_sizes/font_size = 12
autowrap_mode = 3

[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0.3, 0, 1)
theme_override_font_sizes/font_size = 12

[node name="Label" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.2, 0.1, 1)
text = "Требуется:"

[node name="ReqList" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
size_flags_vertical = 3

[node name="CraftButton" type="Button" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details"]
layout_mode = 2
text = "Создать"
"""
with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(tscn_content)
