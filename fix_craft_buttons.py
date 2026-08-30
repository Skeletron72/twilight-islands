import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_btn = """	for recipe_id in ItemDB.RECIPES.keys():
		var btn = Button.new()
		var item = ItemDB.get_item(recipe_id)
		btn.text = item.get("name", recipe_id)
		btn.icon = ItemDB.get_icon(recipe_id)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.clip_text = true
		btn.pressed.connect(func(): _show_recipe_details(recipe_id))
		craft_recipe_list.add_child(btn)"""

new_btn = """	for recipe_id in ItemDB.RECIPES.keys():
		var btn = Button.new()
		var item = ItemDB.get_item(recipe_id)
		btn.text = " " + item.get("name", recipe_id)
		btn.icon = ItemDB.get_icon(recipe_id)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.clip_text = true
		
		btn.flat = true
		btn.add_theme_font_override("font", preload("res://assets/fonts/Chalkboard.ttf"))
		btn.add_theme_font_size_override("font_size", 14)
		btn.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
		btn.add_theme_color_override("font_hover_color", Color(0.4, 0.2, 0.1, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0.1, 0.05, 0.02, 1))
		
		var empty_style = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("hover", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)
		btn.add_theme_stylebox_override("focus", empty_style)
		
		btn.pressed.connect(func(): _show_recipe_details(recipe_id))
		craft_recipe_list.add_child(btn)"""

content = content.replace(old_btn, new_btn)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
