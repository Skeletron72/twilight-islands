with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_btn = """			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			btn.clip_text = true"""

new_btn = """			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			btn.clip_text = true
			btn.flat = true
			btn.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
			btn.add_theme_font_size_override("font_size", 16)
			btn.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
			btn.add_theme_color_override("font_hover_color", Color(0.4, 0.2, 0.1, 1))
			btn.add_theme_color_override("font_pressed_color", Color(0.1, 0.05, 0.02, 1))"""

content = content.replace(old_btn, new_btn)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
