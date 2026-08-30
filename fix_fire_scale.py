import re

with open('scenes/objects/campfire.tscn', 'r') as f:
    content = f.read()

# Current FireSprite node looks like this:
# [node name="FireSprite" type="Sprite2D" parent="."]
# position = Vector2(0, -2)
# texture = ExtResource("3_fire")
# hframes = 4

old_sprite = """[node name="FireSprite" type="Sprite2D" parent="."]
position = Vector2(0, -2)
texture = ExtResource("3_fire")
hframes = 4"""

new_sprite = """[node name="FireSprite" type="Sprite2D" parent="."]
position = Vector2(-2, -4)
scale = Vector2(2, 2)
texture = ExtResource("3_fire")
hframes = 4"""

content = content.replace(old_sprite, new_sprite)

with open('scenes/objects/campfire.tscn', 'w') as f:
    f.write(content)
