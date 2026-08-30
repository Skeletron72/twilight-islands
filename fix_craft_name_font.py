import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Add styling to craft_name in _ready
old_ready = """func _ready() -> void:
	book_panel.visible = false
	dim_bg.visible = false"""

new_ready = """func _ready() -> void:
	book_panel.visible = false
	dim_bg.visible = false
	
	craft_name.label_settings = null
	craft_name.add_theme_font_override("font", preload("res://assets/fonts/Chalkboard.ttf"))
	craft_name.add_theme_font_size_override("font_size", 16)
	craft_name.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))"""

content = content.replace(old_ready, new_ready)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
