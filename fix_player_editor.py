import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Add ext_resource lines at the top
ext_str = """
[ext_resource type="Texture2D" path="res://assets/new_assets/Cute_Fantasy/Player/Player_Base/Player_Base_animations.png" id="tex_base"]
[ext_resource type="Texture2D" path="res://assets/new_assets/Cute_Fantasy/Player/Legs/Farmer_Pants/Farmer_Pants_1_Blue.png" id="tex_legs"]
[ext_resource type="Texture2D" path="res://assets/new_assets/Cute_Fantasy/Player/Feet/Shoes_1_Brown.png" id="tex_feet"]
[ext_resource type="Texture2D" path="res://assets/new_assets/Cute_Fantasy/Player/Chest/Farmer_Shirt/Farmer_Shirt_1_Red.png" id="tex_chest"]
[ext_resource type="Texture2D" path="res://assets/new_assets/Cute_Fantasy/Player/Head/Hair_1/Hair_1_Brown.png" id="tex_head"]
[ext_resource type="Texture2D" path="res://assets/new_assets/Cute_Fantasy/Player/Hands/Hands_1_Bare.png" id="tex_hands"]
"""

# Insert right before the first [sub_resource]
sub_res_idx = content.find('[sub_resource')
if sub_res_idx != -1:
    content = content[:sub_res_idx] + ext_str + '\n' + content[sub_res_idx:]

# Now add texture = ExtResource("...") to each Sprite2D
content = re.sub(r'(\[node name="Base" type="Sprite2D".*?\])', r'\1\ntexture = ExtResource("tex_base")', content)
content = re.sub(r'(\[node name="Legs" type="Sprite2D".*?\])', r'\1\ntexture = ExtResource("tex_legs")', content)
content = re.sub(r'(\[node name="Feet" type="Sprite2D".*?\])', r'\1\ntexture = ExtResource("tex_feet")', content)
content = re.sub(r'(\[node name="Chest" type="Sprite2D".*?\])', r'\1\ntexture = ExtResource("tex_chest")', content)
content = re.sub(r'(\[node name="Head" type="Sprite2D".*?\])', r'\1\ntexture = ExtResource("tex_head")', content)
content = re.sub(r'(\[node name="Hands" type="Sprite2D".*?\])', r'\1\ntexture = ExtResource("tex_hands")', content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
