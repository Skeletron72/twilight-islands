import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_req = """		var req_label = Label.new()
		req_label.text = "- %s: %d / %d" % [ItemDB.get_item(req_id).get("name", req_id), have_amt, req_amt]
		req_label.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
		req_label.add_theme_font_size_override("font_size", 12)
		req_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if have_amt < req_amt:
			req_label.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
			can_craft = false
		else:
			req_label.add_theme_color_override("font_color", Color(0, 0.4, 0))
			
		craft_req_list.add_child(req_label)"""

new_req = """		var req_box = HBoxContainer.new()
		
		var icon = TextureRect.new()
		icon.texture = ItemDB.get_icon(req_id)
		icon.custom_minimum_size = Vector2(16, 16)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		req_box.add_child(icon)
		
		var req_label = Label.new()
		req_label.text = "%s: %d / %d" % [ItemDB.get_item(req_id).get("name", req_id), have_amt, req_amt]
		req_label.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
		req_label.add_theme_font_size_override("font_size", 12)
		req_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if have_amt < req_amt:
			req_label.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
			can_craft = false
		else:
			req_label.add_theme_color_override("font_color", Color(0, 0.4, 0))
			
		req_box.add_child(req_label)
		craft_req_list.add_child(req_box)"""

content = content.replace(old_req, new_req)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
