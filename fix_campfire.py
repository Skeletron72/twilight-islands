import re

with open('scenes/objects/campfire.tscn', 'r') as f:
    content = f.read()

sprite_node = """[node name="Sprite2D" type="Sprite2D" parent="."]
texture = SubResource("AtlasTexture_campfire")
offset = Vector2(0, -16)

"""

if '[node name="Sprite2D"' not in content:
    content = content.replace('[node name="CollisionShape2D"', sprite_node + '[node name="CollisionShape2D"')

# Also, the campfire is 32x32, so we should offset it Vector2(0, -8) or something if the base is the bottom 16px?
# "занимает 4 тайла" -> this means it's a 2x2 grid. If the origin is (0,0), a 32x32 sprite is centered, so Y goes from -16 to +16.
# We usually want the bottom of the sprite to touch Y=0 for Y-sorting, but since it's 32x32 footprint, its collision shape is also 28x28.
# If the collision shape is centered at Y=0, the footprint is Y=-14 to Y=14. So Y-sort origin at Y=0 means the physical center of the 2x2 footprint is Y=0.
# So we DO NOT need offset for Campfire! It's a flat object on the ground!
content = content.replace('offset = Vector2(0, -16)\n\n', '')

with open('scenes/objects/campfire.tscn', 'w') as f:
    f.write(content)
