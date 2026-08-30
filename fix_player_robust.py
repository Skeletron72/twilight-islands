import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Fix player physics collision
pattern1 = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="\."[^\]]*\]\n(?:position = [^\n]+\n)?)shape = SubResource\("CapsuleShape2D_abc12"\)'
content = re.sub(pattern1, r'[node name="CollisionShape2D" type="CollisionShape2D" parent="."]\nposition = Vector2(0, -4)\nrotation = 1.5708\nshape = SubResource("CapsuleShape2D_abc12")', content)

# Fix player interaction collision
pattern2 = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionArea"[^\]]*\]\n(?:position = [^\n]+\n)?)shape = SubResource\("CapsuleShape2D_abc12"\)'
content = re.sub(pattern2, r'[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionArea"]\nposition = Vector2(0, -4)\nrotation = 1.5708\nshape = SubResource("CapsuleShape2D_abc12")', content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
