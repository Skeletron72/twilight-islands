import re

with open('scenes/ui/mobile_controls.tscn', 'r') as f:
    content = f.read()

# Add the new texture resources
new_resources = """[ext_resource type="Texture2D" path="res://assets/sprites/ui/joy_base.png" id="tex_base"]
[ext_resource type="Texture2D" path="res://assets/sprites/ui/joy_knob.png" id="tex_knob"]
[ext_resource type="Texture2D" path="res://assets/sprites/ui/action_button.png" id="tex_act"]"""

content = content.replace('[ext_resource type="Texture2D" uid="uid://dp5wprok3acx3" path="res://icon.png" id="3_tex"]', new_resources)

# Replace Base texture
content = content.replace('texture = ExtResource("3_tex")', 'texture = ExtResource("tex_base")', 1)
# Replace Knob texture
content = content.replace('texture = ExtResource("3_tex")', 'texture = ExtResource("tex_knob")', 1)
# Replace ActionButton texture
content = content.replace('texture = ExtResource("3_tex")', 'texture = ExtResource("tex_act")', 1)

# Because the new images are 16x16, we want them pixelated.
# In Godot 4, texture filtering is usually inherited from CanvasItem (which is usually Nearest if the project is set up for pixel art).
# But just in case, we can set texture_filter = 1 (Nearest) on the TextureRects.
content = content.replace('expand_mode = 1', 'expand_mode = 1\ntexture_filter = 1')

# For the Sprite2D
content = content.replace('scale = Vector2(0.5, 0.5)', 'scale = Vector2(4.0, 4.0)\ntexture_filter = 1')

with open('scenes/ui/mobile_controls.tscn', 'w') as f:
    f.write(content)
