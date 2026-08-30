with open('scripts/autoloads/placement_manager.gd', 'r') as f:
    content = f.read()

old_input = """	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Prevent placing if clicking on UI
		# Wait, checking UI might be tricky. Let's assume left click is place
		if can_place:
			_place_object(target_pos)"""

new_input = """	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _was_pressed:
			_was_pressed = true
			
			# Check if over UI (naive check for now - if book is open, don't place)
			var ui_layer = get_tree().current_scene.get_node_or_null("UILayer")
			if ui_layer and ui_layer.has_node("BookUI") and ui_layer.get_node("BookUI").visible:
				return
				
			if can_place:
				_place_object(target_pos)
	else:
		_was_pressed = false"""

content = content.replace(old_input, new_input)
# Add _was_pressed var
content = content.replace('var current_scene = null', 'var current_scene = null\nvar _was_pressed: bool = false')

with open('scripts/autoloads/placement_manager.gd', 'w') as f:
    f.write(content)
