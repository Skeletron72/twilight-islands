import re

with open('scenes/ui/hotbar_ui.tscn', 'r') as f:
    content = f.read()

# Add font ext_resource if missing
if 'WarmPixel.ttf' not in content:
    content = content.replace('[ext_resource type="Texture2D" path="res://assets/sprites/ui/inventory/UI.png" id="tex_ui"]', 
                              '[ext_resource type="Texture2D" path="res://assets/sprites/ui/inventory/UI.png" id="tex_ui"]\n[ext_resource type="FontFile" path="res://assets/fonts/WarmPixel.ttf" id="font_warm"]')

# Add theme_override_fonts/font = ExtResource("font_warm") to all Amount labels
content = re.sub(r'(theme_override_font_sizes/font_size = 12)', r'theme_override_fonts/font = ExtResource("font_warm")\n\1', content)

with open('scenes/ui/hotbar_ui.tscn', 'w') as f:
    f.write(content)
