import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_block = """			if eq_id != "":
				var btn = Button.new()
				btn.text = "Снять"
				btn.flat = true
				btn.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
				btn.add_theme_font_size_override("font_size", 12)
				btn.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2, 1))
				btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.4, 1))
				
				# Position it nicely
				btn.position = Vector2(44, 12)
				btn.pressed.connect(func(): 
					InventoryManager.unequip(s)
					_refresh_character_tab()
				)
				slot_panel.add_child(btn)"""

new_block = """			if eq_id != "":
				slot_panel.mouse_filter = Control.MOUSE_FILTER_STOP
				slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				
				slot_panel.gui_input.connect(func(event: InputEvent):
					if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						InventoryManager.unequip(s)
						_refresh_character_tab()
				)"""

content = content.replace(old_block, new_block)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
