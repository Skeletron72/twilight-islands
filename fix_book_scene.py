import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# I need to insert the SubResources BEFORE the [node name="BookUI" block
atlas_closed = """[sub_resource type="AtlasTexture" id="AtlasTexture_closed_book"]
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

"""

# Insert before [node name="BookUI"
content = re.sub(r'(\[node name="BookUI".*?\])', atlas_closed + r'\1\nclosed_book_tex = SubResource("AtlasTexture_closed_book")\nopen_book_tex = SubResource("AtlasTexture_book")', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
