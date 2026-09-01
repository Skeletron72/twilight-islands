import re

with open('scenes/objects/stone.tscn', 'r') as f:
    content = f.read()

# Add the Texture back as an ExtResource
ext_resource = '[ext_resource type="Texture2D" uid="uid://rock1placeholder" path="res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Rock_Animations/Rock_1_Anim.png" id="tex_placeholder"]\n'
content = content.replace('[ext_resource type="Script"', ext_resource + '[ext_resource type="Script"', 1)

# Add texture to Sprite2D
content = content.replace('[node name="Sprite2D" type="Sprite2D" parent="." unique_id=395918286]\n', '[node name="Sprite2D" type="Sprite2D" parent="." unique_id=395918286]\ntexture = ExtResource("tex_placeholder")\nhframes = 8\n')

with open('scenes/objects/stone.tscn', 'w') as f:
    f.write(content)
