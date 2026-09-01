import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# 1. Update Visuals position
content = re.sub(r'\[node name="Visuals" type="Node2D" parent="\.".*?\]\nposition = Vector2\(0, -16\)', '[node name="Visuals" type="Node2D" parent="."]\nposition = Vector2(0, -5)', content)

# 2. Update CollisionShape2D (Player body)
content = re.sub(r'\[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_abc12"\]\nradius = [0-9.]+\nheight = [0-9.]+', '[sub_resource type="CircleShape2D" id="CircleShape2D_player_base"]\nradius = 6.0', content)

# Replace the body collision node (ignoring unique_id if present)
body_col = r'\[node name="CollisionShape2D" type="CollisionShape2D" parent="\.".*?\]\nposition = Vector2\(0, -14\.1\)\nshape = SubResource\("CapsuleShape2D_abc12"\)'
content = re.sub(body_col, '[node name="CollisionShape2D" type="CollisionShape2D" parent="."]\nposition = Vector2(0, -2)\nshape = SubResource("CircleShape2D_player_base")', content)

# 3. Update InteractionArea
int_col = r'\[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionArea".*?\]\nposition = Vector2\(0, -11\)'
content = re.sub(int_col, '[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionArea"]\nposition = Vector2(0, -2)', content)

# 4. Update Camera2D
cam = r'\[node name="Camera2D" type="Camera2D" parent="\.".*?\]\nposition = Vector2\(0, -9\)'
content = re.sub(cam, '[node name="Camera2D" type="Camera2D" parent="."]\nposition = Vector2(0, -15)', content)

# Also strip all unique_ids from the file for cleanliness and to prevent future regex misses
content = re.sub(r' unique_id=[0-9]+', '', content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
