import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Update Open Book
content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_book"\]\natlas = ExtResource\("tex_book"\)\nregion = Rect2\(.*?\)', 
                 r'[sub_resource type="AtlasTexture" id="AtlasTexture_book"]\natlas = ExtResource("tex_book")\nregion = Rect2(16, 32, 160, 96)', content)

# Update Closed Book
content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_closed_book"\]\natlas = ExtResource\("tex_book"\)\nregion = Rect2\(.*?\)', 
                 r'[sub_resource type="AtlasTexture" id="AtlasTexture_closed_book"]\natlas = ExtResource("tex_book")\nregion = Rect2(192, 32, 80, 94)', content)

# We have AtlasTexture_bookmark_red, let's rename it and create active/inactive
content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_bookmark_red"\]\natlas = ExtResource\("tex_book"\)\nregion = Rect2\(.*?\)',
"""[sub_resource type="AtlasTexture" id="AtlasTexture_bookmark_active"]
atlas = ExtResource("tex_book")
region = Rect2(96, 16, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_bookmark_inactive"]
atlas = ExtResource("tex_book")
region = Rect2(112, 16, 16, 16)""", content)

# Also need to assign these to the BookUI node
content = content.replace('open_book_tex = SubResource("AtlasTexture_book")', 'open_book_tex = SubResource("AtlasTexture_book")\nbookmark_active_tex = SubResource("AtlasTexture_bookmark_active")\nbookmark_inactive_tex = SubResource("AtlasTexture_bookmark_inactive")')

# Replace the texture_normal references on tabs from _bookmark_red to _bookmark_inactive as default
content = content.replace('texture_normal = SubResource("AtlasTexture_bookmark_red")', 'texture_normal = SubResource("AtlasTexture_bookmark_inactive")')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
