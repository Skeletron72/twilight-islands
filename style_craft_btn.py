import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

pattern = r'(\[node name="CraftButton".*?\nlayout_mode = 2\ntext = "Создать"\n)'
replacement = r"""\1theme_override_fonts/font = ExtResource("4_yq8p3")
theme_override_font_sizes/font_size = 16
theme_override_colors/font_color = Color(0.9, 0.8, 0.6, 1)
theme_override_colors/font_hover_color = Color(1, 1, 1, 1)
"""

content = re.sub(pattern, replacement, content)

# But wait, what about the background? We can use flat=true or inject a StyleBoxFlat.
# Since it's a Craft button, a flat button might look too plain.
# Let's inject flat = true so it looks like a nice text button, or just leave the default gray but with WarmPixel font?
# Actually, the user asked to "format it". I'll add a simple flat=true.
content = content.replace('text = "Создать"\ntheme_override_fonts', 'text = "Создать"\nflat = true\ntheme_override_fonts')


with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
