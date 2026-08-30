import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Change capsule to be smaller and sit at the feet
# radius = 6.0, height = 12.0
content = re.sub(r'radius = \d+\.\d+\nheight = \d+\.\d+', 'radius = 6.0\nheight = 14.0', content)

# Sometimes capsule doesn't have .0 if it's int, let's just replace the whole SubResource block
sub_res = """[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_abc12"]
radius = 6.0
height = 16.0"""

content = re.sub(r'\[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_abc12"\]\nradius = [^\n]+\nheight = [^\n]+', sub_res, content)

# Add rotation to make it horizontal (better for top-down feet) and position it at feet
# The collision shape is under Player and InteractionArea
# Find [node name="CollisionShape2D" parent="."] and replace
# It doesn't have a position currently. We will add position and rotation.

pattern1 = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="\."\]\nshape = SubResource\("CapsuleShape2D_abc12"\))'
content = re.sub(pattern1, r'\1\nposition = Vector2(0, -4)\nrotation = 1.5708', content)

pattern2 = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionArea"\]\nshape = SubResource\("CapsuleShape2D_abc12"\))'
content = re.sub(pattern2, r'\1\nposition = Vector2(0, -4)\nrotation = 1.5708', content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
