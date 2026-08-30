import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Add ext_resource at the top block
res_tools = '[ext_resource type="Texture2D" path="res://assets/sprites/characters/Human/WAITING/tools_waiting_strip9.png" id="tex_tools"]\n'
content = content.replace('[ext_resource type="Texture2D" path="res://assets/sprites/characters/Human/WAITING/hair_merged_waiting_strip9.png" id="tex_hair"]\n', 
                          '[ext_resource type="Texture2D" path="res://assets/sprites/characters/Human/WAITING/hair_merged_waiting_strip9.png" id="tex_hair"]\n' + res_tools)

# Set texture and hframes on Tools node
content = re.sub(r'\[node name="Tools" type="Sprite2D" parent="Visuals"\]', 
                 '[node name="Tools" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_tools")\nhframes = 9', content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
