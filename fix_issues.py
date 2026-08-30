import re

# 1. Reduce speed in player.gd
with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace('@export var speed: float = 80.0', '@export var speed: float = 55.0')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)

# 2. Update TargetHighlight in player.tscn
with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

old_highlight = """[node name="TargetHighlight" type="Sprite2D" parent="."]
visible = false
modulate = Color(1, 1, 0, 0.5)
scale = Vector2(0.6, 0.6)
texture = ExtResource("2_yyy")
z_index = -1"""

new_highlight = """[node name="TargetHighlight" type="ColorRect" parent="."]
visible = false
modulate = Color(1, 1, 1, 0.25)
offset_left = -16.0
offset_top = -16.0
offset_right = 16.0
offset_bottom = 16.0
z_index = -1
mouse_filter = 2"""

content = content.replace(old_highlight, new_highlight)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)

# 3. Remove scale from twilight_ore.tscn
with open('scenes/levels/twilight_ore.tscn', 'r') as f:
    content = f.read()

content = re.sub(r'scale = Vector2\([^)]+\)\n', '', content)

with open('scenes/levels/twilight_ore.tscn', 'w') as f:
    f.write(content)
