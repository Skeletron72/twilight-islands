import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# We need a new SubResource for the interaction area.
interaction_shape = """
[sub_resource type="CircleShape2D" id="CircleShape2D_interaction"]
radius = 24.0
"""
content = content.replace('[ext_resource', interaction_shape + '\n[ext_resource', 1)

# Now find the InteractionArea's CollisionShape2D and replace its shape
# Make sure to remove the rotation too, since it's a circle
pattern = r'(\[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionArea"[^\]]*\]\n)(?:position = [^\n]+\n)?(?:rotation = [^\n]+\n)?shape = SubResource\("CapsuleShape2D_abc12"\)'
replacement = r'\1position = Vector2(0, -12)\nshape = SubResource("CircleShape2D_interaction")'
content = re.sub(pattern, replacement, content)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)

