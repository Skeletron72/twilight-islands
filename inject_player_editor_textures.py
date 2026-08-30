import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Add texture ext_resources if not present
res = """
[ext_resource type="Texture2D" path="res://assets/sprites/characters/Human/WAITING/base_waiting_strip9.png" id="tex_base"]
[ext_resource type="Texture2D" path="res://assets/sprites/characters/Human/WAITING/cloth1_waiting_strip9.png" id="tex_cloth"]
[ext_resource type="Texture2D" path="res://assets/sprites/characters/Human/WAITING/boots1_waiting_strip9.png" id="tex_boots"]
[ext_resource type="Texture2D" path="res://assets/sprites/characters/Human/WAITING/hair_merged_waiting_strip9.png" id="tex_hair"]
"""
if 'id="tex_base"' not in content:
    content = content.replace('[node name="Player"', res + '\n[node name="Player"')

# Update Visuals nodes
content = re.sub(r'\[node name="Base" type="Sprite2D" parent="Visuals"\]', 
                 '[node name="Base" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_base")\nhframes = 9', content)

content = re.sub(r'\[node name="Cloth" type="Sprite2D" parent="Visuals"\]', 
                 '[node name="Cloth" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_cloth")\nhframes = 9', content)

content = re.sub(r'\[node name="Boots" type="Sprite2D" parent="Visuals"\]', 
                 '[node name="Boots" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_boots")\nhframes = 9', content)

content = re.sub(r'\[node name="Hair" type="Sprite2D" parent="Visuals"\]', 
                 '[node name="Hair" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_hair")\nhframes = 9\nvframes = 6', content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
