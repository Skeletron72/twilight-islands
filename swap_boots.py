import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Extract the Boots block and Cloth block
# [node name="Cloth" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_cloth")\nhframes = 9
cloth_block = '[node name="Cloth" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_cloth")\nhframes = 9'
boots_block = '[node name="Boots" type="Sprite2D" parent="Visuals"]\ntexture = ExtResource("tex_boots")\nhframes = 9'

if cloth_block in content and boots_block in content:
    # Remove boots
    content = content.replace(boots_block + '\n\n', '')
    # Insert boots before cloth
    content = content.replace(cloth_block, boots_block + '\n\n' + cloth_block)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
