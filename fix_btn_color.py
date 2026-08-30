import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

content = content.replace('Color(0.9, 0.8, 0.6, 1)', 'Color(0.2, 0.1, 0.05, 1)')
content = content.replace('font_hover_color = Color(1, 1, 1, 1)', 'font_hover_color = Color(0.4, 0.2, 0.1, 1)')
# and let's add font_pressed_color
content = content.replace('font_hover_color = Color(0.4, 0.2, 0.1, 1)', 'font_hover_color = Color(0.4, 0.2, 0.1, 1)\ntheme_override_colors/font_pressed_color = Color(0.1, 0.05, 0.02, 1)')


with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
